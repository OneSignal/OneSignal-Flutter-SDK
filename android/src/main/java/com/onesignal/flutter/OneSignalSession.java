package com.onesignal.flutter;

import com.onesignal.OneSignal;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OneSignalSession extends FlutterMessengerResponder implements MethodCallHandler {

    static void registerWith(BinaryMessenger messenger) {
        OneSignalSession controller = new OneSignalSession();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#session");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#addOutcome"))
            this.addOutcome(call, result);
        else if (call.method.contentEquals("OneSignal#addUniqueOutcome"))
            this.addUniqueOutcome(call, result);
        else if (call.method.contentEquals("OneSignal#addOutcomeWithValue"))
            this.addOutcomeWithValue(call, result);
        else
            replyNotImplemented(result);
    }

    private void addOutcome(MethodCall call, Result result) {
        String name = (String) call.arguments;

        if (name == null || name.isEmpty()) {
            replyError(result, "OneSignal", "addOutcome() name must not be null or empty", null);
            return;
        }

        OneSignal.getSession().addOutcome(name);
        replySuccess(result, null);
    }

    private void addUniqueOutcome(MethodCall call, Result result) {
        String name = (String) call.arguments;

        if (name == null || name.isEmpty()) {
            replyError(result, "OneSignal", "sendUniqueOutcome() name must not be null or empty", null);
            return;
        }

        OneSignal.getSession().addUniqueOutcome(name);
        replySuccess(result, null);
    }

    private void addOutcomeWithValue(MethodCall call, Result result) {
        String name = call.argument("outcome_name");
        Double value = call.argument("outcome_value");

        if (name == null || name.isEmpty()) {
            replyError(result, "OneSignal", "sendOutcomeWithValue() name must not be null or empty", null);
            return;
        }

        if (value == null) {
            replyError(result, "OneSignal", "sendOutcomeWithValue() value must not be null", null);
            return;
        }

        OneSignal.getSession().addOutcomeWithValue(name, value.floatValue());
        replySuccess(result, null);
    }

}
