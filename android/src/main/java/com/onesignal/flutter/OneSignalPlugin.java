package com.onesignal.flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.onesignal.OSEmailSubscriptionObserver;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OSPermissionObserver;
import com.onesignal.OSPermissionStateChanges;
import com.onesignal.OSPermissionSubscriptionState;
import com.onesignal.OSSubscriptionObserver;
import com.onesignal.OSSubscriptionStateChanges;
import com.onesignal.OneSignal;
import com.onesignal.OneSignal.OSInFocusDisplayOption;
import com.onesignal.OneSignal.NotificationOpenedHandler;
import com.onesignal.OneSignal.NotificationReceivedHandler;
import com.onesignal.OneSignal.EmailUpdateHandler;
import com.onesignal.OneSignal.EmailUpdateError;

import org.json.JSONObject;
import org.json.JSONException;

import java.util.Map;
import android.content.Context;
import android.util.Log;

/** OnesignalPlugin */
public class OneSignalPlugin implements MethodCallHandler, NotificationReceivedHandler, NotificationOpenedHandler, OSSubscriptionObserver, OSEmailSubscriptionObserver, OSPermissionObserver {

  /** Plugin registration. */
  private Registrar flutterRegistrar;
  private MethodChannel channel;
  private boolean didSetRequiresPrivacyConsent = false;
  private boolean waitingForUserPrivacyConsent = false;
  private OSNotificationOpenResult coldStartNotificationResult;
  private boolean setNotificationOpenedHandler = false;

  public static void registerWith(Registrar registrar) {

    OneSignal.sdkType = "flutter";

    OneSignalPlugin plugin = new OneSignalPlugin();

    plugin.waitingForUserPrivacyConsent = false;

    plugin.channel = new MethodChannel(registrar.messenger(), "OneSignal");

    plugin.channel.setMethodCallHandler(plugin);

    plugin.flutterRegistrar = registrar;

    OneSignalTagsController.registerWith(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#init")) {
      initOneSignal(call, result);
    } else if (call.method.contentEquals("OneSignal#setLogLevel")) {
      this.setLogLevel(call, result);
    } else if (call.method.contentEquals("OneSignal#requiresUserPrivacyConsent")) {
      result.success(OneSignal.requiresUserPrivacyConsent());
    } else if (call.method.contentEquals("OneSignal#consentGranted")) {
      this.consentGranted(call, result);
    } else if (call.method.contentEquals("OneSignal#setRequiresUserPrivacyConsent")) {
      this.setRequiresUserPrivacyConsent(call, result);
    } else if (call.method.contentEquals("OneSignal#log")) {
      this.oneSignalLog(call, result);
    } else if (call.method.contentEquals("OneSignal#inFocusDisplayType")) {
      result.success(inFocusDisplayOptionToInt(OneSignal.currentInFocusDisplayOption()));
    } else if (call.method.contentEquals("OneSignal#getPermissionSubscriptionState")) {
      this.getPermissionSubscriptionState(result);
    } else if (call.method.contentEquals("OneSignal#setInFocusDisplayType")) {
      this.setInFocusDisplayType(call, result);
    } else if (call.method.contentEquals("OneSignal#setSubscription")) {
      OneSignal.setSubscription((boolean)call.arguments);
    } else if (call.method.contentEquals("OneSignal#postNotification")) {
      this.postNotification(call, result);
    } else if (call.method.contentEquals("OneSignal#promptLocation")) {
      this.promptLocation(result);
    } else if (call.method.contentEquals("OneSignal#setLocationShared")) {
      OneSignal.setLocationShared((boolean)call.arguments);
    } else if (call.method.contentEquals("OneSignal#setEmail")) {
      this.setEmail(call, result);
    } else if (call.method.contentEquals("OneSignal#logoutEmail")) {
      this.logoutEmail(call, result);
    } else if (call.method.contentEquals("OneSignal#promptPermission")) {
      Log.e("onesignal", "promptPermission() is not applicable in Android.");
    } else if (call.method.contentEquals("OneSignal#didSetNotificationOpenedHandler")) {
      this.didSetNotificationOpenedHandler();
    } else {
      result.notImplemented();
    }
  }

  public void initOneSignal(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;
    Context context = flutterRegistrar.context();

    OneSignal.Builder builder = OneSignal.getCurrentOrNewInitBuilder();
    builder.unsubscribeWhenNotificationsAreDisabled(true);
    builder.filterOtherGCMReceivers(true);
    OneSignal.init(context, null, (String)args.get("appId"), this, this);

    if (didSetRequiresPrivacyConsent) {
      this.waitingForUserPrivacyConsent = true;
    } else {
      this.addObservers();
    }

    result.success(null);
  }

  public void addObservers() {
    OneSignal.addSubscriptionObserver(this);
    OneSignal.addEmailSubscriptionObserver(this);
    OneSignal.addPermissionObserver(this);
  }

