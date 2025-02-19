package com.onesignal.flutter;

import com.onesignal.user.state.UserChangedState;
import com.onesignal.user.state.UserState;
import com.onesignal.user.subscriptions.PushSubscriptionChangedState;
import com.onesignal.user.subscriptions.PushSubscriptionState;
import com.onesignal.inAppMessages.IInAppMessage;
import com.onesignal.inAppMessages.IInAppMessageClickResult;
import com.onesignal.inAppMessages.IInAppMessageClickEvent;
import com.onesignal.inAppMessages.IInAppMessageWillDisplayEvent;
import com.onesignal.inAppMessages.IInAppMessageDidDisplayEvent;
import com.onesignal.inAppMessages.IInAppMessageWillDismissEvent;
import com.onesignal.inAppMessages.IInAppMessageDidDismissEvent;
import com.onesignal.notifications.INotification;
import com.onesignal.notifications.IActionButton;
import com.onesignal.notifications.INotificationWillDisplayEvent;
import com.onesignal.notifications.INotificationClickResult;
import com.onesignal.notifications.INotificationClickEvent;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

class OneSignalSerializer {

    static HashMap<String, Object> convertNotificationToMap(INotification notification) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        
        hash.put("androidNotificationId", notification.getAndroidNotificationId());

        if (notification.getGroupedNotifications() != null) {
            hash.put("groupKey", notification.getGroupKey());
            hash.put("groupMessage", notification.getGroupMessage());
            hash.put("groupedNotifications", notification.getGroupedNotifications());
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
        if (notification.getActionButtons() != null) {
            hash.put("buttons", convertActionButtonsToMap
            (notification.getActionButtons()));
        }
        hash.put("rawPayload", notification.getRawPayload());
        return hash;
    }

    static List<HashMap<String, Object>> convertActionButtonsToMap(List<IActionButton> actionButtons) {
        List<HashMap<String, Object>> convertedList = new ArrayList<HashMap<String, Object>>();
        for (IActionButton actionButton : actionButtons) {
            HashMap<String, Object> hash = new HashMap<>();
            hash.put("id", actionButton.getId());
            hash.put("text", actionButton.getText());
            hash.put("icon", actionButton.getIcon());
            convertedList.add(hash);
        }
        return convertedList;
    }

    static HashMap<String, Object> convertNotificationWillDisplayEventToMap(INotificationWillDisplayEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();
        hash.put("notification", convertNotificationToMap(event.getNotification()));  
        return hash;
    }

    private static HashMap<String, Object> convertNotificationClickResultToMap(INotificationClickResult result) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("action_id", result.getActionId());
        hash.put("url", result.getUrl());

        return hash;
    }

    static HashMap<String, Object> convertNotificationClickEventToMap(INotificationClickEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("notification", convertNotificationToMap(event.getNotification()));
        hash.put("result", convertNotificationClickResultToMap(event.getResult()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageClickEventToMap(IInAppMessageClickEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message", convertInAppMessageToMap(event.getMessage()));
        hash.put("result", convertInAppMessageClickResultToMap(event.getResult()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageClickResultToMap(IInAppMessageClickResult result) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("action_id", result.getActionId());
        hash.put("url", result.getUrl());
        hash.put("closing_message", result.getClosingMessage());

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageWillDisplayEventToMap(IInAppMessageWillDisplayEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message", convertInAppMessageToMap(event.getMessage()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageDidDisplayEventToMap(IInAppMessageDidDisplayEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message", convertInAppMessageToMap(event.getMessage()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageWillDismissEventToMap(IInAppMessageWillDismissEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message", convertInAppMessageToMap(event.getMessage()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageDidDismissEventToMap(IInAppMessageDidDismissEvent event) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message", convertInAppMessageToMap(event.getMessage()));

        return hash;
    }

    static HashMap<String, Object> convertInAppMessageToMap(IInAppMessage message) {
        HashMap<String, Object> hash = new HashMap<>();

        hash.put("message_id", message.getMessageId());

        return hash;
    }

    static HashMap<String, Object> convertPushSubscriptionState(PushSubscriptionState state) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();
        

        hash.put("token", state.getToken());
        hash.put("id", state.getId());
        hash.put("optedIn", state.getOptedIn());

        return hash;
    }

    static HashMap<String, Object> convertUserState(UserState state) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();
    
        String onesignalId = setNullIfEmpty(state.getOnesignalId());
        String externalId = setNullIfEmpty(state.getExternalId());
    
        hash.put("onesignalId", onesignalId);
        hash.put("externalId", externalId);
    
        return hash;
    }

    static HashMap<String, Object> convertOnPushSubscriptionChange(PushSubscriptionChangedState changedState) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();
        

        hash.put("current", convertPushSubscriptionState(changedState.getCurrent()));
        hash.put("previous", convertPushSubscriptionState(changedState.getPrevious()));

        return hash;
    }

    static HashMap<String, Object> convertOnUserStateChange(UserChangedState changedState) throws JSONException {
        HashMap<String, Object> hash = new HashMap<>();

        
        hash.put("current", convertUserState(changedState.getCurrent()));
    
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

    /** Helper method to return null value if string is empty **/
    static String setNullIfEmpty(String value) {
        return value.isEmpty() ? null : value;
    }
}
