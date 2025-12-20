package com.onesignal.flutter;

import com.onesignal.Continue;
import com.onesignal.OneSignal;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OneSignalLocation extends FlutterMessengerResponder implements MethodCallHandler {
    private static OneSignalLocation sharedInstance;

    public static OneSignalLocation getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new OneSignalLocation();
        }
        return sharedInstance;
    }

    private OneSignalLocation() { }

    static void registerWith(BinaryMessenger messenger) {
        OneSignalLocation controller = getSharedInstance();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#location");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#requestPermission")) this.requestPermission(result);
        else if (call.method.contentEquals("OneSignal#setShared")) this.setShared(call, result);
        else if (call.method.contentEquals("OneSignal#isShared"))
            replySuccess(result, OneSignal.getLocation().isShared());
        else replyNotImplemented(result);
    }

    private void requestPermission(Result reply) {
        OneSignal.getLocation().requestPermission(Continue.none());
        replySuccess(reply, null);
    }

    private void setShared(MethodCall call, Result result) {
        OneSignal.getLocation().setShared((boolean) call.arguments);
        replySuccess(result, null);
    }
}
