package com.onesignal.flutter;

import com.onesignal.flutter.OneSignalPlugin;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.content.Context;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OneSignal;

/**
 * Created by bradhesse on 7/16/18.
 */

public class NotificationEventHandler implements OneSignal.NotificationReceivedHandler, OneSignal.NotificationOpenedHandler {
    private Context appContext;

    public NotificationEventHandler(Context context) {
        this.appContext = context;
    }

    @Override
    public void notificationReceived(OSNotification notification) {

    }

    @Override
    public void notificationOpened(OSNotificationOpenResult result) {

    }

    private void handleNotificationEvent(String event, JSONObject object, String intentFilter) {
        Bundle bundle = new Bundle();
        bundle.putString(event, object.toString());

        final Intent intent = new Intent(intentFilter);
        intent.putExtras(bundle);

    }
}
