package com.onesignal.flutter;

import android.annotation.SuppressLint;
import android.content.Context;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import com.onesignal.OneSignal;
import com.onesignal.Continue;
import com.onesignal.common.OneSignalWrapper;

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
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

/** OnesignalPlugin */
public class OneSignalPlugin extends FlutterRegistrarResponder implements FlutterPlugin, MethodCallHandler, ActivityAware {

  public OneSignalPlugin() {
  }

  private void init(Context context, BinaryMessenger messenger)
  { 
    this.context = context;
    this.messenger = messenger;
    OneSignalWrapper.setSdkType("flutter");  
    // For 5.0.0, hard code to reflect SDK version
    OneSignalWrapper.setSdkVersion("050206");
    
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

  // This static method is only to remain compatible with apps that don’t use the v2 Android embedding.
  @Deprecated()
  @SuppressLint("Registrar")
  public static void registerWith(Registrar registrar) {
    final OneSignalPlugin plugin = new OneSignalPlugin();
    plugin.init(registrar.activeContext(), registrar.messenger());

    // Create a callback for the flutterRegistrar to connect the applications onDestroy
    registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
      @Override
      public boolean onViewDestroy(FlutterNativeView flutterNativeView) {
        // Remove all handlers so they aren't triggered with wrong context
        plugin.onDetachedFromEngine();
        return false;
      }
    });
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
