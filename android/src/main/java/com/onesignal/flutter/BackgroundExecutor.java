// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.onesignal.flutter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterCallbackInformation;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * An background execution abstraction which handles initializing a background isolate running a
 * callback dispatcher, used to invoke Dart callbacks while backgrounded.
 */
public class BackgroundExecutor implements MethodCallHandler {
  private static final String TAG = "OneSignal - BackgroundExecutor";
  private static final String CHANNEL = "OneSignalBackground";
  private static final String OSK = "one_signal_key";
  private static final String CALLBACK_HANDLE_KEY = "callback_handle";
  private static final String USER_CALLBACK_HANDLE_KEY = "user_callback_handle";

  private static io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
      pluginRegistrantCallback;
  private final AtomicBoolean isCallbackDispatcherReady = new AtomicBoolean(false);
  /**
   * The {@link MethodChannel} that connects the Android side of this plugin with the background
   * Dart isolate that was created by this plugin.
   */
  private MethodChannel backgroundChannel;

  private FlutterEngine backgroundFlutterEngine;

  /**
   * Sets the {@code io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback} used to
   * register plugins with the newly spawned isolate.
   *
   * <p>Note: this is only necessary for applications using the V1 engine embedding API as plugins
   * are automatically registered via reflection in the V2 engine embedding API. If not set,
   * background message callbacks will not be able to utilize functionality from other plugins.
   */
  public static void setPluginRegistrant(
      io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback callback) {
    pluginRegistrantCallback = callback;
  }

  /**
   * Sets the Dart callback handle for the Dart method that is responsible for initializing the
   * background Dart isolate, preparing it to receive Dart callback tasks requests.
   */
  public static void setCallbackDispatcher(long callbackHandle) {
    Context context = ContextHolder.getApplicationContext();
    SharedPreferences prefs =
        context.getSharedPreferences(OSK, 0);
    prefs.edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    String method = call.method;
    try {
      if (method.equals("OneSignal#backgroundHandlerInitialized")) {
        // This message is sent by the background method channel as soon as the background isolate
        // is running. From this point forward, the Android side of this plugin can send
        // callback handles through the background method channel, and the Dart side will execute
        // the Dart methods corresponding to those callback handles.
        Log.i(TAG, "Background channel ready");

        result.success(true);
      } else {
        result.notImplemented();
      }
    } catch (Exception e) {
      result.error("error", "OneSignal error: " + e.getMessage(), null);
    }
  }

  /**
   * Returns true when the background isolate has started and is ready to handle background
   * messages.
   */
  public boolean isNotRunning() {
    return !isCallbackDispatcherReady.get();
  }

