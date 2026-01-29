package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.internal.logging.Logging;
import com.onesignal.user.state.IUserStateObserver;
import com.onesignal.user.state.UserChangedState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.List;
import java.util.Map;
import org.json.JSONException;

public class OneSignalUser extends FlutterMessengerResponder implements MethodCallHandler, IUserStateObserver {
    private static OneSignalUser sharedInstance;

    public static OneSignalUser getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new OneSignalUser();
        }
        return sharedInstance;
    }

    private OneSignalUser() {}

    static void registerWith(BinaryMessenger messenger) {
        OneSignalUser controller = getSharedInstance();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#user");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#setLanguage")) this.setLanguage(call, result);
        else if (call.method.contentEquals("OneSignal#getOnesignalId")) this.getOnesignalId(call, result);
        else if (call.method.contentEquals("OneSignal#getExternalId")) this.getExternalId(call, result);
        else if (call.method.contentEquals("OneSignal#addAliases")) this.addAliases(call, result);
        else if (call.method.contentEquals("OneSignal#removeAliases")) this.removeAliases(call, result);
        else if (call.method.contentEquals("OneSignal#addEmail")) this.addEmail(call, result);
        else if (call.method.contentEquals("OneSignal#removeEmail")) this.removeEmail(call, result);
        else if (call.method.contentEquals("OneSignal#addSms")) this.addSms(call, result);
        else if (call.method.contentEquals("OneSignal#removeSms")) this.removeSms(call, result);
        else if (call.method.contentEquals("OneSignal#addTags")) this.addTags(call, result);
        else if (call.method.contentEquals("OneSignal#removeTags")) this.removeTags(call, result);
        else if (call.method.contentEquals("OneSignal#getTags")) this.getTags(call, result);
        else if (call.method.contentEquals("OneSignal#lifecycleInit")) this.lifecycleInit(result);
        else if (call.method.contentEquals("OneSignal#trackEvent"))
            this.trackEvent(call, result);
        else replyNotImplemented(result);
    }

    private void setLanguage(MethodCall call, Result result) {
        String language = call.argument("language");
        if (language != null && language.length() == 0) {
            language = null;
        }
        OneSignal.getUser().setLanguage(language);
        replySuccess(result, null);
    }

    private void lifecycleInit(Result result) {
        OneSignal.getUser().removeObserver(this);
        OneSignal.getUser().addObserver(this);
        replySuccess(result, null);
    }

    private void getOnesignalId(MethodCall call, Result result) {
        String onesignalId = OneSignal.getUser().getOnesignalId();
        if (onesignalId.isEmpty()) {
            onesignalId = null;
        }
        replySuccess(result, onesignalId);
    }

    private void getExternalId(MethodCall call, Result result) {
        String externalId = OneSignal.getUser().getExternalId();
        if (externalId.isEmpty()) {
            externalId = null;
        }
        replySuccess(result, externalId);
    }

    private void addAliases(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        // a ClassCastException will be thrown
        try {
            OneSignal.getUser().addAliases((Map<String, String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(
                    result,
                    "OneSignal",
                    "addAliases failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
        }
    }

    private void removeAliases(MethodCall call, Result result) {
        // call.arguments is being casted to a List<String> so a try-catch with
        // a ClassCastException will be thrown
        try {
            OneSignal.getUser().removeAliases((List<String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(
                    result,
                    "OneSignal",
                    "removeAliases failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
        }
    }

    private void addEmail(MethodCall call, Result result) {
        OneSignal.getUser().addEmail((String) call.arguments);
        replySuccess(result, null);
    }

    private void removeEmail(MethodCall call, Result result) {
        OneSignal.getUser().removeEmail((String) call.arguments);
        replySuccess(result, null);
    }

    private void addSms(MethodCall call, Result result) {
        OneSignal.getUser().addSms((String) call.arguments);
        replySuccess(result, null);
    }

    private void removeSms(MethodCall call, Result result) {
        OneSignal.getUser().removeSms((String) call.arguments);
        replySuccess(result, null);
    }

    private void addTags(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        // a ClassCastException will be thrown
        try {
            OneSignal.getUser().addTags((Map<String, String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(
                    result,
                    "OneSignal",
                    "addTags failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
        }
    }

    private void removeTags(MethodCall call, Result result) {
        // call.arguments is being casted to a List<String> so a try-catch with
        // a ClassCastException will be thrown
        try {
            OneSignal.getUser().removeTags((List<String>) call.arguments);
            replySuccess(result, null);
        } catch (ClassCastException e) {
            replyError(
                    result,
                    "OneSignal",
                    "deleteTags failed with error: " + e.getMessage() + "\n" + e.getStackTrace(),
                    null);
        }
    }

    private void getTags(MethodCall call, Result result) {
        replySuccess(result, OneSignal.getUser().getTags());
    }

    private void trackEvent(MethodCall call, Result result) {
        String name = call.argument("name");
        Map<String, Object> properties = call.argument("properties");
        Map<String, Object> sanitizedProperties = OneSignalSerializer.formatPropertiesMap(properties);
        OneSignal.getUser().trackEvent(name, sanitizedProperties);
        replySuccess(result, null);
    }

    @Override
    public void onUserStateChange(UserChangedState userChangedState) {
        try {
            invokeMethodOnUiThread(
                    "OneSignal#onUserStateChange", OneSignalSerializer.convertOnUserStateChange(userChangedState));
        } catch (JSONException e) {
            e.getStackTrace();
            Logging.error(
                    "Encountered an error attempting to convert UserChangedState object to hash map:" + e.toString(),
                    null);
        }
    }
}
