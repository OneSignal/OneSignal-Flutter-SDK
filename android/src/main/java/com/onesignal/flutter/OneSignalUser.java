package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.LogLevel;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class OneSignalUser extends FlutterRegistrarResponder implements MethodCallHandler {
    private MethodChannel channel;

    static void registerWith(BinaryMessenger messenger) {
        OneSignalUser controller = new OneSignalUser();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#user");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#setLanguage"))
            this.setLanguage(call, result);
        else if (call.method.contentEquals("OneSignal#addAliases"))
            this.addAliases(call, result);
        else if (call.method.contentEquals("OneSignal#removeAliases"))
            this.removeAliases(call, result);
        else if (call.method.contentEquals("OneSignal#addEmail"))
            this.addEmail(call, result);
        else if (call.method.contentEquals("OneSignal#removeEmail"))
            this.removeEmail(call, result);
        else if (call.method.contentEquals("OneSignal#addSms"))
            this.addSms(call, result);
        else if (call.method.contentEquals("OneSignal#removeSMS"))
            this.removeSms(call, result);
        else if (call.method.contentEquals("OneSignal#addTags"))
            this.addTags(call, result);
        else if (call.method.contentEquals("OneSignal#removeTags"))
            this.removeTags(call, result);
        else
            replyNotImplemented(result);
    }

    private void setLanguage(MethodCall call, final Result result) {
        String language = call.argument("language");
        if (language != null && language.length() == 0)
          language = null;
    
          OneSignal.getUser().setLanguage(language);
    }

    private void addAliases(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getUser().addAliases((Map<String, String>) call.arguments);
        } catch(ClassCastException e) {
            replyError(result, "OneSignal", "addAliases failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void removeAliases(MethodCall call, Result result) {
        // call.arguments is being casted to a List<String> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getUser().removeAliases((List<String>) call.arguments);
        } catch(ClassCastException e) {
            replyError(result, "OneSignal", "removeAliases failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void addEmail(MethodCall call, final Result reply) {
        String email = call.argument("email");
    
        OneSignal.getUser().addEmail(email);
      }
    
      private void removeEmail(MethodCall call, final Result reply) {
        String email = call.argument("email");
        OneSignal.getUser().removeEmail(email);
      }
    
      private void addSms(MethodCall call, final Result reply) {
        String smsNumber = call.argument("smsNumber");
    
        OneSignal.getUser().addSms(smsNumber);
      }
    
      private void removeSms(MethodCall call, final Result reply) {
        String smsNumber = call.argument("smsNumber");
        OneSignal.getUser().removeSms(smsNumber);
      }
      private void addTags(MethodCall call, Result result) {
        // call.arguments is being casted to a Map<String, Object> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getUser().addTags((Map<String, String>) call.arguments);
        } catch(ClassCastException e) {
            replyError(result, "OneSignal", "addTags failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }

    private void removeTags(MethodCall call, Result result) {
        // call.arguments is being casted to a List<String> so a try-catch with
        //  a ClassCastException will be thrown
        try {
            OneSignal.getUser().removeTags((List<String>) call.arguments);
        } catch(ClassCastException e) {
            replyError(result, "OneSignal", "deleteTags failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }
    }
    
     
}
