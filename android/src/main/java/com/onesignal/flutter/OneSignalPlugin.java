package com.onesignal.flutter;

import android.content.Context;
import androidx.annotation.NonNull;
import com.onesignal.OneSignal;
import com.onesignal.OneSignalResult;
import com.onesignal.OneSignalUserProfile;
import com.onesignal.common.OneSignalWrapper;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.EmptyCoroutineContext;
import kotlin.coroutines.intrinsics.IntrinsicsKt;

/** OnesignalPlugin */
public class OneSignalPlugin extends FlutterMessengerResponder
        implements FlutterPlugin, MethodCallHandler, ActivityAware {

    public OneSignalPlugin() {}

    private void init(Context context, BinaryMessenger messenger) {
        this.context = context;
        this.messenger = messenger;
        OneSignalWrapper.setSdkType("flutter");
        // Keep in sync with pubspec.yaml version
        OneSignalWrapper.setSdkVersion("050700");

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
        init(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        // #1138: pass the detaching engine's messenger so a background (FlutterFire)
        // engine detaching doesn't tear down the listener bound to the UI engine.
        OneSignalNotifications.getSharedInstance().onDetachedFromEngine(binding.getBinaryMessenger());
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.context = binding.getActivity();
        rebindChannelsToActivityEngine();
    }

    @Override
    public void onDetachedFromActivity() {
        // #1138: unregister so the native SDK queues clicks until a new activity attaches.
        OneSignalNotifications.getSharedInstance().onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.context = binding.getActivity();
        rebindChannelsToActivityEngine();
    }

    /**
     * #1138: (re)bind the process-global singleton channels to the engine that
     * hosts the activity (the UI isolate), so native callbacks aren't routed to a
     * FlutterFire background engine that has no listeners.
     */
    private void rebindChannelsToActivityEngine() {
        OneSignalNotifications.getSharedInstance().onAttachedToActivity(this.messenger);
        OneSignalUser.getSharedInstance().onAttachedToActivity(this.messenger);
        OneSignalPushSubscription.getSharedInstance().onAttachedToActivity(this.messenger);
        OneSignalInAppMessages.getSharedInstance().onAttachedToActivity(this.messenger);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        OneSignalNotifications.getSharedInstance().onDetachedFromActivity();
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {
        runOnBackgroundThread(result, new Runnable() {
            @Override
            public void run() {
                handleMethodCall(call, result);
            }
        });
    }

    private void handleMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#initialize")) this.initWithContext(call, result);
        else if (call.method.contentEquals("OneSignal#consentRequired")) this.setConsentRequired(call, result);
        else if (call.method.contentEquals("OneSignal#consentGiven")) this.setConsentGiven(call, result);
        else if (call.method.contentEquals("OneSignal#login")) this.login(call, result);
        else if (call.method.contentEquals("OneSignal#loginWithJWT")) this.loginWithJWT(call, result);
        else if (call.method.contentEquals("OneSignal#loginWithProfile")) this.loginWithProfile(call, result);
        else if (call.method.contentEquals("OneSignal#logout")) this.logout(call, result);
        else replyNotImplemented(result);
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

    private void loginWithProfile(MethodCall call, final Result result) {
        Map<String, Object> rawProfile = call.argument("profile");
        OneSignalUserProfile profile = new OneSignalUserProfile.Builder()
                .setEmail(stringOrNull(rawProfile, "email"))
                .setSms(stringOrNull(rawProfile, "sms"))
                .setTags(stringMap(rawProfile, "tags"))
                .setAliases(stringMap(rawProfile, "aliases"))
                .build();

        final AtomicBoolean replied = new AtomicBoolean(false);
        Continuation<Object> continuation = new Continuation<Object>() {
            @NonNull
            @Override
            public CoroutineContext getContext() {
                return EmptyCoroutineContext.INSTANCE;
            }

            @Override
            public void resumeWith(@NonNull Object outcome) {
                replyLoginResult(result, replied, outcome);
            }
        };

        Object returned = OneSignal.login(
                (String) call.argument("externalId"), profile, (String) call.argument("jwtBearerToken"), continuation);
        // A suspend function that completes without suspending returns its result here
        // and never calls resumeWith.
        if (returned != IntrinsicsKt.getCOROUTINE_SUSPENDED()) {
            replyLoginResult(result, replied, returned);
        }
    }

    private void replyLoginResult(Result result, AtomicBoolean replied, Object outcome) {
        if (!replied.compareAndSet(false, true)) return;
        String message = "Unexpected loginWithProfile result";
        if (outcome instanceof OneSignalResult) {
            // May run on the SDK's coroutine thread, so a conversion failure must not escape.
            try {
                replySuccess(result, OneSignalSerializer.convertToCodecValue(((OneSignalResult<?>) outcome).toMap()));
                return;
            } catch (Throwable t) {
                message = String.valueOf(t);
            }
        } else if (outcome instanceof kotlin.Result.Failure) {
            message = String.valueOf(((kotlin.Result.Failure) outcome).exception);
        }
        replyError(result, "OneSignal", message, null);
    }

    private static String stringOrNull(Map<String, Object> map, String key) {
        Object value = map == null ? null : map.get(key);
        return value instanceof String ? (String) value : null;
    }

    private static Map<String, String> stringMap(Map<String, Object> map, String key) {
        Map<String, String> converted = new HashMap<>();
        Object value = map == null ? null : map.get(key);
        if (!(value instanceof Map)) return converted;
        for (Map.Entry<?, ?> entry : ((Map<?, ?>) value).entrySet()) {
            if (entry.getKey() != null && entry.getValue() != null) {
                converted.put(entry.getKey().toString(), entry.getValue().toString());
            }
        }
        return converted;
    }

    private void logout(MethodCall call, Result result) {
        OneSignal.logout();
        replySuccess(result, null);
    }
}
