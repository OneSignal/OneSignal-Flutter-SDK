package com.onesignal.onesignal;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.onesignal.OSEmailSubscriptionObserver;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OSPermissionObserver;
import com.onesignal.OSPermissionState;
import com.onesignal.OSPermissionStateChanges;
import com.onesignal.OSPermissionSubscriptionState;
import com.onesignal.OSSubscriptionObserver;
import com.onesignal.OSSubscriptionState;
import com.onesignal.OSEmailSubscriptionState;
import com.onesignal.OSSubscriptionStateChanges;
import com.onesignal.OneSignal;
import com.onesignal.OneSignal.NotificationOpenedHandler;
import com.onesignal.OneSignal.NotificationReceivedHandler;
import com.onesignal.OneSignal.EmailUpdateHandler;
import com.onesignal.OneSignal.EmailUpdateError;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

/**
 * Created by bradhesse on 7/17/18.
 */

public class OneSignalTagsController implements MethodCallHandler {
    private MethodChannel channel;

    public static void registerWith(Registrar registrar) {
        OneSignalTagsController controller = new OneSignalTagsController();

        controller.channel = new MethodChannel(registrar.messenger(), "OneSignal#tags");

        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#getTags")) {
            final Result reply = result;
            OneSignal.getTags(new OneSignal.GetTagsHandler() {
                @Override
                public void tagsAvailable(JSONObject tags) {
                    try {
                        reply.success(OneSignalSerializer.convertJSONObjectToHashMap(tags));
                    } catch (JSONException exception) {
                        reply.error("onesignal", "Encountered an error serializing tags into hashmap: " + exception.getMessage() + "\n" + exception.getStackTrace(), null);
                    }
                }
            });
        } else if (call.method.contentEquals("OneSignal#sendTags")) {
            Map<String, Object> args = (Map<String, Object>)call.arguments;
            OneSignal.sendTags(new JSONObject(args));
        } else if (call.method.contentEquals("OneSignal#deleteTags")) {
            OneSignal.deleteTags((List<String>)call.arguments);
        }
    }
}
