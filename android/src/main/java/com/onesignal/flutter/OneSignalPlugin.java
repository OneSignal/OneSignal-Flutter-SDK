package com.onesignal.flutter;

import android.content.Context;

import com.onesignal.OSEmailSubscriptionObserver;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSInAppMessageAction;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OSPermissionObserver;
import com.onesignal.OSPermissionStateChanges;
import com.onesignal.OSPermissionSubscriptionState;
import com.onesignal.OSSubscriptionObserver;
import com.onesignal.OSSubscriptionStateChanges;
import com.onesignal.OneSignal;
import com.onesignal.OneSignal.EmailUpdateError;
import com.onesignal.OneSignal.EmailUpdateHandler;
import com.onesignal.OneSignal.InAppMessageClickHandler;
import com.onesignal.OneSignal.NotificationOpenedHandler;
import com.onesignal.OneSignal.NotificationReceivedHandler;
import com.onesignal.OneSignal.OSInFocusDisplayOption;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collection;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

/** OnesignalPlugin */
public class OneSignalPlugin
   extends FlutterRegistrarResponder
   implements MethodCallHandler,
   NotificationReceivedHandler,
   NotificationOpenedHandler,
   InAppMessageClickHandler,
   OSSubscriptionObserver,
   OSEmailSubscriptionObserver,
   OSPermissionObserver {

  /** Plugin registration. */
  private OSNotificationOpenResult coldStartNotificationResult;
  private OSInAppMessageAction inAppMessageClickedResult;
  private boolean hasSetNotificationOpenedHandler = false;
  private boolean hasSetInAppMessageClickedHandler = false;
  private boolean hasSetRequiresPrivacyConsent = false;
  private boolean waitingForUserPrivacyConsent = false;

  public static void registerWith(Registrar registrar) {
    OneSignal.sdkType = "flutter";

    OneSignalPlugin plugin = new OneSignalPlugin();

    plugin.waitingForUserPrivacyConsent = false;
    plugin.channel = new MethodChannel(registrar.messenger(), "OneSignal");
    plugin.channel.setMethodCallHandler(plugin);
    plugin.flutterRegistrar = registrar;

    // Create a callback for the flutterRegistrar to connect the applications onDestroy
    plugin.flutterRegistrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
      @Override
      public boolean onViewDestroy(FlutterNativeView flutterNativeView) {
        // Remove all handlers so they aren't triggered with wrong context
        OneSignal.removeNotificationReceivedHandler();
        OneSignal.removeNotificationOpenedHandler();
        OneSignal.removeInAppMessageClickHandler();
        return false;
      }
    });

    OneSignalTagsController.registerWith(registrar);
    OneSignalInAppMessagingController.registerWith(registrar);
    OneSignalOutcomeEventsController.registerWith(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#init"))
      this.initOneSignal(call, result);
    else if (call.method.contentEquals("OneSignal#setLogLevel"))
      this.setLogLevel(call, result);
    else if (call.method.contentEquals("OneSignal#log"))
      this.oneSignalLog(call, result);
    else if (call.method.contentEquals("OneSignal#requiresUserPrivacyConsent"))
      replySuccess(result, OneSignal.requiresUserPrivacyConsent());
    else if (call.method.contentEquals("OneSignal#setRequiresUserPrivacyConsent"))
      this.setRequiresUserPrivacyConsent(call, result);
    else if (call.method.contentEquals("OneSignal#consentGranted"))
      this.consentGranted(call, result);
    else if (call.method.contentEquals("OneSignal#inFocusDisplayType"))
      replySuccess(result, inFocusDisplayOptionToInt(OneSignal.currentInFocusDisplayOption()));
    else if (call.method.contentEquals("OneSignal#setInFocusDisplayType"))
      this.setInFocusDisplayType(call, result);
    else if (call.method.contentEquals("OneSignal#promptPermission"))
      this.promptPermission(call, result);
    else if (call.method.contentEquals("OneSignal#getPermissionSubscriptionState"))
      this.getPermissionSubscriptionState(result);
    else if (call.method.contentEquals("OneSignal#setSubscription"))
      this.setSubscription(call, result);
    else if (call.method.contentEquals("OneSignal#postNotification"))
      this.postNotification(call, result);
    else if (call.method.contentEquals("OneSignal#promptLocation"))
      this.promptLocation(result);
    else if (call.method.contentEquals("OneSignal#setLocationShared"))
      this.setLocationShared(call, result);
    else if (call.method.contentEquals("OneSignal#setEmail"))
      this.setEmail(call, result);
    else if (call.method.contentEquals("OneSignal#logoutEmail"))
      this.logoutEmail(result);
    else if (call.method.contentEquals("OneSignal#setExternalUserId"))
      this.setExternalUserId(call, result);
    else if (call.method.contentEquals("OneSignal#removeExternalUserId"))
      this.removeExternalUserId(result);
    else if (call.method.contentEquals("OneSignal#initNotificationOpenedHandlerParams"))
      this.initNotificationOpenedHandlerParams();
    else if (call.method.contentEquals("OneSignal#initInAppMessageClickedHandlerParams"))
      this.initInAppMessageClickedHandlerParams();
    else
      replyNotImplemented(result);
  }

  private void setSubscription(MethodCall call, Result result) {
    OneSignal.setSubscription((boolean) call.arguments);
    replySuccess(result, null);
  }

  private void initOneSignal(MethodCall call, Result reply) {
    String appId = call.argument("appId");
    Context context = flutterRegistrar.activeContext();

    OneSignal.Builder builder = OneSignal.getCurrentOrNewInitBuilder();
    builder.unsubscribeWhenNotificationsAreDisabled(true);
    builder.filterOtherGCMReceivers(true);
    builder.setInAppMessageClickHandler(this);
    OneSignal.init(context, null, appId, this, this);

    if (hasSetRequiresPrivacyConsent)
      this.waitingForUserPrivacyConsent = true;
    else
      this.addObservers();

    replySuccess(reply, null);
  }

  private void addObservers() {
    OneSignal.addSubscriptionObserver(this);
    OneSignal.addEmailSubscriptionObserver(this);
    OneSignal.addPermissionObserver(this);
  }

  private void setLogLevel(MethodCall call, Result reply) {
    int console = call.argument("console");
    int visual = call.argument("visual");

    OneSignal.setLogLevel(console, visual);

    replySuccess(reply, null);
  }

  private void oneSignalLog(MethodCall call, Result reply) {
    int logLevel = call.argument("logLevel");
    String message = call.argument("message");

    OneSignal.onesignalLog(OneSignal.LOG_LEVEL.values()[logLevel], message);

    replySuccess(reply, null);
  }

  private void setRequiresUserPrivacyConsent(MethodCall call, Result reply) {
    boolean required = call.argument("required");
    hasSetRequiresPrivacyConsent = required;

    OneSignal.setRequiresUserPrivacyConsent(required);

    replySuccess(reply, null);
  }

  private void consentGranted(MethodCall call, Result reply) {
    boolean granted = call.argument("granted");
    OneSignal.provideUserConsent(granted);

    if (this.waitingForUserPrivacyConsent) {
      this.waitingForUserPrivacyConsent = false;

      this.addObservers();
    }

    replySuccess(reply, null);
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

  private void setInFocusDisplayType(MethodCall call, Result reply) {
    int displayType = call.argument("displayType");
    OneSignal.setInFocusDisplaying(displayType);
    replySuccess(reply, null);
  }

  private void promptPermission(MethodCall call, Result result) {
    OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "promptPermission() is not applicable in Android");
    replySuccess(result, null);
  }

  private void getPermissionSubscriptionState(Result reply) {
    OSPermissionSubscriptionState state = OneSignal.getPermissionSubscriptionState();
    replySuccess(reply, OneSignalSerializer.convertPermissionSubscriptionStateToMap(state));
  }

  private void postNotification(MethodCall call, final Result reply) {
    JSONObject json = new JSONObject((Map<String, Object>) call.arguments);
    OneSignal.postNotification(json, new OneSignal.PostNotificationResponseHandler() {
      @Override
      public void onSuccess(JSONObject response) {
        try {
          replySuccess(reply, OneSignalSerializer.convertJSONObjectToHashMap(response));
        } catch (JSONException e) {
          replyError(reply, "OneSignal", "Encountered an error attempting to deserialize server response: " + e.getMessage(), null);
        }
      }

      @Override
      public void onFailure(final JSONObject response) {
        try {
          replyError(reply, "OneSignal",
                  "Encountered an error attempting to post notification: " + response.toString(),
                  OneSignalSerializer.convertJSONObjectToHashMap(response));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response: " + e.getMessage());
        }
      }
    });
  }

  private void promptLocation(Result reply) {
    OneSignal.promptLocation();
    replySuccess(reply, null);
  }

  private void setLocationShared(MethodCall call, Result result) {
    OneSignal.setLocationShared((boolean) call.arguments);
    replySuccess(result, null);
  }

  private void setEmail(MethodCall call, final Result reply) {
    String email = call.argument("email");
    String emailAuthHashToken = call.argument("emailAuthHashToken");

    OneSignal.setEmail(email, emailAuthHashToken, new EmailUpdateHandler() {
      @Override
      public void onSuccess() {
        replySuccess(reply, null);
      }

      @Override
      public void onFailure(EmailUpdateError error) {
        replyError(reply, "OneSignal",
                "Encountered an error setting email: " + error.getMessage(),
                null);
      }
    });
  }

  private void logoutEmail(final Result reply) {
    OneSignal.logoutEmail(new EmailUpdateHandler() {
      @Override
      public void onSuccess() {
        replySuccess(reply, null);
      }

      @Override
      public void onFailure(EmailUpdateError error) {
        replyError(reply, "OneSignal",
                "Encountered an error loggoing out of email: " + error.getMessage(),
                null);
      }
    });
  }

  private void setExternalUserId(MethodCall call, final Result result) {
    String externalUserId = call.argument("externalUserId");
    String authHashToken = call.argument("authHashToken");
    if (externalUserId != null && externalUserId.length() == 0)
      externalUserId = null;
    if (authHashToken != null && authHashToken.length() == 0)
      authHashToken = null;

    OneSignal.setExternalUserId(externalUserId, authHashToken, new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
      @Override
      public void onComplete(JSONObject results) {
        try {
          replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for setExternalUserId: " + e.getMessage());
        }
      }
    });
  }

  private void removeExternalUserId(final Result result) {
    OneSignal.removeExternalUserId(new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
      @Override
      public void onComplete(JSONObject results) {
        try {
          replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for removeExternalUserId: " + e.getMessage());
        }
      }
    });
  }

  private void initNotificationOpenedHandlerParams() {
    this.hasSetNotificationOpenedHandler = true;
    if (this.coldStartNotificationResult != null) {
      this.notificationOpened(this.coldStartNotificationResult);
      this.coldStartNotificationResult = null;
    }
  }

  private void initInAppMessageClickedHandlerParams() {
    this.hasSetInAppMessageClickedHandler = true;
    if (this.inAppMessageClickedResult != null) {
      this.inAppMessageClicked(this.inAppMessageClickedResult);
      this.inAppMessageClickedResult = null;
    }
  }

  @Override
  public void onOSSubscriptionChanged(OSSubscriptionStateChanges stateChanges) {
    invokeMethodOnUiThread("OneSignal#subscriptionChanged", OneSignalSerializer.convertSubscriptionStateChangesToMap(stateChanges));
  }

  @Override
  public void onOSEmailSubscriptionChanged(OSEmailSubscriptionStateChanges stateChanges) {
    invokeMethodOnUiThread("OneSignal#emailSubscriptionChanged", OneSignalSerializer.convertEmailSubscriptionStateChangesToMap(stateChanges));
  }

  @Override
  public void onOSPermissionChanged(OSPermissionStateChanges stateChanges) {
    invokeMethodOnUiThread("OneSignal#permissionChanged", OneSignalSerializer.convertPermissionStateChangesToMap(stateChanges));
  }

  @Override
  public void notificationReceived(OSNotification notification) {
    try {
      invokeMethodOnUiThread("OneSignal#handleReceivedNotification", OneSignalSerializer.convertNotificationToMap(notification));
    } catch (JSONException e) {
      e.printStackTrace();
      OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
         "Encountered an error attempting to convert OSNotification object to hash map: " + e.getMessage());
    }
  }

  @Override
  public void notificationOpened(OSNotificationOpenResult result) {
    if (!this.hasSetNotificationOpenedHandler) {
      this.coldStartNotificationResult = result;
      return;
    }

    try {
      invokeMethodOnUiThread("OneSignal#handleOpenedNotification", OneSignalSerializer.convertNotificationOpenResultToMap(result));
    } catch (JSONException e) {
      e.getStackTrace();
      OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
              "Encountered an error attempting to convert OSNotificationOpenResult object to hash map: " + e.getMessage());
    }
  }

  @Override
  public void inAppMessageClicked(OSInAppMessageAction action) {
    if (!this.hasSetInAppMessageClickedHandler) {
      this.inAppMessageClickedResult = action;
      return;
    }

    invokeMethodOnUiThread("OneSignal#handleClickedInAppMessage", OneSignalSerializer.convertInAppMessageClickedActionToMap(action));
  }
}
