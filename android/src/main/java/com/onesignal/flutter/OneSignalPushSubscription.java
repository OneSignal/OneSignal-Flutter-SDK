package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.user.subscriptions.IPushSubscriptionObserver;
import com.onesignal.user.subscriptions.PushSubscriptionChangedState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import org.json.JSONException;

public class OneSignalPushSubscription extends FlutterMessengerResponder
        implements MethodCallHandler, IPushSubscriptionObserver {
    private static OneSignalPushSubscription sharedInstance;

    public static OneSignalPushSubscription getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new OneSignalPushSubscription();
        }
        return sharedInstance;
    }

    private OneSignalPushSubscription() {}

    static void registerWith(BinaryMessenger messenger) {
        OneSignalPushSubscription controller = getSharedInstance();
        controller.bindChannelIfUnbound(messenger, "OneSignal#pushsubscription", controller);
    }

    void onAttachedToActivity(BinaryMessenger activityMessenger) {
        rebindChannelToEngine(activityMessenger, "OneSignal#pushsubscription", this);
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
        OneSignal.getUser().getPushSubscription().removeObserver(this);
        OneSignal.getUser().getPushSubscription().addObserver(this);
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
