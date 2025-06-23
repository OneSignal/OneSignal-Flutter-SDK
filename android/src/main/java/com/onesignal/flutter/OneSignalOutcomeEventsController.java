package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.OSOutcomeEvent;

import java.util.HashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

class OSFlutterOutcomeEventsHandler extends FlutterRegistrarResponder implements OneSignal.OutcomeCallback {
    private Result result;

    // the outcome events callbacks can in some instances be called more than once
    // ie. cached vs. server response.
    // this property guarantees the callback will never be called more than once.
    private AtomicBoolean replySubmitted = new AtomicBoolean(false);

    OSFlutterOutcomeEventsHandler(BinaryMessenger messenger, MethodChannel channel, Result result) {
        this.messenger = messenger;
        this.channel = channel;
        this.result = result;
    }

    @Override
    public void onSuccess(OSOutcomeEvent outcomeEvent) {
        if (this.replySubmitted.getAndSet(true))
            return;

        if (outcomeEvent == null)
            replySuccess(result, new HashMap<>());
        else
            replySuccess(result, OneSignalSerializer.convertOutcomeEventToMap(outcomeEvent));
    }

}

public class OneSignalOutcomeEventsController extends FlutterRegistrarResponder implements MethodCallHandler {
    private MethodChannel channel;

    static void registerWith(BinaryMessenger messenger) {
        OneSignalOutcomeEventsController controller = new OneSignalOutcomeEventsController();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#outcomes");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#sendOutcome"))
            this.sendOutcome(call, result);
        else if (call.method.contentEquals("OneSignal#sendUniqueOutcome"))
            this.sendUniqueOutcome(call, result);
        else if (call.method.contentEquals("OneSignal#sendOutcomeWithValue"))
            this.sendOutcomeWithValue(call, result);
        else
            replyNotImplemented(result);
    }

    private void sendOutcome(MethodCall call, Result result) {
        String name = (String) call.arguments;

        if (name == null || name.isEmpty()) {
            replyError(result, "OneSignal", "sendOutcome() name must not be null or empty", null);
            return;
        }

        OneSignal.sendOutcome(name, new OSFlutterOutcomeEventsHandler(messenger, channel, result));
    }

    private void sendUniqueOutcome(MethodCall call, Result result) {
        String name = (String) call.arguments;

        if (name == null || name.isEmpty()) {
            replyError(result, "OneSignal", "sendUniqueOutcome() name must not be null or empty", null);
            return;
        }

        OneSignal.sendUniqueOutcome(name, new OSFlutterOutcomeEventsHandler(messenger, channel, result));
    }

    private void sendOutcomeWithValue(MethodCall call, Result result) {
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

        OneSignal.sendOutcomeWithValue(name, value.floatValue(), new OSFlutterOutcomeEventsHandler(messenger, channel, result));
    }

}