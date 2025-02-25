package com.onesignal.flutter;

import android.content.Context;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import com.onesignal.OneSignal;
import com.onesignal.common.OneSignalWrapper;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** OnesignalPlugin */
public class OneSignalPlugin extends FlutterMessengerResponder implements FlutterPlugin, MethodCallHandler, ActivityAware {

  public OneSignalPlugin() {
  }

  private void init(Context context, BinaryMessenger messenger)
  { 
    this.context = context;
    this.messenger = messenger;
    OneSignalWrapper.setSdkType("flutter");  
    // For 5.0.0, hard code to reflect SDK version
    OneSignalWrapper.setSdkVersion("050300");
    
    channel = new MethodChannel(messenger, "OneSignal");
    channel.setMethodCallHandler(this);

    OneSignalDebug.registerWith(messenger);
    OneSignalLocation.registerWith(messenger);
    OneSignalSession.registerWith(messenger);
    OneSignalInAppMessages.registerWith(messenger);
    OneSignalUser.registerWith(messenger);
    OneSignalPushSubscription.registerWith(messenger);
    OneSignalNotifications.registerWith(messenger);
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
    if (call.method.contentEquals("OneSignal#initialize"))
      this.initWithContext(call, result);
    else if (call.method.contentEquals("OneSignal#consentRequired"))
      this.setConsentRequired(call, result);
    else if (call.method.contentEquals("OneSignal#consentGiven"))
      this.setConsentGiven(call, result);
    else if (call.method.contentEquals("OneSignal#login"))
      this.login(call, result);
      else if (call.method.contentEquals("OneSignal#loginWithJWT"))
      this.loginWithJWT(call, result);
    else if (call.method.contentEquals("OneSignal#logout"))
      this.logout(call, result);
    else
      replyNotImplemented(result);
  }

  private void initWithContext(MethodCall call, Result reply) {
    String appId = call.argument("appId");
    OneSignal.initWithContext(context, appId);
    replySuccess(reply, null);
  }

  private void setConsentRequired(MethodCall call, Result reply) {
    boolean required = call.argument("required");
    OneSignal.setConsentRequired(required);
    replySuccess(reply, null);
  }

  private void setConsentGiven(MethodCall call, Result reply) {
    boolean granted = call.argument("granted");
    OneSignal.setConsentGiven(granted);
    replySuccess(reply, null);
  }

  private void login(MethodCall call, Result result) {
    OneSignal.login((String) call.argument("externalId"));
    replySuccess(result, null);
  }

  private void loginWithJWT(MethodCall call, Result result) {
    OneSignal.login((String) call.argument("externalId"), (String) call.argument("jwt"));
    replySuccess(result, null);
  }
  
  private void logout(MethodCall call, Result result) {
    OneSignal.logout();
    replySuccess(result, null);
  }
}
