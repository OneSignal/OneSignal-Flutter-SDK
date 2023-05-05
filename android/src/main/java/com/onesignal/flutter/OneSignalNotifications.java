package com.onesignal.flutter;

import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.OneSignal;
import com.onesignal.Continue;

import com.onesignal.notifications.INotification;
import com.onesignal.notifications.INotificationClickHandler;
import com.onesignal.notifications.INotificationClickResult;
import com.onesignal.notifications.INotificationReceivedEvent;
import com.onesignal.notifications.IRemoteNotificationReceivedHandler;

import com.onesignal.notifications.INotificationWillShowInForegroundHandler;
import com.onesignal.notifications.INotificationReceivedEvent;
import com.onesignal.notifications.IRemoteNotificationReceivedHandler;

import com.onesignal.user.subscriptions.ISubscription;
import com.onesignal.user.subscriptions.IPushSubscription;
import com.onesignal.notifications.IPermissionChangedHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class OneSignalNotifications extends FlutterRegistrarResponder implements MethodCallHandler, INotificationClickListener, INotificationLifecycleListener, IPermissionObserver {
    private final HashMap<String, INotificationReceivedEvent> notificationOnWillDisplayEventCache = new HashMap<>();

    static void registerWith(BinaryMessenger messenger) {
        OneSignalNotifications controller = new OneSignalNotifications();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#notifications");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#permission"))
        replySuccess(result, OneSignal.getNotifications().getPermission());
    else if (call.method.contentEquals("OneSignal#requestPermission"))
        this.requestPermission(call, result);
    else if (call.method.contentEquals("OneSignal#removeNotification"))
        this.removeNotification(call, result);
    else if (call.method.contentEquals("OneSignal#removeGroupedNotifications"))
        this.removeGroupedNotifications(call, result);
    else if (call.method.contentEquals("OneSignal#clearAll"))
        this.clearAll(call, result);
    else if (call.method.contentEquals("OneSignal#displayNotification"))
        this.displayNotification(call, result);
    else if (call.method.contentEquals("OneSignal#preventDefault"))
        this.preventDefault(call, result);
    else if (call.method.contentEquals("OneSignal#lifecycleInit"))
        this.lifecycleInit();
    else
        replyNotImplemented(result);
    }

    private void requestPermission(MethodCall call, Result result) {
        boolean fallback = (boolean) call.argument("fallbackToSettings");
        OneSignal.getNotifications().requestPermission(fallback, Continue.none());
        replySuccess(result, null);
    }

    private void removeNotification(MethodCall call, Result result) {
        int notificationId = call.argument("notificationId");
        OneSignal.getNotifications().removeNotification(notificationId);
    
        replySuccess(result, null);
    }

    private void removeGroupedNotifications(MethodCall call, Result result) {
        String notificationGroup = call.argument("notificationGroup");
        OneSignal.getNotifications().removeGroupedNotifications(notificationGroup);
    
        replySuccess(result, null);
    }

    private void clearAll(MethodCall call, Result result) {
        OneSignal.getNotifications().clearAllNotifications();
        replySuccess(result, null);
    }

    private void displayNotification(MethodCall call, Result result) {
        String notificationId = call.argument("notificationId");
        INotificationWillDisplayEvent event = notificationOnWillDisplayEventCache.get(notificationId);
        if (event == null) {
            Logging.error("Could not find onWillDisplayNotification event for notification with id: " + notificationId, null);
            return;
        }
        event.notification.display();
        replySuccess(result, null);
    }

    private void preventDefault(MethodCall call, Result result) {
        String notificationId = call.argument("notificationId");
        INotificationWillDisplayEvent event = notificationOnWillDisplayEventCache.get(notificationId);
        if (event == null) {
            Logging.error("Could not find onWillDisplayNotification event for notification with id: " + notificationId, null);
            return;
        }
        event.preventDefault();
        replySuccess(result, null);
    }

    @Override
    public void onClick(INotificationClickEvent event) {
        try {
            invokeMethodOnUiThread("OneSignal#onClickNotification", OneSignalSerializer.convertNotificationClickEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error("Encountered an error attempting to convert INotificationClickEvent object to hash map:" + e.toString(), null);
        }
    }

    private JSONObject getJsonFromMap(Map<String, Object> map) throws JSONException {
        JSONObject jsonData = new JSONObject();
        for (String key : map.keySet()) {
            Object value = map.get(key);
            if (value instanceof Map<?, ?>) {
                value = getJsonFromMap((Map<String, Object>) value);
            }
            jsonData.put(key, value);
        }
        return jsonData;
    }

    @Override
    public void onWillDisplay(INotificationWillDisplayEvent event) {
        INotification notification = notificationReceivedEvent.getNotification();
        notificationLifecycleEventCache.put(notification.getNotificationId(), event);
        try {
            invokeMethodOnUiThread("OneSignal#onWillDisplayNotification", OneSignalSerializer.convertNotificationWillDisplayEventToMap(result));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error("Encountered an error attempting to convert INotificationWillDisplayEvent object to hash map:" + e.toString(), null);
        }
    }

    @Override
    public void onNotificationPermissionChange(boolean permission)  { 
        invokeMethodOnUiThread("OneSignal#onNotificationPermissionDidChange", permission);
    }

    private void lifecycleInit() {
        OneSignal.getNotifications().addLifecycleListener(this);
        OneSignal.getNotification().addClickListener(this);
        OneSignal.getNotifications().addPermissionChangedHandler(this);
    }
} 