package com.onesignal.flutter;

import android.annotation.SuppressLint;
import android.content.Context;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import com.onesignal.OSDeviceState;
import com.onesignal.OSEmailSubscriptionObserver;
import com.onesignal.OSEmailSubscriptionStateChanges;
import com.onesignal.OSInAppMessageAction;
import com.onesignal.OSInAppMessage;
import com.onesignal.OSInAppMessageLifecycleHandler;
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

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** OnesignalPlugin */
public class OneSignalPlugin
        extends FlutterRegistrarResponder
        implements FlutterPlugin, 
        MethodCallHandler,
        ActivityAware,
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


  private final HashMap<String, OSNotificationReceivedEvent> notificationReceivedEventCache = new HashMap<>();

  public OneSignalPlugin() {
  }

  private void init(Context context, BinaryMessenger messenger)
  {
    this.context = context;
    this.messenger = messenger;

    OneSignal.sdkType = "flutter";

    waitingForUserPrivacyConsent = false;
    channel = new MethodChannel(messenger, "OneSignal");
    channel.setMethodCallHandler(this);

    OneSignalTagsController.registerWith(messenger);
    OneSignalInAppMessagingController.registerWith(messenger);
    OneSignalOutcomeEventsController.registerWith(messenger);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    init(
        flutterPluginBinding.getApplicationContext(),
        flutterPluginBinding.getBinaryMessenger()
    );
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    onDetachedFromEngine();
  }

  private void onDetachedFromEngine() {
    OneSignal.setNotificationOpenedHandler(null);
    OneSignal.setInAppMessageClickHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.context = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
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
    else if (call.method.contentEquals("OneSignal#setLanguage"))
      this.setLanguage(call, result);
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

    OneSignal.setInAppMessageClickHandler(this);
    OneSignal.initWithContext(context);
    OneSignal.setAppId(appId);
    setInAppMessageLifecycleHandler();

    if (hasSetRequiresPrivacyConsent && !OneSignal.userProvidedPrivacyConsent())
      this.waitingForUserPrivacyConsent = true;
    else
      this.addObservers();

    replySuccess(reply, null);
  }

  private void addObservers() {
    // Clean observers before setting, avoid being call twice
    OneSignal.removeSubscriptionObserver(this);
    OneSignal.removeEmailSubscriptionObserver(this);
    OneSignal.removeSMSSubscriptionObserver(this);
    OneSignal.removePermissionObserver(this);

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
    boolean fallback = call.argument("fallback");
    OneSignal.promptForPushNotifications(fallback, new OSFlutterPromptForPushNotificationPermissionResponseHandler(messenger, channel, result, "promptPermission"));
  }

  private void getDeviceState(Result reply) {
    OSDeviceState state = OneSignal.getDeviceState();
    replySuccess(reply, OneSignalSerializer.convertDeviceStateToMap(state));
  }

  private void postNotification(MethodCall call, final Result reply) {
    JSONObject json = new JSONObject((Map<String, Object>) call.arguments);
    OneSignal.postNotification(json, new OSFlutterPostNotificationHandler(messenger, channel, reply, "postNotification"));
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

    OneSignal.setEmail(email, emailAuthHashToken, new OSFlutterEmailHandler(messenger, channel, reply, "setEmail"));
  }

  private void logoutEmail(final Result reply) {
    OneSignal.logoutEmail(new OSFlutterEmailHandler(messenger, channel, reply, "logoutEmail"));
  }

  private void setSMSNumber(MethodCall call, final Result reply) {
    String smsNumber = call.argument("smsNumber");
    String smsAuthHashToken = call.argument("smsAuthHashToken");

    OneSignal.setSMSNumber(smsNumber, smsAuthHashToken, new OSFlutterSMSHandler(messenger, channel, reply, "setSMSNumber"));
  }

  private void logoutSMSNumber(final Result reply) {
    OneSignal.logoutSMSNumber(new OSFlutterSMSHandler(messenger, channel, reply, "logoutSMSNumber"));
  }

  private void setLanguage(MethodCall call, final Result result) {
    String language = call.argument("language");
    if (language != null && language.length() == 0)
      language = null;

      OneSignal.setLanguage(language, new OSFlutterSetLanguageHandler(messenger, channel, result, "setLanguage"));
  }

  private void setExternalUserId(MethodCall call, final Result result) {
    String externalUserId = call.argument("externalUserId");
    String authHashToken = call.argument("authHashToken");
    if (externalUserId != null && externalUserId.length() == 0)
      externalUserId = null;
    if (authHashToken != null && authHashToken.length() == 0)
      authHashToken = null;

    OneSignal.setExternalUserId(externalUserId, authHashToken, new OSFlutterExternalUserIdHandler(messenger, channel, result, "setExternalUserId"));
  }

  private void removeExternalUserId(final Result result) {
    OneSignal.removeExternalUserId(new OSFlutterExternalUserIdHandler(messenger, channel, result, "removeExternalUserId"));
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

  /* in app message lifecycle */
  public void setInAppMessageLifecycleHandler() {
    OneSignal.setInAppMessageLifecycleHandler(new OSInAppMessageLifecycleHandler() {
        @Override
        public void onWillDisplayInAppMessage(OSInAppMessage message) { 
          invokeMethodOnUiThread("OneSignal#onWillDisplayInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
        }

        @Override
        public void onDidDisplayInAppMessage(OSInAppMessage message) {
          invokeMethodOnUiThread("OneSignal#onDidDisplayInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
        }

        @Override
        public void onWillDismissInAppMessage(OSInAppMessage message) {
          invokeMethodOnUiThread("OneSignal#onWillDismissInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
        }

        @Override
        public void onDidDismissInAppMessage(OSInAppMessage message) {
          invokeMethodOnUiThread("OneSignal#onDidDismissInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
        }
    });
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

  static class OSFlutterEmailHandler extends OSFlutterHandler
          implements OneSignal.EmailUpdateHandler {

    OSFlutterEmailHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }

    @Override
    public void onSuccess() {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring!");
        return;
      }

      replySuccess(result, null);
    }

    @Override
    public void onFailure(EmailUpdateError error) {
      if (this.replySubmitted.getAndSet(true))
          return;

      replyError(result, "OneSignal",
              "Encountered an error when " + methodName + ": " + error.getMessage(),
              null);
    }
  }

  static class OSFlutterSMSHandler extends OSFlutterHandler
          implements OneSignal.OSSMSUpdateHandler {

    OSFlutterSMSHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }

    @Override
    public void onSuccess(JSONObject results) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response: " + results);
        return;
      }

      try {
        replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
      } catch (JSONException e) {
        replyError(result, "OneSignal", "Encountered an error attempting to deserialize server response for " + methodName + ": " + e.getMessage(), null);
      }
    }

    @Override
    public void onFailure(OneSignal.OSSMSUpdateError error) {
      if (this.replySubmitted.getAndSet(true))
        return;

      replyError(result, "OneSignal", "Encountered an error when " + methodName + " (" + error.getType() + "): " + error.getMessage(), null);
    }
  }

  static class OSFlutterExternalUserIdHandler extends OSFlutterHandler
          implements OneSignal.OSExternalUserIdUpdateCompletionHandler {

    OSFlutterExternalUserIdHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }

    @Override
    public void onSuccess(JSONObject results) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response: " + results);
        return;
      }

      try {
        replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
      } catch (JSONException e) {
        replyError(result, "OneSignal", "Encountered an error attempting to deserialize server response for " + methodName + ": " + e.getMessage(), null);
      }
    }

    @Override
    public void onFailure(OneSignal.ExternalIdError error) {
      if (this.replySubmitted.getAndSet(true))
        return;

      replyError(result, "OneSignal", "Encountered an error when " + methodName + " (" + error.getType() + "): " + error.getMessage(), null);
    }
  }

  static class OSFlutterPromptForPushNotificationPermissionResponseHandler extends OSFlutterHandler
            implements OneSignal.PromptForPushNotificationPermissionResponseHandler {
    OSFlutterPromptForPushNotificationPermissionResponseHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }
      
    @Override
    public void response(boolean accepted) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response");
        return;
      }
      replySuccess(result, accepted);
    }
  }

  static class OSFlutterPostNotificationHandler extends OSFlutterHandler
            implements OneSignal.PostNotificationResponseHandler {

    OSFlutterPostNotificationHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }

    @Override
    public void onSuccess(JSONObject results) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response: " + results);
        return;
      }

      try {
          replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(results));
      } catch (JSONException e) {
          replyError(result, "OneSignal", "Encountered an error attempting to deserialize server response for " + methodName + ": " + e.getMessage(), null);
      }
    }

    @Override
    public void onFailure(JSONObject response) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response: " + response);
        return;
      }

      try {
          replyError(result, "OneSignal", "Encountered an error attempting to " + methodName + " " + response.toString(), OneSignalSerializer.convertJSONObjectToHashMap(response));
      } catch (JSONException jsonException) {
          replyError(result, "OneSignal", "Encountered an error attempting to deserialize server response " + methodName + " " + jsonException.getMessage(), null);
      }
    }
  }

  static class OSFlutterSetLanguageHandler extends OSFlutterHandler
          implements OneSignal.OSSetLanguageCompletionHandler {

    OSFlutterSetLanguageHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      super(messenger, channel, res, methodName);
    }

    @Override
    public void onSuccess(String results) {
      if (this.replySubmitted.getAndSet(true)) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.DEBUG, "OneSignal " + methodName + " handler called twice, ignoring! response: " + results);
        return;
      }

      if (results == null) { // The results currently is always null.
        results = "Successfully set language.";
      }

      HashMap<String, Object> responseMap = new HashMap<>();
      responseMap.put("success", true);
      responseMap.put("message", results);
      replySuccess(result, responseMap);
    }

    @Override
    public void onFailure(OneSignal.OSLanguageError error) {
      if (this.replySubmitted.getAndSet(true)) {
        return;
      }

      String errorMessage = error.getMessage();
      if (errorMessage == null) {
        errorMessage = "Failed to set language.";
      }

      replyError(result, "OneSignal",
              "Encountered an error when " + methodName + ": " + errorMessage,
              null);
    }
  }

  static class OSFlutterHandler extends FlutterRegistrarResponder {
    protected final Result result;
    protected final String methodName;
    protected final AtomicBoolean replySubmitted = new AtomicBoolean(false);

    OSFlutterHandler(BinaryMessenger messenger, MethodChannel channel, Result res, String methodName) {
      this.messenger = messenger;
      this.channel = channel;
      this.result = res;
      this.methodName = methodName;
    }
  }
}
