package com.onesignal.flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.onesignal.OneSignal;
import com.onesignal.OneSignal.GetTagsHandler;
import com.onesignal.OneSignal.ChangeTagsUpdateHandler;
import com.onesignal.OneSignal.SendTagsError;

import org.json.JSONObject;
import org.json.JSONException;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by bradhesse on 7/17/18.
 */

class OSFlutterChangeTagsHandler extends FlutterRegistrarResponder implements ChangeTagsUpdateHandler, GetTagsHandler {
    private Result result;

    // the tags callbacks can in some instances be called more than once
    // ie. cached vs. server response.
    // this property guarantees the callback will never be called more than once.
    private AtomicBoolean replySubmitted = new AtomicBoolean(false);

    OSFlutterChangeTagsHandler(PluginRegistry.Registrar flutterRegistrar, MethodChannel channel, Result res) {
        this.flutterRegistrar = flutterRegistrar;
        this.channel = channel;
        this.result = res;
    }

    @Override
    public void onSuccess(JSONObject tags) {
        if (this.replySubmitted.getAndSet(true))
            return;

        try {
            replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(tags));
        } catch (JSONException exception) {
            replyError(result, "onesignal", "Encountered an error serializing tags into hashmap: " + exception.getMessage() + "\n" + exception.getStackTrace(), null);
        }
    }

    @Override
    public void onFailure(SendTagsError error) {
        if (this.replySubmitted.getAndSet(true))
            return;

        replyError(result,"onesignal","Encountered an error updating tags (" + error.getCode() + "): " + error.getMessage(), null);
    }

    @Override
    public void tagsAvailable(JSONObject jsonObject) {
        if (this.replySubmitted.getAndSet(true))
            return;

        try {
            replySuccess(result, OneSignalSerializer.convertJSONObjectToHashMap(jsonObject));
        } catch (JSONException exception) {
            replyError(result, "onesignal", "Encountered an error serializing tags into hashmap: " + exception.getMessage() + "\n" + exception.getStackTrace(), null);
        }
    }
}

public class OneSignalTagsController implements MethodCallHandler {
    private MethodChannel channel;
    private Registrar registrar;

    static void registerWith(Registrar registrar) {
        OneSignalTagsController controller = new OneSignalTagsController();
        controller.registrar = registrar;
        controller.channel = new MethodChannel(registrar.messenger(), "OneSignal#tags");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#getTags"))
            OneSignal.getTags(new OSFlutterChangeTagsHandler(registrar, channel, result));
        else if (call.method.contentEquals("OneSignal#sendTags"))
            OneSignal.sendTags(new JSONObject((Map<String, Object>) call.arguments), new OSFlutterChangeTagsHandler(registrar, channel, result));
        else if (call.method.contentEquals("OneSignal#deleteTags"))
            OneSignal.deleteTags((List<String>)call.arguments, new OSFlutterChangeTagsHandler(registrar, channel, result));
    }
}
