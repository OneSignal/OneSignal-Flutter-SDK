package com.onesignal.flutter;

import com.onesignal.OneSignal;

import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

class OSFlutterOutcomeEventsHandler extends FlutterRegistrarResponder implements OneSignal.OutcomeCallback {
    private Result result;

    // the tags callbacks can in some instances be called more than once
    // ie. cached vs. server response.
    // this property guarantees the callback will never be called more than once.
    private AtomicBoolean replySubmitted = new AtomicBoolean(false);

    OSFlutterOutcomeEventsHandler(PluginRegistry.Registrar flutterRegistrar, MethodChannel channel, Result result) {
        this.flutterRegistrar = flutterRegistrar;
        this.channel = channel;
        this.result = result;
    }

    @Override
    public void onOutcomeSuccess(String name) {
        if (this.replySubmitted.getAndSet(true))
            return;

        replySuccess(result, name);
    }

    @Override
    public void onOutcomeFail(int statusCode, String response) {
        if (this.replySubmitted.getAndSet(true))
            return;

        replyError(result,"OneSignal", "Encountered an error sending outcome with code: " + statusCode, response);
    }

}

public class OneSignalOutcomeEventsController extends FlutterRegistrarResponder implements MethodCallHandler {
    private MethodChannel channel;
    private Registrar registrar;

    static void registerWith(Registrar registrar) {
        OneSignalOutcomeEventsController controller = new OneSignalOutcomeEventsController();
        controller.registrar = registrar;
        controller.channel = new MethodChannel(registrar.messenger(), "OneSignal#outcomes");
        controller.channel.setMethodCallHandler(controller);
        controller.flutterRegistrar = registrar;
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
            OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Outcome name must not be null or empty");
            replySuccess(result, null);
            return;
        }

        OneSignal.sendOutcome(name, new OSFlutterOutcomeEventsHandler(registrar, channel, result));
    }

    private void sendUniqueOutcome(MethodCall call, Result result) {
        String name = (String) call.arguments;

        if (name == null || name.isEmpty()) {
            OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Outcome name must not be null or empty");
            replySuccess(result, null);
            return;
        }

        OneSignal.sendUniqueOutcome(name, new OSFlutterOutcomeEventsHandler(registrar, channel, result));
    }

    private void sendOutcomeWithValue(MethodCall call, Result result) {
        String name = call.argument("outcome_name");
        Double value = call.argument("outcome_value");

        if (name == null || name.isEmpty()) {
            OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Outcome name must not be null or empty");
            replySuccess(result, null);
            return;
        }

        if (value == null) {
            OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Outcome value must not be null");
            replySuccess(result, null);
            return;
        }

        OneSignal.sendOutcomeWithValue(name, value.floatValue(), new OSFlutterOutcomeEventsHandler(registrar, channel, result));
    }

}