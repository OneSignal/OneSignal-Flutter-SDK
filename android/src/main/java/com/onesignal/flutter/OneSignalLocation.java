package com.onesignal.flutter;

import com.onesignal.Continue;
import com.onesignal.OneSignal;
import com.onesignal.debug.internal.logging.Logging;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OneSignalLocation extends FlutterMessengerResponder implements MethodCallHandler {
    private static OneSignalLocation sharedInstance;
    private static final String LOCATION_MODULE_NOT_AVAILABLE =
            "OneSignal location module is not available. Add the location dependency to use OneSignal.Location.";

    public static OneSignalLocation getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new OneSignalLocation();
        }
        return sharedInstance;
    }

    private OneSignalLocation() {}

    static void registerWith(BinaryMessenger messenger) {
        OneSignalLocation controller = getSharedInstance();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#location");
        controller.channel.setMethodCallHandler(controller);
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
        if (call.method.contentEquals("OneSignal#requestPermission")) this.requestPermission(result);
        else if (call.method.contentEquals("OneSignal#setShared")) this.setShared(call, result);
        else if (call.method.contentEquals("OneSignal#isShared")) this.isShared(result);
        else replyNotImplemented(result);
    }

    private void logLocationModuleNotAvailable(Throwable throwable) {
        Logging.error(LOCATION_MODULE_NOT_AVAILABLE, throwable);
    }

    private void requestPermission(Result reply) {
        try {
            OneSignal.getLocation().requestPermission(Continue.none());
        } catch (Throwable t) {
            logLocationModuleNotAvailable(t);
        }
        replySuccess(reply, null);
    }

    private void setShared(MethodCall call, Result result) {
        try {
            OneSignal.getLocation().setShared((boolean) call.arguments);
        } catch (Throwable t) {
            logLocationModuleNotAvailable(t);
        }
        replySuccess(result, null);
    }

    private void isShared(Result result) {
        try {
            replySuccess(result, OneSignal.getLocation().isShared());
        } catch (Throwable t) {
            logLocationModuleNotAvailable(t);
            replySuccess(result, false);
        }
    }
}
