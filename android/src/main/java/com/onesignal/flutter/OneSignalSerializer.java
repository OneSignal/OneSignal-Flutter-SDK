package com.onesignal.flutter;

import android.util.Log;

import com.onesignal.user.subscriptions.ISubscription;
import com.onesignal.user.subscriptions.IPushSubscription;

import com.onesignal.inAppMessages.IInAppMessage;
import com.onesignal.inAppMessages.IInAppMessageClickResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

class OneSignalSerializer {
    static HashMap<String, Object> convertInAppMessageClickedActionToMap(IInAppMessageClickResult result) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("click_name", result.getAction().getClickName());
        hash.put("click_url", result.getAction().getClickUrl());
        hash.put("first_click", result.getAction().isFirstClick());
        hash.put("closes_message", result.getAction().getClosesMessage());

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageToMap(IInAppMessage message) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message_id", message.getMessageId());

        return hash;
    }

    static HashMap<String, Object> convertOnSubscriptionChanged(IPushSubscription state) {
        HashMap<String, Object> hash = new HashMap<>();
        

        hash.put("token", state.getToken());
        hash.put("pushId", state.getId());
        hash.put("optedIn", state.getOptedIn());

        return hash;
    }


    static HashMap<String, Object> convertJSONObjectToHashMap(JSONObject object) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        if (object == null || object == JSONObject.NULL)
           return hash;

        Iterator<String> keys = object.keys();

        while (keys.hasNext()) {
            String key = keys.next();

            if (object.isNull(key))
                continue;

            Object val = object.get(key);

            if (val instanceof JSONArray) {
                val = convertJSONArrayToList((JSONArray)val);
            } else if (val instanceof JSONObject) {
                val = convertJSONObjectToHashMap((JSONObject)val);
            }

            hash.put(key, val);
        }

        return hash;
    }

    private static List<Object> convertJSONArrayToList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<>();

        for (int i = 0; i < array.length(); i++) {
            Object val = array.get(i);

            if (val instanceof JSONArray)
                val = OneSignalSerializer.convertJSONArrayToList((JSONArray)val);
            else if (val instanceof JSONObject)
                val = convertJSONObjectToHashMap((JSONObject)val);

            list.add(val);
        }

        return list;
    }
}
