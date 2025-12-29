package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.inAppMessages.IInAppMessageClickEvent;
import com.onesignal.inAppMessages.IInAppMessageClickListener;
import com.onesignal.inAppMessages.IInAppMessageDidDismissEvent;
import com.onesignal.inAppMessages.IInAppMessageDidDisplayEvent;
import com.onesignal.inAppMessages.IInAppMessageLifecycleListener;
import com.onesignal.inAppMessages.IInAppMessageWillDismissEvent;
import com.onesignal.inAppMessages.IInAppMessageWillDisplayEvent;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.Collection;
import java.util.Map;
import org.json.JSONException;

public class OneSignalInAppMessages extends FlutterMessengerResponder
        implements MethodCallHandler, IInAppMessageClickListener, IInAppMessageLifecycleListener {
    private static OneSignalInAppMessages sharedInstance;

    public static OneSignalInAppMessages getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new OneSignalInAppMessages();
        }
        return sharedInstance;
    }

    private OneSignalInAppMessages() {}

    static void registerWith(BinaryMessenger messenger) {
        OneSignalInAppMessages controller = getSharedInstance();

        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#inappmessages");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#addTrigger")) this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#addTriggers")) this.addTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#removeTrigger")) this.removeTrigger(call, result);
        else if (call.method.contentEquals("OneSignal#removeTriggers")) this.removeTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#clearTriggers")) this.clearTriggers(call, result);
        else if (call.method.contentEquals("OneSignal#arePaused"))
            replySuccess(result, OneSignal.getInAppMessages().getPaused());
        else if (call.method.contentEquals("OneSignal#paused")) this.paused(call, result);
        else if (call.method.contentEquals("OneSignal#lifecycleInit")) this.lifecycleInit(result);
        else replyNotImplemented(result);
    }

    private void addTriggers(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getInAppMessages().addTriggers((Map<String, String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(
                    result,
                    "OneSignal",
                    "Add triggers failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
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
            replyError(
                    result,
                    "OneSignal",
                    "Remove triggers for keys failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
        }
    }

    private void clearTriggers(MethodCall call, Result result) {
        OneSignal.getInAppMessages().clearTriggers();
        replySuccess(result, null);
    }

    private void paused(MethodCall call, Result result) {
        OneSignal.getInAppMessages().setPaused((boolean) call.arguments);
        replySuccess(result, null);
    }

    public void lifecycleInit(Result result) {
        OneSignal.getInAppMessages().removeLifecycleListener(this);
        OneSignal.getInAppMessages().addLifecycleListener(this);
        OneSignal.getInAppMessages().removeClickListener(this);
        OneSignal.getInAppMessages().addClickListener(this);
        replySuccess(result, null);
    }

    @Override
    public void onClick(IInAppMessageClickEvent event) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onClickInAppMessage", OneSignalSerializer.convertInAppMessageClickEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert IInAppMessageClickEvent object to hash map:"
                            + e.toString(),
                    null);
        }
    }

    @Override
    public void onWillDisplay(IInAppMessageWillDisplayEvent event) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onWillDisplayInAppMessage",
                    OneSignalSerializer.convertInAppMessageWillDisplayEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert IInAppMessageWillDisplayEvent object to hash map:"
                            + e.toString(),
                    null);
        }
    }

    @Override
    public void onDidDisplay(IInAppMessageDidDisplayEvent event) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onDidDisplayInAppMessage",
                    OneSignalSerializer.convertInAppMessageDidDisplayEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert IInAppMessageDidDisplayEvent object to hash map:"
                            + e.toString(),
                    null);
        }
    }

    @Override
    public void onWillDismiss(IInAppMessageWillDismissEvent event) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onWillDismissInAppMessage",
                    OneSignalSerializer.convertInAppMessageWillDismissEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert IInAppMessageWillDismissEvent object to hash map:"
                            + e.toString(),
                    null);
        }
    }

    @Override
    public void onDidDismiss(IInAppMessageDidDismissEvent event) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onDidDismissInAppMessage",
                    OneSignalSerializer.convertInAppMessageDidDismissEventToMap(event));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert IInAppMessageDidDismissEvent object to hash map:"
                            + e.toString(),
                    null);
        }
    }
}
