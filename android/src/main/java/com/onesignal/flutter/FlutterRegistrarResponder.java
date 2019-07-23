package com.onesignal.flutter;

import android.app.Activity;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

abstract class FlutterRegistrarResponder {
   protected MethodChannel channel;
   protected PluginRegistry.Registrar flutterRegistrar;

   /**
    * MethodChannel class is home to success() method used by Result class
    * It has the @UiThread annotation and must be run on UI thread, otherwise a RuntimeException will be thrown
    * This will communicate success back to Dart
    */
   protected void replySuccess(final MethodChannel.Result reply, final Object response) {
      runOnMainThread(new Runnable() {
         @Override
         public void run() {
            reply.success(response);
         }
      });
   }

   /**
    * MethodChannel class is home to error() method used by Result class
    * It has the @UiThread annotation and must be run on UI thread, otherwise a RuntimeException will be thrown
    * This will communicate error back to Dart
    */
   protected void replyError(final MethodChannel.Result reply, final String tag, final String message, final Object response) {
      runOnMainThread(new Runnable() {
         @Override
         public void run() {
            reply.error(tag, message, response);
         }
      });
   }

   /**
    * MethodChannel class is home to notImplemented() method used by Result class
    * It has the @UiThread annotation and must be run on UI thread, otherwise a RuntimeException will be thrown
    * This will communicate not implemented back to Dart
    */
   protected void replyNotImplemented(final MethodChannel.Result reply) {
      runOnMainThread(new Runnable() {
         @Override
         public void run() {
            reply.notImplemented();
         }
      });
   }

   protected void runOnMainThread(final Runnable runnable) {
      ((Activity)flutterRegistrar.activeContext()).runOnUiThread(runnable);
   }

   protected void invokeMethodOnUiThread(final String methodName, final HashMap map) {
      final MethodChannel channel = this.channel;
      runOnMainThread(new Runnable() {
         @Override
         public void run() {
            channel.invokeMethod(methodName, map);
         }
      });
   }
}
