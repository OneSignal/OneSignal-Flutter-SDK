package com.onesignal.flutter;

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

public class OneSignalNotifications extends FlutterRegistrarResponder implements MethodCallHandler, INotificationClickHandler, INotificationWillShowInForegroundHandler, IPermissionChangedHandler {
    private MethodChannel channel;

    private boolean hasSetNotificationWillShowInForegroundHandler = false;
    private final HashMap<String, INotificationReceivedEvent> notificationReceivedEventCache = new HashMap<>();


    static void registerWith(BinaryMessenger messenger) {
        OneSignalNotifications controller = new OneSignalNotifications();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#notifications");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#getPermission"))
        replySuccess(result, OneSignal.getNotifications().getPermission());
    else if (call.method.contentEquals("OneSignal#requestPermission"))
        this.requestPermission(call, result);
    else if (call.method.contentEquals("OneSignal#removeNotification"))
        this.removeNotification(call, result);
    else if (call.method.contentEquals("OneSignal#removeGroupedNotifications"))
        this.removeGroupedNotifications(call, result);
    else if (call.method.contentEquals("OneSignal#clearAll"))
        this.clearAll(call, result);
    else if (call.method.contentEquals("OneSignal#initNotificationOpenedHandlerParams"))
        this.initNotificationOpenedHandlerParams();
    else if (call.method.contentEquals("OneSignal#initNotificationWillShowInForegroundHandlerParams"))
        this.initNotificationWillShowInForegroundHandlerParams();
    else if (call.method.contentEquals("OneSignal#completeNotification"))
        this.initNotificationWillShowInForegroundHandlerParams();
    else if (call.method.contentEquals("OneSignal#lifecycleInit"))
        this.lifecycleInit();
    else
        replyNotImplemented(result);
    }

    private void requestPermission(MethodCall call, Result result) {
        boolean fallback = (boolean) call.argument("fallbackToSettings");
        OneSignal.getNotifications().requestPermission(fallback, Continue.none());
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
    
    
    private void initNotificationOpenedHandlerParams() {
        OneSignal.getNotifications().setNotificationClickHandler(this);
    }


    private void initNotificationWillShowInForegroundHandlerParams() {
        this.hasSetNotificationWillShowInForegroundHandler = true;
    }

    private void completeNotification(MethodCall call, final Result reply) {
        String notificationId = call.argument("notificationId");
        boolean shouldDisplay = call.argument("shouldDisplay");
        INotificationReceivedEvent notificationReceivedEvent = notificationReceivedEventCache.get(notificationId);

        if (notificationReceivedEvent == null) {
            //OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Could not find notification completion block with id: " + notificationId);
            return;
        }

        if (shouldDisplay) {
            notificationReceivedEvent.complete(notificationReceivedEvent.getNotification());
        } else {
            notificationReceivedEvent.complete(null);
        }
    }

    @Override
    public void notificationClicked(INotificationClickResult result) {
        try {
            invokeMethodOnUiThread("OneSignal#handleOpenedNotification", OneSignalSerializer.convertNotificationClickedResultToMap(result));
        } catch (JSONException e) {
        e.getStackTrace();
        // OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
        //         "Encountered an error attempting to convert OSNotificationOpenResult object to hash map: " + e.getMessage());
        }
    }

    @Override
    public void notificationWillShowInForeground(INotificationReceivedEvent notificationReceivedEvent) {
        if (!this.hasSetNotificationWillShowInForegroundHandler) {
            notificationReceivedEvent.complete(notificationReceivedEvent.getNotification());
            return;
        }

        INotification notification = notificationReceivedEvent.getNotification();
        notificationReceivedEventCache.put(notification.getNotificationId(), notificationReceivedEvent);

        try {
            HashMap<String, Object>  receivedMap = OneSignalSerializer.convertNotificationToMap(notification);
            
            invokeMethodOnUiThread("OneSignal#handleNotificationWillShowInForeground", receivedMap);
        } catch (JSONException e) {
            e.getStackTrace();
            // OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
            //         "Encountered an error attempting to convert OSNotificationReceivedEvent object to hash map: " + e.getMessage());
        }
    }

    @Override
    public void onPermissionChanged(boolean permission)  { 

        invokeMethodOnUiThread("OneSignal#OSPermissionChanged", OneSignalSerializer.convertPermissionChanged(permission));
    }

    public void lifecycleInit() {
        OneSignal.getNotifications().setNotificationWillShowInForegroundHandler(this);
        OneSignal.getNotifications().addPermissionChangedHandler(this);
    }

    
} 