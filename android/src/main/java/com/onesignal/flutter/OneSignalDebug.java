package com.onesignal.flutter;

import com.onesignal.OneSignal;
import com.onesignal.debug.LogLevel;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OneSignalDebug extends FlutterMessengerResponder implements MethodCallHandler {
    
   static void registerWith(BinaryMessenger messenger) {
        OneSignalDebug controller = new OneSignalDebug();
        controller.messenger = messenger;
        controller.channel = new MethodChannel(messenger, "OneSignal#debug");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#setLogLevel"))
            this.setLogLevel(call, result);
        else if (call.method.contentEquals("OneSignal#setAlertLevel"))
            this.setAlertLevel(call, result);
        else
            replyNotImplemented(result);
    }

    private void setLogLevel(MethodCall call, Result reply) {
        try {
            int console = call.argument("logLevel");
            LogLevel consoleLogLevel = LogLevel.fromInt(console);
            OneSignal.getDebug().setLogLevel(consoleLogLevel);
            replySuccess(reply, null);
        }
        catch(ClassCastException e) {
            replyError(reply, "OneSignal", "failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }  
    }

    private void setAlertLevel(MethodCall call, Result reply) {  
        try {
            int visual = call.argument("visualLevel");
            LogLevel visualLogLevel = LogLevel.fromInt(visual);
            OneSignal.getDebug().setAlertLevel(visualLogLevel);
            replySuccess(reply, null);
        }
        catch(ClassCastException e) {
            replyError(reply, "OneSignal", "failed with error: " + e.getMessage() + "\n" + e.getStackTrace(), null);
        }  
    }
}
