package com.onesignal.onesignalexample

import android.content.Context
import android.util.Log
import org.json.JSONObject

import com.onesignal.onesignalexample.MainActivity
import com.onesignal.flutter.OneSignalSerializer
import io.flutter.plugin.common.MethodChannel
import com.onesignal.OSNotification
import com.onesignal.OSMutableNotification
import com.onesignal.OSNotificationReceivedEvent
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler

class NotificationServiceExtension : OSRemoteNotificationReceivedHandler {
    override fun remoteNotificationReceived(
        context: Context,
        notificationReceivedEvent: OSNotificationReceivedEvent
    ) {
        val notification = notificationReceivedEvent.notification

        // Example of modifying the notification's accent color
        val mutableNotification = notification.mutableCopy()
        // mutableNotification.setExtender(builder -> builder.setColor(context.getResources().getColor(R.color.colorPrimary)));
        val data = notification.additionalData
        Log.i("OneSignalExample", "Received Notification Data: $data")

        var receivedMap = OneSignalSerializer.convertNotificationReceivedEventToMap(notificationReceivedEvent);
        
        MainActivity.flutterEngineInstance?.let {
            MethodChannel(
                it.dartExecutor.binaryMessenger, 
                "com.onesignal.flutter.OneSignalPlugin"
            ).invokeMethod("OneSignal#handleNotificationWillShowInForeground", receivedMap);
        }

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()
        notificationReceivedEvent.complete(null);
    }
}