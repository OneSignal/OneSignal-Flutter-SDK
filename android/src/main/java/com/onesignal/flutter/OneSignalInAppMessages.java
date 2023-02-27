package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.inAppMessages.IInAppMessage;
import com.onesignal.inAppMessages.IInAppMessageClickHandler;
import com.onesignal.inAppMessages.IInAppMessageClickResult;
import com.onesignal.inAppMessages.IInAppMessageLifecycleHandler;

import java.util.Collection;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class OneSignalInAppMessages extends FlutterRegistrarResponder implements MethodCallHandler, 
IInAppMessageClickHandler, IInAppMessageLifecycleHandler{
  
    private IInAppMessageClickResult inAppMessageClickedResult;
    private boolean hasSetInAppMessageClickedHandler = false;

    static void registerWith(BinaryMessenger messenger) {
        OneSignalInAppMessages sharedInstance = new OneSignalInAppMessages();
       
        sharedInstance.messenger = messenger;
        sharedInstance.channel = new MethodChannel(messenger, "OneSignal#inappmessages");
        sharedInstance.channel.setMethodCallHandler(sharedInstance);   
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#addTrigger"))
            this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#addTriggers"))
            this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#removeTrigger"))
            this.removeTrigger(call, result);
        else if (call.method.contentEquals("OneSignal#removeTriggers"))
            this.removeTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#arePaused"))
            replySuccess(result, OneSignal.getInAppMessages().getPaused());
        else if (call.method.contentEquals("OneSignal#paused"))
            this.paused(call, result);
        else if (call.method.contentEquals("OneSignal#initInAppMessageClickedHandlerParams"))
            this.initInAppMessageClickedHandlerParams();
        else if (call.method.contentEquals("OneSignal#lifecycleInit"))
            this.lifecycleInit();
        else
            replyNotImplemented(result);
    }

    private void addTriggers(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getInAppMessages().addTriggers((Map<String, Object>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(result, "OneSignal", "Add triggers failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void removeTrigger(MethodCall call, Result result) {
        OneSignal.getInAppMessages().removeTrigger((String) call.arguments);
        replySuccess(result, null);
    }

    private void removeTriggers(MethodCall call, Result result) {
        // call.arguments is being casted to a Collection<String> a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getInAppMessages().removeTriggers((Collection<String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(result, "OneSignal", "Remove triggers for keys failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void paused(MethodCall call, Result result) {
        OneSignal.getInAppMessages().setPaused((boolean) call.arguments);
        replySuccess(result, null);
    }

    private void initInAppMessageClickedHandlerParams() {
        this.hasSetInAppMessageClickedHandler = true;
        if (this.inAppMessageClickedResult != null) {
          this.inAppMessageClicked(this.inAppMessageClickedResult);
          this.inAppMessageClickedResult = null;
        }
      }

    public void lifecycleInit() {
        this.setInAppMessageLifecycleHandler();
        OneSignal.getInAppMessages().setInAppMessageClickHandler(this);
    }

    public void inAppMessageClicked(IInAppMessageClickResult action) {
        if (!this.hasSetInAppMessageClickedHandler) {
            this.inAppMessageClickedResult = action;
        return;
        }

        invokeMethodOnUiThread("OneSignal#handleClickedInAppMessage", OneSignalSerializer.convertInAppMessageClickedActionToMap(action));
    }

    /* in app message lifecycle */
    public void setInAppMessageLifecycleHandler() {
        OneSignal.getInAppMessages().setInAppMessageLifecycleHandler(this);
    }
    
    @Override
    public void onWillDisplayInAppMessage(IInAppMessage message) { 
        invokeMethodOnUiThread("OneSignal#onWillDisplayInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
    }

    @Override
    public void onDidDisplayInAppMessage(IInAppMessage message) {
        invokeMethodOnUiThread("OneSignal#onDidDisplayInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
    }

    @Override
    public void onWillDismissInAppMessage(IInAppMessage message) {
        invokeMethodOnUiThread("OneSignal#onWillDismissInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
    }

    @Override
    public void onDidDismissInAppMessage(IInAppMessage message) {
        invokeMethodOnUiThread("OneSignal#onDidDismissInAppMessage", OneSignalSerializer.convertInAppMessageToMap(message));
    }
}
