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

class OneSignalSerializer {
    private static HashMap<String, Object> convertSubscriptionStateToMap(OSSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("subscribed", state.getSubscribed());
        hash.put("userSubscriptionSetting", state.getUserSubscriptionSetting());
        hash.put("pushToken", state.getPushToken());
        hash.put("userId", state.getUserId());

        return hash;
    }

    private static HashMap<String, Object> convertPermissionStateToMap(OSPermissionState state) {
        HashMap<String, Object> permission = new HashMap<>();

        permission.put("enabled", state.getEnabled());

        return permission;
    }

    private static HashMap<String, Object> convertEmailSubscriptionStateToMap(OSEmailSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("emailUserId", state.getEmailUserId());
        hash.put("emailAddress", state.getEmailAddress());
        hash.put("subscribed", state.getSubscribed());

        return hash;
    }

    static HashMap<String, Object> convertPermissionSubscriptionStateToMap(OSPermissionSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

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

    static HashMap<String, Object> convertSubscriptionStateChangesToMap(OSSubscriptionStateChanges changes) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("to", convertSubscriptionStateToMap(changes.getTo()));
        hash.put("from", convertSubscriptionStateToMap(changes.getFrom()));

        return hash;
    }

    static HashMap<String, Object> convertEmailSubscriptionStateChangesToMap(OSEmailSubscriptionStateChanges changes) {
       HashMap<String, Object> hash = new HashMap<>();

        hash.put("to", convertEmailSubscriptionStateToMap(changes.getTo()));
        hash.put("from", convertEmailSubscriptionStateToMap(changes.getFrom()));

        return hash;
    }

    static HashMap convertPermissionStateChangesToMap(OSPermissionStateChanges changes) {
       HashMap<String, Object> hash = new HashMap<>();

        hash.put("to", convertPermissionStateToMap(changes.getTo()));
        hash.put("from", convertPermissionStateToMap(changes.getFrom()));

        return hash;
    }

    private static HashMap<String, Object> convertNotificationPayloadToMap(OSNotificationPayload payload) throws JSONException {
       HashMap<String, Object> hash = new HashMap<>();

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

        ArrayList<HashMap> buttons = new ArrayList<>();

        if (payload.actionButtons != null) {
            for (int i = 0; i < payload.actionButtons.size(); i++) {
                OSNotificationPayload.ActionButton button = payload.actionButtons.get(i);

               HashMap<String, Object> buttonHash = new HashMap<>();
                buttonHash.put("id", button.id);
                buttonHash.put("text", button.text);
                buttonHash.put("icon", button.icon);
                buttons.add(buttonHash);
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

    static HashMap<String, Object> convertNotificationToMap(OSNotification notification) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

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

    static HashMap<String, Object> convertNotificationOpenResultToMap(OSNotificationOpenResult openResult) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("notification", convertNotificationToMap(openResult.notification));
        hash.put("action", convertNotificationActionToMap(openResult.action));

        return hash;
    }

    private static HashMap<String, Object> convertNotificationActionToMap(OSNotificationAction action) {
        HashMap<String, Object> hash = new HashMap<>();

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

    static HashMap<String, Object> convertInAppMessageClickedActionToMap(OSInAppMessageAction action) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("click_name", action.clickName);
        hash.put("click_url", action.clickUrl);
        hash.put("first_click", action.firstClick);
        hash.put("closes_message", action.closesMessage);

        return hash;
    }

    static HashMap<String, Object> convertOutcomeEventToMap(OutcomeEvent outcomeEvent) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("session", outcomeEvent.getSession().toString());

        if (outcomeEvent.getNotificationIds() == null)
            hash.put("notification_ids", new JSONArray().toString());
        else
            hash.put("notification_ids", outcomeEvent.getNotificationIds().toString());

        hash.put("id", outcomeEvent.getName());
        hash.put("timestamp", outcomeEvent.getTimestamp());
        hash.put("weight", String.valueOf(outcomeEvent.getWeight()));

        return hash;
    }

    private static HashMap<String, Object> convertAndroidBackgroundImageLayoutToMap(BackgroundImageLayout layout) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("image", layout.image);
        hash.put("bodyTextColor", layout.bodyTextColor);
        hash.put("titleTextColor", layout.titleTextColor);

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