  public void setLogLevel(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;

    OneSignal.setLogLevel((int)args.get("console"), (int)args.get("visual"));

    result.success(null);
  }

  public void consentGranted(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;

    OneSignal.provideUserConsent((Boolean)args.get("granted"));

    result.success(null);

    if (this.waitingForUserPrivacyConsent) {
      this.waitingForUserPrivacyConsent = false;

      this.addObservers();
    }
  }

  public void setRequiresUserPrivacyConsent(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;
    
    boolean required = (boolean)args.get("required");

    didSetRequiresPrivacyConsent = required;

    OneSignal.setRequiresUserPrivacyConsent(required);

    result.success(null);
  }

  public void oneSignalLog(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;
    OneSignal.onesignalLog(OneSignal.LOG_LEVEL.values()[(int)args.get("logLevel")], (String)args.get("message"));
  }

  public void getPermissionSubscriptionState(Result result) {
    OSPermissionSubscriptionState state = OneSignal.getPermissionSubscriptionState();

    result.success(OneSignalSerializer.convertPermissionSubscriptionStateToMap(state));
  }

  public void setInFocusDisplayType(MethodCall call, Result result) {
    Map<String, Object> args = (Map<String, Object>)call.arguments;
    OneSignal.setInFocusDisplaying((int)args.get("displayType"));
    result.success(null);
  }

  public void postNotification(MethodCall call, Result result) {
    JSONObject json = new JSONObject((Map<String, Object>)call.arguments);
    final Result reply = result;
    OneSignal.postNotification(json, new OneSignal.PostNotificationResponseHandler() {
      @Override
      public void onFailure(JSONObject response) {
        reply.error("onesignal", "Encountered an error attempting to post notification: " + response.toString(), response);
      }

      @Override
      public void onSuccess(JSONObject response) {
        try {
          reply.success(OneSignalSerializer.convertJSONObjectToHashMap(response));
        } catch (JSONException exception) {
          Log.e("onesignal", "Encountered an error attempting to deserialize server response: " + exception.getMessage());
        }
      }
    });
  }

  public void promptLocation(Result result) {
    OneSignal.promptLocation();
    result.success(null);
  }

  public void setEmail(MethodCall call, Result result) {
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
  }

  public void logoutEmail(MethodCall call, Result result) {
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
  }

  private int inFocusDisplayOptionToInt(OSInFocusDisplayOption option) {
    switch (option) {
      case None:
        return 0;
      case InAppAlert:
        return 1;
      case Notification:
        return 2;
    }

    return 1;
  }

  public void didSetNotificationOpenedHandler() {
    this.setNotificationOpenedHandler = true;
    if (this.coldStartNotificationResult != null) {
      this.notificationOpened(this.coldStartNotificationResult);
      this.coldStartNotificationResult = null;
    }
  }

  @Override
  public void onOSSubscriptionChanged(OSSubscriptionStateChanges stateChanges) {
    Log.d("onesignal", "Subscription changed calling observer");
    this.channel.invokeMethod("OneSignal#subscriptionChanged", OneSignalSerializer.convertSubscriptionStateChangesToMap(stateChanges));
  }

  @Override
  public void onOSEmailSubscriptionChanged(OSEmailSubscriptionStateChanges stateChanges) {
    this.channel.invokeMethod("OneSignal#emailSubscriptionChanged", OneSignalSerializer.convertEmailSubscriptionStateChangesToMap(stateChanges));
  }

  @Override
  public void onOSPermissionChanged(OSPermissionStateChanges stateChanges) {
    this.channel.invokeMethod("OneSignal#permissionChanged", OneSignalSerializer.convertPermissionStateChangesToMap(stateChanges));
  }

  @Override
  public void notificationReceived(OSNotification notification) {
    try {
      this.channel.invokeMethod("OneSignal#handleReceivedNotification", OneSignalSerializer.convertNotificationToMap(notification));
    } catch (JSONException exception) {
      Log.e("onesignal", "Encountered an error attempting to convert OSNotification object to hash map: " + exception.getMessage() + "\n" + exception.getStackTrace());
    }
  }

  @Override
  public void notificationOpened(OSNotificationOpenResult result) {
    if (!this.setNotificationOpenedHandler) {
      this.coldStartNotificationResult = result;
      return;
    }

    Log.d("onesignal", "OS Notification Opened");
    try {
      this.channel.invokeMethod("OneSignal#handleOpenedNotification", OneSignalSerializer.convertNotificationOpenResultToMap(result));
    } catch (JSONException exception) {
      Log.e("onesignal", "Encountered an error attempting to convert OSNotificationOpenResult object to hash map: " + exception.getMessage() + "\n" + exception.getStackTrace());
    }
  }
}
