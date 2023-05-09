package com.onesignal.flutter;

import com.onesignal.OneSignal;

import com.onesignal.user.subscriptions.IPushSubscription;
import com.onesignal.user.subscriptions.ISubscription;
import com.onesignal.user.subscriptions.IPushSubscriptionObserver;
import com.onesignal.user.subscriptions.PushSubscriptionChangedState;
import com.onesignal.user.subscriptions.PushSubscriptionState;
import com.onesignal.debug.internal.logging.Logging;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class OneSignalPushSubscription extends FlutterRegistrarResponder implements MethodCallHandler, IPushSubscriptionObserver {

    static void registerWith(BinaryMessenger messenger) {
        OneSignalPushSubscription controller = new OneSignalPushSubscription();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#pushsubscription");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#optIn"))
            this.optIn(call, result);
        else if (call.method.contentEquals("OneSignal#optOut"))
            this.optOut(call, result);
        else if (call.method.contentEquals("OneSignal#pushSubscriptionId"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getId());
        else if (call.method.contentEquals("OneSignal#pushSubscriptionToken"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getToken());
        else if (call.method.contentEquals("OneSignal#pushSubscriptionOptedIn"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getOptedIn());
        else if (call.method.contentEquals("OneSignal#lifecycleInit"))
            this.lifecycleInit();
        else
            replyNotImplemented(result);
    }

    private void optIn(MethodCall call, Result reply) {
        OneSignal.getUser().getPushSubscription().optIn();
        replySuccess(reply, null);
    }
    private void optOut(MethodCall call, Result reply) {
        OneSignal.getUser().getPushSubscription().optOut();
        replySuccess(reply, null);
    }

    private void lifecycleInit() {
        OneSignal.getUser().getPushSubscription().addObserver(this);
    }  

    @Override
    public void onPushSubscriptionChange(PushSubscriptionChangedState changeState) {
        try {
            invokeMethodOnUiThread("OneSignal#onPushSubscriptionChange", OneSignalSerializer.convertOnPushSubscriptionChange(changeState));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error("Encountered an error attempting to convert PushSubscriptionChangedState object to hash map:" + e.toString(), null);
        }         
    }

} 