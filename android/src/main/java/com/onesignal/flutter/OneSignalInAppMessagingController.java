package com.onesignal.flutter;

import com.onesignal.OneSignal;

import java.util.Collection;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class OneSignalInAppMessagingController extends FlutterRegistrarResponder implements MethodCallHandler {
    private MethodChannel channel;

    static void registerWith(Registrar registrar) {
        OneSignalInAppMessagingController controller = new OneSignalInAppMessagingController();
        controller.channel = new MethodChannel(registrar.messenger(), "OneSignal#inAppMessages");
        controller.channel.setMethodCallHandler(controller);
        controller.flutterRegistrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#addTrigger"))
            this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#addTriggers"))
            this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#removeTriggerForKey"))
            this.removeTriggerForKey(call, result);
        else if (call.method.contentEquals("OneSignal#removeTriggersForKeys"))
            this.removeTriggersForKeys(call, result);
        else if (call.method.contentEquals("OneSignal#getTriggerValueForKey"))
            replySuccess(result, OneSignal.getTriggerValueForKey((String) call.arguments));
        else if (call.method.contentEquals("OneSignal#pauseInAppMessages"))
            this.pauseInAppMessages(call, result);
        else
            replyNotImplemented(result);
    }

    private void addTriggers(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.addTriggers((Map<String, Object>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(result, "OneSignal", "Add triggers failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void removeTriggerForKey(MethodCall call, Result result) {
        OneSignal.removeTriggerForKey((String) call.arguments);
        replySuccess(result, null);
    }

    private void removeTriggersForKeys(MethodCall call, Result result) {
        // call.arguments is being casted to a Collection<String> a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.removeTriggersForKeys((Collection<String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(result, "OneSignal", "Remove triggers for keys failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void pauseInAppMessages(MethodCall call, Result result) {
        OneSignal.pauseInAppMessages((boolean) call.arguments);
        replySuccess(result, null);
    }
}
