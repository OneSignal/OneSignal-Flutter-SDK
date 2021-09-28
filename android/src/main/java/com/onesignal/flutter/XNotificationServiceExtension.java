package com.onesignal.flutter;

import android.os.Looper;
import android.os.Handler;
import android.content.Context;
import android.util.Log;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import com.onesignal.flutter.OneSignalSerializer;
import com.onesignal.flutter.BackgroundExecutor;
import com.onesignal.flutter.IsolateStatusHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import com.onesignal.OSNotification;
import com.onesignal.OSMutableNotification;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler;

public class XNotificationServiceExtension implements OSRemoteNotificationReceivedHandler {

    private static final String TAG = "OneSignal - XNotificationServiceExtension";
    public static BackgroundExecutor be;
    public static HashMap<String, OSNotificationReceivedEvent> notificationReceivedEventCache = new HashMap<>();

    @Override
    public void remoteNotificationReceived(Context context, OSNotificationReceivedEvent notificationReceivedEvent) {
        OSNotification notification = notificationReceivedEvent.getNotification();
        XNotificationServiceExtension.notificationReceivedEventCache.put(notification.getNotificationId(), notificationReceivedEvent);
        JSONObject data = notification.getAdditionalData();
        Log.i(TAG, "Received Notification Data: " + data.toString());

        if (ContextHolder.getApplicationContext() == null) {
            ContextHolder.setApplicationContext(context.getApplicationContext());
        }
        if (XNotificationServiceExtension.be == null) {
            XNotificationServiceExtension.be = new BackgroundExecutor();
        }
        Log.i(TAG, "Checking isolated BackgroundExecutor.");
        try {
            HashMap<String, Object> receivedMap = OneSignalSerializer.convertNotificationReceivedEventToMap(notificationReceivedEvent);
            XNotificationServiceExtension.be.startBackgroundIsolate(new IsolateStatusHandler() {
                @Override
                public void done() {
                    if (XNotificationServiceExtension.be != null) {
                        Log.i(TAG, "Executing dart code in isolate.");
                        XNotificationServiceExtension.be.executeDartCallbackInBackgroundIsolate(receivedMap);
                    }
                }
            });
        } catch (Exception e) {
            Log.i(TAG, "Exception while executing dart code in isolate", e);
        }
    }
}