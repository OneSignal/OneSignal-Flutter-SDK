package com.onesignal.flutter;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import com.onesignal.debug.internal.logging.Logging;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

abstract class FlutterMessengerResponder {
    private static final ExecutorService BACKGROUND_EXECUTOR = Executors.newSingleThreadExecutor(new ThreadFactory() {
        @Override
        public Thread newThread(Runnable runnable) {
            Thread thread = new Thread(runnable, "OneSignalFlutterBg");
            thread.setDaemon(true);
            return thread;
        }
    });

    Context context;
    protected MethodChannel channel;
    BinaryMessenger messenger;

    /**
     * #1138: bind the outgoing shared channel only on the first engine. These
     * responders are process-global singletons but {@code registerWith} runs once
     * per Flutter engine; FlutterFire's headless background engine would otherwise
     * rebind the channel to an isolate with no listeners and drop native callbacks.
     *
     * <p>The incoming-call handler is still registered on every engine's messenger
     * so Dart->Native calls work from any isolate (e.g. an FCM background handler),
     * matching the pre-#1138 behavior; only the outgoing Native->Dart channel stays
     * pinned to the first engine.
     *
     * @return true if this call performed the initial bind.
     */
    boolean bindChannelIfUnbound(BinaryMessenger messenger, String channelName, MethodCallHandler handler) {
        MethodChannel channel = new MethodChannel(messenger, channelName);
        channel.setMethodCallHandler(handler);
        if (this.channel != null) {
            return false;
        }
        this.messenger = messenger;
        this.channel = channel;
        return true;
    }

    /**
     * #1138: reassert the channel binding to the engine that hosts the activity (the
     * UI isolate), in case a background engine attached after us. No-op if the
     * messenger is unchanged.
     *
     * @return true if the channel was rebound to a different engine.
     */
    boolean rebindChannelToEngine(BinaryMessenger activityMessenger, String channelName, MethodCallHandler handler) {
        if (activityMessenger == null || activityMessenger == this.messenger) {
            return false;
        }
        this.messenger = activityMessenger;
        this.channel = new MethodChannel(activityMessenger, channelName);
        this.channel.setMethodCallHandler(handler);
        return true;
    }

    /**
     * MethodChannel class is home to success() method used by Result class
     * It has the @UiThread annotation and must be run on UI thread, otherwise a RuntimeException will be thrown
     * This will communicate success back to Dart
     */
    void replySuccess(final MethodChannel.Result reply, final Object response) {
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
    void replyError(final MethodChannel.Result reply, final String tag, final String message, final Object response) {
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
    void replyNotImplemented(final MethodChannel.Result reply) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                reply.notImplemented();
            }
        });
    }

    private void runOnMainThread(final Runnable runnable) {
        if (Looper.getMainLooper().getThread() == Thread.currentThread()) runnable.run();
        else {
            Handler handler = new Handler(Looper.getMainLooper());
            handler.post(runnable);
        }
    }

    void runOnBackgroundThread(final MethodChannel.Result result, final Runnable runnable) {
        BACKGROUND_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    runnable.run();
                } catch (Exception e) {
                    Logging.error("Encountered an error while handling a Flutter method call: " + e.toString(), e);
                    replyError(result, "OneSignal", e.getMessage(), null);
                }
            }
        });
    }

    void invokeMethodOnUiThread(final String methodName, final HashMap map) {
        // final MethodChannel channel = this.channel;
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                channel.invokeMethod(methodName, map);
            }
        });
    }
}
