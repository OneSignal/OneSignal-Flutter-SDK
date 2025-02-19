package com.onesignal.flutter;

import androidx.annotation.NonNull;

import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.OneSignal;

import com.onesignal.notifications.INotification;
import com.onesignal.notifications.INotificationClickEvent;
import com.onesignal.notifications.INotificationWillDisplayEvent;
import com.onesignal.notifications.INotificationClickListener;
import com.onesignal.notifications.INotificationLifecycleListener;
import com.onesignal.notifications.IPermissionObserver;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlinx.coroutines.Dispatchers;

public class OneSignalNotifications extends FlutterMessengerResponder implements MethodCallHandler, INotificationClickListener, INotificationLifecycleListener, IPermissionObserver {
    private final HashMap<String, INotificationWillDisplayEvent> notificationOnWillDisplayEventCache = new HashMap<>();
    private final HashMap<String, INotificationWillDisplayEvent> preventedDefaultCache = new HashMap<>();

    /**
     * A helper class to encapsulate invoking the suspending function [requestPermission] in Java.
     * To support API level < 24, the SDK cannot use the OneSignal-defined [Continue.with] helper method.
     */
    private class RequestPermissionContinuation implements Continuation<Boolean> {

        private final MethodChannel.Result result;

        public RequestPermissionContinuation(MethodChannel.Result result) {
            this.result = result;
        }

        @NonNull
        @Override
        public CoroutineContext getContext() {
            return (CoroutineContext) Dispatchers.getMain();
        }

        @Override
        public void resumeWith(@NonNull Object o) {
            if (o instanceof kotlin.Result.Failure) {
                Throwable e = ((kotlin.Result.Failure) o).exception;
                replyError(result, "OneSignal", "requestPermission failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
            }
            else {
                replySuccess(result, o);
            }
        }
    }

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
    else if (call.method.contentEquals("OneSignal#canRequest"))
        replySuccess(result, OneSignal.getNotifications().getCanRequestPermission());
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
    else if (call.method.contentEquals("OneSignal#proceedWithWillDisplay"))
        this.proceedWithWillDisplay(call, result);
    else if (call.method.contentEquals("OneSignal#addNativeClickListener"))
        this.registerClickListener();
    else
        replyNotImplemented(result);
    }

    private void requestPermission(MethodCall call, Result result) {
        boolean fallback = (boolean) call.argument("fallbackToSettings");
        // if permission already exists, return early as the method call will not resolve
        if (OneSignal.getNotifications().getPermission()) {
            replySuccess(result, true);
            return;
        }

        OneSignal.getNotifications().requestPermission(fallback, new RequestPermissionContinuation(result));
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

    /// Our bridge layer needs to preventDefault() so that the Flutter listener has time to preventDefault() before the notification is displayed
    /// This function is called after all of the flutter listeners have responded to the willDisplay event. 
    /// If any of them have called preventDefault() we will not call display(). Otherwise we will display.
    private void proceedWithWillDisplay(MethodCall call, Result result) {
        String notificationId = call.argument("notificationId");
        INotificationWillDisplayEvent event = notificationOnWillDisplayEventCache.get(notificationId);
        if (event == null) {
            Logging.error("Could not find onWillDisplayNotification event for notification with id: " + notificationId, null);
            return;
        }
        if (this.preventedDefaultCache.containsKey(notificationId)) {
            replySuccess(result, null);
            return;
        }
        event.getNotification().display();
        replySuccess(result, null);
    }

    private void displayNotification(MethodCall call, Result result) {
        String notificationId = call.argument("notificationId");
        INotificationWillDisplayEvent event = notificationOnWillDisplayEventCache.get(notificationId);
        if (event == null) {
            Logging.error("Could not find onWillDisplayNotification event for notification with id: " + notificationId, null);
            return;
        }
        event.getNotification().display();
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
        this.preventedDefaultCache.put(notificationId, event);
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
        INotification notification = event.getNotification();
        notificationOnWillDisplayEventCache.put(notification.getNotificationId(), event);
        /// Our bridge layer needs to preventDefault() so that the Flutter listener has time to preventDefault() before the notification is displayed
        event.preventDefault();
        try {
            invokeMethodOnUiThread("OneSignal#onWillDisplayNotification", OneSignalSerializer.convertNotificationWillDisplayEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error("Encountered an error attempting to convert INotificationWillDisplayEvent object to hash map:" + e.toString(), null);
        }
    }

    @Override
    public void onNotificationPermissionChange(boolean permission)  { 
        HashMap<String, Object> hash = new HashMap<>();
        hash.put("permission", permission);
        invokeMethodOnUiThread("OneSignal#onNotificationPermissionDidChange", hash);
    }

    private void lifecycleInit() {
        OneSignal.getNotifications().addForegroundLifecycleListener(this);
        OneSignal.getNotifications().addPermissionObserver(this);
    }

    private void registerClickListener() {
        OneSignal.getNotifications().addClickListener(this);
    }
} 