  private void onInitialized() {
    isCallbackDispatcherReady.set(true);
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine} using a previously
   * used entrypoint.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code io.flutter.view.FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method used the last time this plugin was initialized in the
   *       foreground.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given callback must correspond to a registered Dart callback. If the handle does not
   *       resolve to a Dart callback then this method does nothing.
   *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
   *       PluginRegistrantException} will be thrown.
   * </ul>
   */
  public void startBackgroundIsolate(IsolateStatusHandler isolate) {
    Log.i(TAG, "Starting background isolate.");
    if (isNotRunning()) {
      long callbackHandle = getPluginCallbackHandle();
      if (callbackHandle != 0) {
        startBackgroundIsolate(callbackHandle, null, isolate);
      }
    } else {
      Log.i(TAG, "Background isolate already started. Skipping..");
      Handler mainHandler = new Handler(Looper.getMainLooper());
      Runnable myRunnable = () -> { isolate.done(); };
      mainHandler.post(myRunnable);
    }
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine}.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code io.flutter.view.FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method represented by {@code callbackHandle}.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given {@code callbackHandle} must correspond to a registered Dart callback. If the
   *       handle does not resolve to a Dart callback then this method does nothing.
   *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
   *       PluginRegistrantException} will be thrown.
   * </ul>
   */
  public void startBackgroundIsolate(long callbackHandle, FlutterShellArgs shellArgs, IsolateStatusHandler isolate) {
    if (ContextHolder.getApplicationContext() == null) {
      Log.i(TAG, "ApplicationContext null when starting isolation");
      return;
    }
    if (backgroundFlutterEngine != null) {
      Log.i(TAG, "Background isolate already started.");
      Handler mainHandler = new Handler(Looper.getMainLooper());
      Runnable myRunnable = () -> { isolate.done(); };
      mainHandler.post(myRunnable);
      return;
    }
    if (!isNotRunning()) {
      return;
    }

    onInitialized();

    Handler mainHandler = new Handler(Looper.getMainLooper());
    Runnable myRunnable =
        () -> {
          io.flutter.view.FlutterMain.startInitialization(ContextHolder.getApplicationContext());
          io.flutter.view.FlutterMain.ensureInitializationCompleteAsync(
              ContextHolder.getApplicationContext(),
              null,
              mainHandler,
              () -> {
                String appBundlePath = io.flutter.view.FlutterMain.findAppBundlePath();
                AssetManager assets = ContextHolder.getApplicationContext().getAssets();
                if (shellArgs != null) {
                  Log.i(
                      TAG,
                      "Creating background FlutterEngine instance, with args: "
                          + Arrays.toString(shellArgs.toArray()));
                  backgroundFlutterEngine =
                      new FlutterEngine(
                          ContextHolder.getApplicationContext(), shellArgs.toArray());
                } else {
                  Log.i(TAG, "Creating background FlutterEngine instance.");
                  backgroundFlutterEngine =
                      new FlutterEngine(ContextHolder.getApplicationContext());
                }
                // We need to create an instance of `FlutterEngine` before looking up the
                // callback. If we don't, the callback cache won't be initialized and the
                // lookup will fail.
                FlutterCallbackInformation flutterCallback = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
                DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
                initializeMethodChannel(executor);
                DartCallback dartCallback = new DartCallback(assets, appBundlePath, flutterCallback);

                executor.executeDartCallback(dartCallback);

                // The pluginRegistrantCallback should only be set in the V1 embedding as
                // plugin registration is done via reflection in the V2 embedding.
                if (pluginRegistrantCallback != null) {
                  pluginRegistrantCallback.registerWith(
                      new ShimPluginRegistry(backgroundFlutterEngine));
                }
                
                isolate.done();
              });
        };
    mainHandler.post(myRunnable);
}

  boolean isDartBackgroundHandlerRegistered() {
    return getPluginCallbackHandle() != 0;
  }

  /**
   * Executes the desired Dart callback in a background Dart isolate.
   *
   * <p>The given {@code intent} should contain a {@code long} extra called "callbackHandle", which
   * corresponds to a callback registered with the Dart VM.
   */
  public void executeDartCallbackInBackgroundIsolate(final HashMap<String, Object> receivedMap) {
    if (backgroundFlutterEngine == null) {
      Log.i(
          TAG,
          "A background message could not be handled in Dart as no onBackgroundMessage handler has been registered.");
      return;
    }
    if (receivedMap != null) {
          Log.i(TAG, "Invoking OneSignal#onBackgroundNotification");
          backgroundChannel.invokeMethod(
            "OneSignal#onBackgroundNotification",
            new HashMap<String, Object>() {
              {
                put("notificationCallbackHandle", getUserCallbackHandle());
                put("message", receivedMap);
              }
            });
    } else {
      Log.e(TAG, "Notification not found.");
    }
  }

  /**
   * Get the users registered Dart callback handle for background messaging. Returns 0 if not set.
   */
  private long getUserCallbackHandle() {
    if (ContextHolder.getApplicationContext() == null) {
      return 0;
    }
    SharedPreferences prefs =
        ContextHolder.getApplicationContext()
            .getSharedPreferences(OSK, 0);
    return prefs.getLong(USER_CALLBACK_HANDLE_KEY, 0);
  }

  /**
   * Sets the Dart callback handle for the users Dart handler that is responsible for handling
   * messaging events in the background.
   */
  public static void setUserCallbackHandle(long callbackHandle) {
    Context context = ContextHolder.getApplicationContext();
    SharedPreferences prefs =
        context.getSharedPreferences(OSK, 0);
    prefs.edit().putLong(USER_CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  /** Get the registered Dart callback handle for the messaging plugin. Returns 0 if not set. */
  private long getPluginCallbackHandle() {
    if (ContextHolder.getApplicationContext() == null) {
      return 0;
    }
    SharedPreferences prefs =
        ContextHolder.getApplicationContext()
            .getSharedPreferences(OSK, 0);
    return prefs.getLong(CALLBACK_HANDLE_KEY, 0);
  }

  // This channel is responsible for sending requests from Android to Dart to execute Dart
  // callbacks in the background isolate.
  private void initializeMethodChannel(BinaryMessenger isolate) {
    backgroundChannel = new MethodChannel(isolate, CHANNEL);
    backgroundChannel.setMethodCallHandler(this);
  }
}