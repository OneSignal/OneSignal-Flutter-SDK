package com.onesignal.flutter;

import android.util.Log;

import com.onesignal.OSDeviceState;
import com.onesignal.OSEmailSubscriptionState;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSInAppMessageAction;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationAction;
import com.onesignal.OSNotificationOpenedResult;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OSOutcomeEvent;
import com.onesignal.OSPermissionState;
import com.onesignal.OSPermissionStateChanges;
import com.onesignal.OSSMSSubscriptionState;
import com.onesignal.OSSMSSubscriptionStateChanges;
import com.onesignal.OSSubscriptionState;
import com.onesignal.OSSubscriptionStateChanges;
import com.onesignal.OSOutcomeEvent;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class OneSignalSerializer {
    private static HashMap<String, Object> convertSubscriptionStateToMap(OSSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("isSubscribed", state.isSubscribed());
        hash.put("isPushDisabled", state.isPushDisabled());
        hash.put("pushToken", state.getPushToken());
        hash.put("userId", state.getUserId());

        return hash;
    }

    private static HashMap<String, Object> convertPermissionStateToMap(OSPermissionState state) {
        HashMap<String, Object> permission = new HashMap<>();

        permission.put("areNotificationsEnabled", state.areNotificationsEnabled());

        return permission;
    }

    private static HashMap<String, Object> convertEmailSubscriptionStateToMap(OSEmailSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("emailUserId", state.getEmailUserId());
        hash.put("emailAddress", state.getEmailAddress());
        hash.put("isSubscribed", state.isSubscribed());

        return hash;
    }

    private static HashMap<String, Object> convertSMSSubscriptionStateToMap(OSSMSSubscriptionState state) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("smsUserId", state.getSmsUserId());
        hash.put("smsNumber", state.getSMSNumber());
        hash.put("isSubscribed", state.isSubscribed());

        return hash;
    }

    static HashMap<String, Object> convertDeviceStateToMap(OSDeviceState state) {
        HashMap<String, Object> hash = new HashMap<>();

        if (state == null)
            return hash;

        hash.put("hasNotificationPermission", state.areNotificationsEnabled());
        hash.put("pushDisabled", state.isPushDisabled());
        hash.put("subscribed", state.isSubscribed());
        hash.put("emailSubscribed", state.isEmailSubscribed());
        hash.put("smsSubscribed", state.isSMSSubscribed());
        hash.put("userId", state.getUserId());
        hash.put("pushToken", state.getPushToken());
        hash.put("emailUserId", state.getEmailUserId());
        hash.put("emailAddress", state.getEmailAddress());
        hash.put("smsUserId", state.getSMSUserId());
        hash.put("smsNumber", state.getSMSNumber());

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

    static HashMap<String, Object> convertSMSSubscriptionStateChangesToMap(OSSMSSubscriptionStateChanges changes) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("to", convertSMSSubscriptionStateToMap(changes.getTo()));
        hash.put("from", convertSMSSubscriptionStateToMap(changes.getFrom()));

        return hash;
    }

    static HashMap convertPermissionStateChangesToMap(OSPermissionStateChanges changes) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("to", convertPermissionStateToMap(changes.getTo()));
        hash.put("from", convertPermissionStateToMap(changes.getFrom()));

        return hash;
    }

    static HashMap<String, Object> convertNotificationToMap(OSNotification notification) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("androidNotificationId", notification.getAndroidNotificationId());

        if (notification.getGroupedNotifications() != null && !notification.getGroupedNotifications().isEmpty()) {
            JSONArray payloadJsonArray = new JSONArray();
            for (OSNotification groupedNotification : notification.getGroupedNotifications())
                payloadJsonArray.put(groupedNotification.toJSONObject());

            hash.put("groupedNotifications", payloadJsonArray.toString());
        }

        hash.put("notificationId", notification.getNotificationId());
        hash.put("title", notification.getTitle());

        if (notification.getBody() != null)
            hash.put("body", notification.getBody());
        if (notification.getSmallIcon() != null)
            hash.put("smallIcon", notification.getSmallIcon());
        if (notification.getLargeIcon() != null)
            hash.put("largeIcon", notification.getLargeIcon());
        if (notification.getBigPicture() != null)
            hash.put("bigPicture", notification.getBigPicture());
        if (notification.getSmallIconAccentColor() != null)
            hash.put("smallIconAccentColor", notification.getSmallIconAccentColor());
        if (notification.getLaunchURL() != null)
            hash.put("launchUrl", notification.getLaunchURL());
        if (notification.getSound() != null)
            hash.put("sound", notification.getSound());
        if (notification.getLedColor() != null)
            hash.put("ledColor", notification.getLedColor());
        hash.put("lockScreenVisibility", notification.getLockScreenVisibility());
        if (notification.getGroupKey() != null)
            hash.put("groupKey", notification.getGroupKey());
        if (notification.getGroupMessage() != null)
            hash.put("groupMessage", notification.getGroupMessage());
        if (notification.getFromProjectNumber() != null)
            hash.put("fromProjectNumber", notification.getFromProjectNumber());
        if (notification.getCollapseId() != null)
            hash.put("collapseId", notification.getCollapseId());
        hash.put("priority", notification.getPriority());
        if (notification.getAdditionalData() != null && notification.getAdditionalData().length() > 0)
            hash.put("additionalData", convertJSONObjectToHashMap(notification.getAdditionalData()));
        if (notification.getActionButtons() != null && !notification.getActionButtons().isEmpty()) {
            ArrayList<HashMap> buttons = new ArrayList<>();

            List<OSNotification.ActionButton> actionButtons = notification.getActionButtons();
            for (int i = 0; i < actionButtons.size(); i++) {
                OSNotification.ActionButton button = actionButtons.get(i);

                HashMap<String, Object> buttonHash = new HashMap<>();
                buttonHash.put("id", button.getId());
                buttonHash.put("text", button.getText());
                buttonHash.put("icon", button.getIcon());
                buttons.add(buttonHash);
            }

            hash.put("buttons", buttons);
        }

        if (notification.getBackgroundImageLayout() != null)
            hash.put("backgroundImageLayout", convertAndroidBackgroundImageLayoutToMap(notification.getBackgroundImageLayout()));

        hash.put("rawPayload", notification.getRawPayload());

        Log.d("onesignal", "Created json raw payload: " + hash.toString());

        return hash;
    }

    static HashMap<String, Object> convertNotificationOpenResultToMap(OSNotificationOpenedResult openResult) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("notification", convertNotificationToMap(openResult.getNotification()));
        hash.put("action", convertNotificationActionToMap(openResult.getAction()));

        return hash;
    }

    private static HashMap<String, Object> convertNotificationActionToMap(OSNotificationAction action) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("id", action.getActionId());

        switch (action.getType()) {
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

        hash.put("click_name", action.getClickName());
        hash.put("click_url", action.getClickUrl());
        hash.put("first_click", action.isFirstClick());
        hash.put("closes_message", action.doesCloseMessage());

        return hash;
    }

    public static HashMap<String, Object> convertNotificationReceivedEventToMap(OSNotificationReceivedEvent notificationReceivedEvent) throws JSONException {
        return convertNotificationToMap(notificationReceivedEvent.getNotification());
    }

    static HashMap<String, Object> convertOutcomeEventToMap(OSOutcomeEvent outcomeEvent) {
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

    private static HashMap<String, Object> convertAndroidBackgroundImageLayoutToMap(OSNotification.BackgroundImageLayout layout) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("image", layout.getImage());
        hash.put("bodyTextColor", layout.getBodyTextColor());
        hash.put("titleTextColor", layout.getTitleTextColor());

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
