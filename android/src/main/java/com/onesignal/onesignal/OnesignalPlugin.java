package com.onesignal.onesignal;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OSPermissionState;
import com.onesignal.OSPermissionSubscriptionState;
import com.onesignal.OSSubscriptionState;
import com.onesignal.OSEmailSubscriptionState;
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

/** OnesignalPlugin */
public class OneSignalPlugin implements MethodCallHandler {
  public static final String NOTIFICATION_OPENED_INTENT_FILTER = "GTNotificationOpened";
  public static final String NOTIFICATION_RECEIVED_INTENT_FILTER = "GTNotificationReceived";
  public static final String HIDDEN_MESSAGE_KEY = "hidden";

  /** Plugin registration. */
  private Registrar flutterRegistrar;
  private MethodChannel channel;

  public static void registerWith(Registrar registrar) {

    OneSignalPlugin plugin = new OneSignalPlugin();

    plugin.channel = new MethodChannel(registrar.messenger(), "OneSignal");

    plugin.channel.setMethodCallHandler(plugin);

    plugin.flutterRegistrar = registrar;

    OneSignal.setLogLevel(OneSignal.LOG_LEVEL.VERBOSE, OneSignal.LOG_LEVEL.NONE);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#init")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;
      Context context = flutterRegistrar.context();
      OneSignal.init(context, null, (String)args.get("appId"),
              new NotificationOpenedHandler() {
                @Override
                public void notificationOpened(OSNotificationOpenResult result) {
                  
                }
              },
              new NotificationReceivedHandler() {
                @Override
                public void notificationReceived(OSNotification notification) {

                }
              });
    } else if (call.method.contentEquals("OneSignal#setLogLevel")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;

      int console = (int)args.get("console");
      int visual = (int)args.get("visual");

      OneSignal.setLogLevel(console, visual);

      result.success(null);
    } else if (call.method.contentEquals("OneSignal#requiresUserPrivacyConsent")) {
      result.success(!OneSignal.userProvidedPrivacyConsent());
    } else if (call.method.contentEquals("OneSignal#consentGranted")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;

      OneSignal.provideUserConsent((Boolean)args.get("granted"));

      result.success(null);
    } else if (call.method.contentEquals("OneSignal#setRequiresUserPrivacyConsent")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;

      OneSignal.setRequiresUserPrivacyConsent((Boolean)args.get("granted"));

      result.success(null);
    } else if (call.method.contentEquals("OneSignal#log")) {
      //TODO: Implement
    } else if (call.method.contentEquals("OneSignal#inFocusDisplayType")) {
      //TODO: Implement
    } else if (call.method.contentEquals("OneSignal#getPermissionSubscriptionState")) {
      OSPermissionSubscriptionState state = OneSignal.getPermissionSubscriptionState();

      result.success(OneSignalSerializer.permissionSubscriptionStateToMap(state));
    } else if (call.method.contentEquals("OneSignal#setInFocusDisplayType")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;
      OneSignal.setInFocusDisplaying((int)args.get("displayType"));
    } else if (call.method.contentEquals("OneSignal#setSubscription")) {
      OneSignal.setSubscription((boolean)call.arguments);
    } else if (call.method.contentEquals("OneSignal#postNotification")) {
      JSONObject json = new JSONObject((Map<String, Object>)call.arguments);
      final Result reply = result;
      OneSignal.postNotification(json, new OneSignal.PostNotificationResponseHandler() {
        @Override
        public void onFailure(JSONObject response) {
          reply.error("onesignal", "Encountered an error attempting to post notification: " + response.toString(), response);
        }

        @Override
        public void onSuccess(JSONObject response) {
          reply.success(response);
        }
      });
    } else if (call.method.contentEquals("OneSignal#promptLocation")) {
      OneSignal.promptLocation();
      result.success(null);
    } else if (call.method.contentEquals("OneSignal#setLocationShared")) {
      boolean shared = (boolean)call.arguments;
      OneSignal.setLocationShared(shared);
    } else if (call.method.contentEquals("OneSignal#setEmail")) {
      Map<String, Object> args = (Map<String, Object>)call.arguments;
      final Result reply = result;

      OneSignal.setEmail((String) args.get("email"), (String) args.get("emailAuthHashToken"), new EmailUpdateHandler() {
        @Override
        public void onSuccess() {
          reply.success(null);
        }

        @Override
        public void onFailure(EmailUpdateError error) {
          reply.error("onesignal", "Encountered an error setting email: " + error.getMessage(), null);
        }
      });
    } else if (call.method.contentEquals("OneSignal#logoutEmail")) {
      final Result reply = result;

      OneSignal.logoutEmail(new EmailUpdateHandler() {
        @Override
        public void onSuccess() {
          reply.success(null);
        }

        @Override
        public void onFailure(EmailUpdateError error) {
          reply.error("onesignal", "Encountered an error loggoing out of email: " + error.getMessage(), null);
        }
      });
    } else {
      result.notImplemented();
    }
  }

  void initOneSignal(String appId) {
    
  }
}
