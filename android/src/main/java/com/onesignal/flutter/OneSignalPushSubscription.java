package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.user.subscriptions.IPushSubscriptionObserver;
import com.onesignal.user.subscriptions.PushSubscriptionChangedState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import org.json.JSONException;

public class OneSignalPushSubscription extends FlutterMessengerResponder
        implements MethodCallHandler, IPushSubscriptionObserver {
    private static OneSignalPushSubscription instance;
    private boolean hasObserver = false;

    static void registerWith(BinaryMessenger messenger) {
        if (instance != null) {
            instance.removeListeners();
        }
        instance = new OneSignalPushSubscription();
        instance.messenger = messenger;
        instance.channel = new MethodChannel(messenger, "OneSignal#pushsubscription");
        instance.channel.setMethodCallHandler(instance);
    }

    static void unregisterWith() {
        if (instance != null) {
            instance.removeListeners();
            instance.channel.setMethodCallHandler(null);
            instance = null;
        }
    }

    private void removeListeners() {
        if (hasObserver) {
            OneSignal.getUser().getPushSubscription().removeObserver(this);
            hasObserver = false;
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#optIn")) this.optIn(call, result);
        else if (call.method.contentEquals("OneSignal#optOut")) this.optOut(call, result);
        else if (call.method.contentEquals("OneSignal#pushSubscriptionId"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getId());
        else if (call.method.contentEquals("OneSignal#pushSubscriptionToken"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getToken());
        else if (call.method.contentEquals("OneSignal#pushSubscriptionOptedIn"))
            replySuccess(result, OneSignal.getUser().getPushSubscription().getOptedIn());
        else if (call.method.contentEquals("OneSignal#lifecycleInit")) this.lifecycleInit(result);
        else replyNotImplemented(result);
    }

    private void optIn(MethodCall call, Result reply) {
        OneSignal.getUser().getPushSubscription().optIn();
        replySuccess(reply, null);
    }

    private void optOut(MethodCall call, Result reply) {
        OneSignal.getUser().getPushSubscription().optOut();
        replySuccess(reply, null);
    }

    private void lifecycleInit(Result result) {
        OneSignal.getUser().getPushSubscription().addObserver(this);
        hasObserver = true;
        replySuccess(result, null);
    }

    @Override
    public void onPushSubscriptionChange(PushSubscriptionChangedState changeState) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onPushSubscriptionChange",
                    OneSignalSerializer.convertOnPushSubscriptionChange(changeState));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert PushSubscriptionChangedState object to hash map:"
                            + e.toString(),
                    null);
        }
    }
}
