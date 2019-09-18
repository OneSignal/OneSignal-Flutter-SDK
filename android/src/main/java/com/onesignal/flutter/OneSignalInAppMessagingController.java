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
          addTriggers(call.arguments);
        else if (call.method.contentEquals("OneSignal#addTriggers"))
          addTriggers(call.arguments);
        else if (call.method.contentEquals("OneSignal#removeTriggerForKey"))
          OneSignal.removeTriggerForKey((String) call.arguments);
        else if (call.method.contentEquals("OneSignal#removeTriggersForKeys"))
          removeTriggersForKeys(call.arguments);
        else if (call.method.contentEquals("OneSignal#getTriggerValueForKey"))
          getTriggerValueForKey(result, (String) call.arguments);
        else if (call.method.contentEquals("OneSignal#pauseInAppMessages"))
          OneSignal.pauseInAppMessages((boolean) call.arguments);
    }

    private void addTriggers(Object arguments) {
      // call.arguments is being casted to a Map<String, Object> so a try-catch with
      //  a ClassCastException will be thrown
      try {
        OneSignal.addTriggers((Map<String, Object>) arguments);
      } catch (ClassCastException e) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Add triggers failed with error: " + e.getMessage());
        e.printStackTrace();
      }
    }

    private void removeTriggersForKeys(Object arguments) {
      // call.arguments is being casted to a Collection<String> a try-catch with
      //  a ClassCastException will be thrown
      try {
        OneSignal.removeTriggersForKeys((Collection<String>) arguments);
      } catch (ClassCastException e) {
        OneSignal.onesignalLog(OneSignal.LOG_LEVEL.ERROR, "Remove trigger for keys failed with error: " + e.getMessage());
        e.printStackTrace();
      }
    }

    private void getTriggerValueForKey(Result reply, String key) {
      Object triggerValue = OneSignal.getTriggerValueForKey(key);
      replySuccess(reply, triggerValue);
    }
}
