package com.onesignal.flutter;

import android.content.Context;

import com.onesignal.OSDeviceState;
import com.onesignal.OSEmailSubscriptionObserver;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSInAppMessageAction;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenedResult;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OSPermissionObserver;
import com.onesignal.OSPermissionStateChanges;
import com.onesignal.OSSMSSubscriptionObserver;
import com.onesignal.OSSMSSubscriptionStateChanges;
import com.onesignal.OSSubscriptionObserver;
import com.onesignal.OSSubscriptionStateChanges;
import com.onesignal.OneSignal;
import com.onesignal.OneSignal.EmailUpdateError;
import com.onesignal.OneSignal.EmailUpdateHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
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
        OneSignal.OSNotificationOpenedHandler,
        OneSignal.OSInAppMessageClickHandler,
        OSSubscriptionObserver,
        OSEmailSubscriptionObserver,
        OSSMSSubscriptionObserver,
        OSPermissionObserver,
        OneSignal.OSNotificationWillShowInForegroundHandler {

  /** Plugin registration. */
  private OSInAppMessageAction inAppMessageClickedResult;
  private boolean hasSetInAppMessageClickedHandler = false;
  private boolean hasSetNotificationWillShowInForegroundHandler = false;
  private boolean hasSetRequiresPrivacyConsent = false;
  private boolean waitingForUserPrivacyConsent = false;

  private HashMap<String, OSNotificationReceivedEvent> notificationReceivedEventCache = new HashMap<>();

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
        OneSignal.setNotificationOpenedHandler(null);
        OneSignal.setInAppMessageClickHandler(null);
        return false;
      }
    });

    OneSignalTagsController.registerWith(registrar);
    OneSignalInAppMessagingController.registerWith(registrar);
    OneSignalOutcomeEventsController.registerWith(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.contentEquals("OneSignal#setAppId"))
      this.setAppId(call, result);
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
    else if (call.method.contentEquals("OneSignal#userProvidedPrivacyConsent"))
      this.userProvidedPrivacyConsent(call, result);
    else if (call.method.contentEquals("OneSignal#promptPermission"))
      this.promptPermission(call, result);
    else if (call.method.contentEquals("OneSignal#getDeviceState"))
      this.getDeviceState(result);
    else if (call.method.contentEquals("OneSignal#disablePush"))
      this.disablePush(call, result);
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
    else if (call.method.contentEquals("OneSignal#setSMSNumber"))
      this.setSMSNumber(call, result);
    else if (call.method.contentEquals("OneSignal#logoutSMSNumber"))
      this.logoutSMSNumber(result);
    else if (call.method.contentEquals("OneSignal#setExternalUserId"))
      this.setExternalUserId(call, result);
    else if (call.method.contentEquals("OneSignal#removeExternalUserId"))
      this.removeExternalUserId(result);
    else if (call.method.contentEquals("OneSignal#initNotificationOpenedHandlerParams"))
      this.initNotificationOpenedHandlerParams();
    else if (call.method.contentEquals("OneSignal#initInAppMessageClickedHandlerParams"))
      this.initInAppMessageClickedHandlerParams();
    else if (call.method.contentEquals("OneSignal#initNotificationWillShowInForegroundHandlerParams"))
      this.initNotificationWillShowInForegroundHandlerParams();
    else if (call.method.contentEquals("OneSignal#completeNotification"))
      this.completeNotification(call, result);
    else if (call.method.contentEquals("OneSignal#clearOneSignalNotifications"))
      this.clearOneSignalNotifications(call, result);
    else if (call.method.contentEquals("OneSignal#removeNotification"))
      this.removeNotification(call, result);
    else
      replyNotImplemented(result);
  }

  private void disablePush(MethodCall call, Result result) {
    OneSignal.disablePush((boolean) call.arguments);
    replySuccess(result, null);
  }

  private void setAppId(MethodCall call, Result reply) {
    String appId = call.argument("appId");
    Context context = flutterRegistrar.activeContext();

    OneSignal.setInAppMessageClickHandler(this);
    OneSignal.initWithContext(context);
    OneSignal.setAppId(appId);

    if (hasSetRequiresPrivacyConsent && !OneSignal.userProvidedPrivacyConsent())
      this.waitingForUserPrivacyConsent = true;
    else
      this.addObservers();

    replySuccess(reply, null);
  }

  private void addObservers() {
    OneSignal.addSubscriptionObserver(this);
    OneSignal.addEmailSubscriptionObserver(this);
    OneSignal.addSMSSubscriptionObserver(this);
    OneSignal.addPermissionObserver(this);
    OneSignal.setNotificationWillShowInForegroundHandler(this);
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

  private void userProvidedPrivacyConsent(MethodCall call, Result reply) {
    boolean result = OneSignal.userProvidedPrivacyConsent();

    replySuccess(reply, result);
  }

  private void promptPermission(MethodCall call, Result result) {
    OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "promptPermission() is not applicable in Android");
    replySuccess(result, null);
  }

  private void getDeviceState(Result reply) {
    OSDeviceState state = OneSignal.getDeviceState();
    replySuccess(reply, OneSignalSerializer.convertDeviceStateToMap(state));
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

  private void setSMSNumber(MethodCall call, final Result reply) {
    String smsNumber = call.argument("smsNumber");
    String smsAuthHashToken = call.argument("smsAuthHashToken");

    OneSignal.setSMSNumber(smsNumber, smsAuthHashToken, new OneSignal.OSSMSUpdateHandler() {
      @Override
      public void onSuccess(JSONObject result) {
        try {
          replySuccess(reply, OneSignalSerializer.convertJSONObjectToHashMap(result));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for setSMSNumber: " + e.getMessage());
        }
      }

      @Override
      public void onFailure(OneSignal.OSSMSUpdateError error) {
        replyError(reply, "OneSignal",
                "Encountered an error setting SMS Number: " + error.getMessage(),
                null);
      }
    });
  }

  private void logoutSMSNumber(final Result reply) {
    OneSignal.logoutSMSNumber(new OneSignal.OSSMSUpdateHandler() {
      @Override
      public void onSuccess(JSONObject result) {
        try {
          replySuccess(reply, OneSignalSerializer.convertJSONObjectToHashMap(result));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for logoutSMSNumber: " + e.getMessage());
        }
      }

      @Override
      public void onFailure(OneSignal.OSSMSUpdateError error) {
        replyError(reply, "OneSignal",
                "Encountered an error logging out SMS number: " + error.getMessage(),
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
      public void onSuccess(JSONObject results) {
        try {
          replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for setExternalUserId: " + e.getMessage());
        }
      }

      @Override
      public void onFailure(OneSignal.ExternalIdError error) {
        replyError(result, "OneSignal",
                "Encountered an error setting external id: " + error.getMessage(),
                null);
      }
    });
  }

  private void removeExternalUserId(final Result result) {
    OneSignal.removeExternalUserId(new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
      @Override
      public void onSuccess(JSONObject results) {
        try {
          replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
        } catch (JSONException e) {
          OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
                  "Encountered an error attempting to deserialize server response for removeExternalUserId: " + e.getMessage());
        }
      }

      @Override
      public void onFailure(OneSignal.ExternalIdError error) {
        replyError(result, "OneSignal",
                "Encountered an error removing external id: " + error.getMessage(),
                null);
      }
    });
  }

  private void initNotificationOpenedHandlerParams() {
    OneSignal.setNotificationOpenedHandler(this);
  }

  private void initInAppMessageClickedHandlerParams() {
    this.hasSetInAppMessageClickedHandler = true;
    if (this.inAppMessageClickedResult != null) {
      this.inAppMessageClicked(this.inAppMessageClickedResult);
      this.inAppMessageClickedResult = null;
    }
  }

  private void initNotificationWillShowInForegroundHandlerParams() {
    this.hasSetNotificationWillShowInForegroundHandler = true;
  }

  private void clearOneSignalNotifications(MethodCall call, final Result reply) {
    OneSignal.clearOneSignalNotifications();

    replySuccess(reply, null);
  }

  private void removeNotification(MethodCall call, final Result reply) {
    int notificationId = call.argument("notificationId");
    OneSignal.removeNotification(notificationId);

    replySuccess(reply, null);
  }

  private void completeNotification(MethodCall call, final Result reply) {
    String notificationId = call.argument("notificationId");
    boolean shouldDisplay = call.argument("shouldDisplay");
    OSNotificationReceivedEvent notificationReceivedEvent = notificationReceivedEventCache.get(notificationId);

    if (notificationReceivedEvent == null) {
      OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Could not find notification completion block with id: " + notificationId);
      return;
    }

    if (shouldDisplay) {
      notificationReceivedEvent.complete(notificationReceivedEvent.getNotification());
    } else {
      notificationReceivedEvent.complete(null);
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
  public void onSMSSubscriptionChanged(OSSMSSubscriptionStateChanges stateChanges) {
    invokeMethodOnUiThread("OneSignal#smsSubscriptionChanged", OneSignalSerializer.convertSMSSubscriptionStateChangesToMap(stateChanges));
  }

  @Override
  public void onOSPermissionChanged(OSPermissionStateChanges stateChanges) {
    invokeMethodOnUiThread("OneSignal#permissionChanged", OneSignalSerializer.convertPermissionStateChangesToMap(stateChanges));
  }

  @Override
  public void notificationOpened(OSNotificationOpenedResult result) {
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

  @Override
  public void notificationWillShowInForeground(OSNotificationReceivedEvent notificationReceivedEvent) {
    if (!this.hasSetNotificationWillShowInForegroundHandler) {
      notificationReceivedEvent.complete(notificationReceivedEvent.getNotification());
      return;
    }

    OSNotification notification = notificationReceivedEvent.getNotification();
    notificationReceivedEventCache.put(notification.getNotificationId(), notificationReceivedEvent);

    try {
      HashMap<String, Object>  receivedMap = OneSignalSerializer.convertNotificationReceivedEventToMap(notificationReceivedEvent);
      invokeMethodOnUiThread("OneSignal#handleNotificationWillShowInForeground", receivedMap);
    } catch (JSONException e) {
      e.getStackTrace();
      OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR,
              "Encountered an error attempting to convert OSNotificationReceivedEvent object to hash map: " + e.getMessage());
    }
  }

}
