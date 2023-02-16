package com.onesignal.flutter;

import android.annotation.SuppressLint;
import android.content.Context;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import com.onesignal.OneSignal;

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

  private boolean hasSetRequiresPrivacyConsent = false;
  private boolean waitingForUserPrivacyConsent = false;

  public OneSignalPlugin() {
  }

  private void init(Context context, BinaryMessenger messenger)
  {
    this.context = context;
    this.messenger = messenger;

    // OneSignal.sdkType = "flutter";

    waitingForUserPrivacyConsent = false;
    channel = new MethodChannel(messenger, "OneSignal");
    channel.setMethodCallHandler(this);

    // OneSignalTagsController.registerWith(messenger);
    // OneSignalInAppMessagingController.registerWith(messenger);
    // OneSignalOutcomeEventsController.registerWith(messenger);
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
    // OneSignal.setNotificationOpenedHandler(null);
    // OneSignal.setInAppMessageClickHandler(null);
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
    if (call.method.contentEquals("OneSignal#initalize"))
      this.initWithContext(call, result);
    else
      replyNotImplemented(result);
  }

  private void initWithContext(MethodCall call, Result reply) {
    String appId = call.argument("appId");
    OneSignal.initWithContext(context, appId);
   
    // if (hasSetRequiresPrivacyConsent && !OneSignal.userProvidedPrivacyConsent())
    //   this.waitingForUserPrivacyConsent = true;
    // else
    //   this.addObservers();

    replySuccess(reply, null);
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
