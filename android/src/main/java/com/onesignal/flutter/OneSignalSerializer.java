package com.onesignal.flutter;

import android.util.Log;
import com.onesignal.OSNotificationPayload.BackgroundImageLayout;
import com.onesignal.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class OneSignalSerializer {
    static public HashMap<Object, Object> convertSubscriptionStateToMap(OSSubscriptionState state) {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("subscribed", state.getSubscribed());
        hash.put("userSubscriptionSetting", state.getUserSubscriptionSetting());
        hash.put("pushToken", state.getPushToken());
        hash.put("userId", state.getUserId());

        return hash;
    }

    static public HashMap<Object, Object> convertPermissionStateToMap(OSPermissionState state) {
        HashMap<Object, Object> permission = new HashMap<Object, Object>();

        permission.put("enabled", state.getEnabled());

        return permission;
    }

    static public HashMap<Object, Object> convertEmailSubscriptionStateToMap(OSEmailSubscriptionState state) {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("emailUserId", state.getEmailUserId());
        hash.put("emailAddress", state.getEmailAddress());
        hash.put("subscribed", state.getSubscribed());

        return hash;
    }

    static public HashMap<Object, Object> convertPermissionSubscriptionStateToMap(OSPermissionSubscriptionState state) {
        HashMap<Object, Object> hash = new HashMap();

        OSSubscriptionState subState = state.getSubscriptionStatus();
        OSPermissionState permState = state.getPermissionStatus();
        OSEmailSubscriptionState emailState = state.getEmailSubscriptionStatus();

        if (subState != null)
            hash.put("subscriptionStatus", convertSubscriptionStateToMap(subState));

        if (permState != null)
            hash.put("permissionStatus", convertPermissionStateToMap(state.getPermissionStatus()));

        if (emailState != null)
            hash.put("emailSubscriptionStatus", convertEmailSubscriptionStateToMap(state.getEmailSubscriptionStatus()));

        return hash;
    }

    static public HashMap<Object, Object> convertSubscriptionStateChangesToMap(OSSubscriptionStateChanges changes) {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("to", convertSubscriptionStateToMap(changes.getTo()));
        hash.put("from", convertSubscriptionStateToMap(changes.getFrom()));

        return hash;
    }

    static public HashMap<Object, Object> convertEmailSubscriptionStateChangesToMap(OSEmailSubscriptionStateChanges changes) {
        HashMap hash = new HashMap();

        hash.put("to", convertEmailSubscriptionStateToMap(changes.getTo()));
        hash.put("from", convertEmailSubscriptionStateToMap(changes.getFrom()));

        return hash;
    }

    static public HashMap convertPermissionStateChangesToMap(OSPermissionStateChanges changes) {
        HashMap hash = new HashMap();

        hash.put("to", convertPermissionStateToMap(changes.getTo()));
        hash.put("from", convertPermissionStateToMap(changes.getFrom()));

        return hash;
    }

    static public HashMap<Object, Object> convertNotificationPayloadToMap(OSNotificationPayload payload) throws JSONException {
        HashMap hash = new HashMap();

        hash.put("notificationId", payload.notificationID);
        hash.put("templateName", payload.templateName);
        hash.put("templateId", payload.templateId);
        hash.put("sound", payload.sound);
        hash.put("title", payload.title);
        hash.put("body", payload.body);
        hash.put("launchUrl", payload.launchURL);
        hash.put("smallIcon", payload.smallIcon);
        hash.put("largeIcon", payload.largeIcon);
        hash.put("bigPicture", payload.bigPicture);
        hash.put("smallIconAccentColor", payload.smallIconAccentColor);
        hash.put("ledColor", payload.ledColor);
        hash.put("lockScreenVisibility", payload.lockScreenVisibility);
        hash.put("groupKey", payload.groupKey);
        hash.put("groupMessage", payload.groupMessage);
        hash.put("fromProjectNumber", payload.fromProjectNumber);
        hash.put("collapseId", payload.collapseId);
        hash.put("priority", payload.priority);

        ArrayList<HashMap> buttons = new ArrayList<HashMap>();

        if (payload.actionButtons != null) {
            for (int i = 0; i < payload.actionButtons.size(); i++) {
                OSNotificationPayload.ActionButton button = payload.actionButtons.get(i);

                HashMap buttonHash = new HashMap();
                buttonHash.put("id", button.id);
                buttonHash.put("text", button.text);
                buttonHash.put("icon", button.icon);
            }
        }

        if (buttons.size() > 0)
            hash.put("buttons", buttons);

        if (payload.backgroundImageLayout != null)
            hash.put("backgroundImageLayout", convertAndroidBackgroundImageLayoutToMap(payload.backgroundImageLayout));

        if (payload.rawPayload != null)
            hash.put("rawPayload", payload.rawPayload);

        Log.d("onesignal", "Created json raw payload: " + convertJSONObjectToHashMap(new JSONObject(payload.rawPayload)).toString());

        if (payload.additionalData != null)
            hash.put("additionalData", convertJSONObjectToHashMap(payload.additionalData));

        return hash;
    }

    static public HashMap<Object, Object> convertNotificationToMap(OSNotification notification) throws JSONException {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("payload", convertNotificationPayloadToMap(notification.payload));
        hash.put("shown", notification.shown);
        hash.put("appInFocus", notification.isAppInFocus);
        hash.put("androidNotificationId", notification.androidNotificationId);

        switch (notification.displayType) {
            case None:
                hash.put("displayType", 0);
            case InAppAlert:
                hash.put("displayType", 1);
                break;
            case Notification:
                hash.put("displayType", 2);
        }

        return hash;
    }

    static public HashMap<Object, Object> convertNotificationOpenResultToMap(OSNotificationOpenResult openResult) throws JSONException {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("notification", convertNotificationToMap(openResult.notification));
        hash.put("action", convertNotificationActionToMap(openResult.action));

        return hash;
    }

    static public HashMap<Object, Object> convertNotificationActionToMap(OSNotificationAction action) throws JSONException {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("id", action.actionID);

        switch (action.type) {
            case Opened:
                hash.put("type", 0);
                break;
            case ActionTaken:
                hash.put("type", 1);

        }

        return hash;
    }

    static public HashMap<Object, Object> convertAndroidBackgroundImageLayoutToMap(BackgroundImageLayout layout) {
        HashMap<Object, Object> hash = new HashMap();

        hash.put("image", layout.image);
        hash.put("bodyTextColor", layout.bodyTextColor);
        hash.put("titleTextColor", layout.titleTextColor);

        return hash;
    }

    static public HashMap<Object, Object> convertJSONObjectToHashMap(JSONObject object) throws JSONException {
        HashMap<Object, Object> hash = new HashMap();

        Iterator<String> keys = object.keys();

        while (keys.hasNext()) {
            String key = keys.next();
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

    static public List<Object> convertJSONArrayToList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();

        for (int i = 0; i < array.length(); i++) {
            Object val = array.get(i);

            if (val instanceof JSONArray) {
                val = OneSignalSerializer.convertJSONArrayToList((JSONArray)val);
            } else if (val instanceof JSONObject) {
                val = convertJSONObjectToHashMap((JSONObject)val);
            }

            list.add(val);
        }

        return list;
    }
}
