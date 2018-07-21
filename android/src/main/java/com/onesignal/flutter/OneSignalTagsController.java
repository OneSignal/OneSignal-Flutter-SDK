package com.onesignal.flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.onesignal.OneSignal;
import com.onesignal.OneSignal.GetTagsHandler;
import com.onesignal.OneSignal.ChangeTagsUpdateHandler;
import com.onesignal.OneSignal.SendTagsError;

import org.json.JSONObject;
import org.json.JSONException;

import java.util.List;
import java.util.Map;

/**
 * Created by bradhesse on 7/17/18.
 */

class OSFlutterChangeTagsHandler implements ChangeTagsUpdateHandler {
    private Result result;

    OSFlutterChangeTagsHandler(Result res) {
        this.result = res;
    }

    @Override
    public void onSuccess(JSONObject tags) {
        try {
            this.result.success(OneSignalSerializer.convertJSONObjectToHashMap(tags));
        } catch (JSONException exception) {
            this.result.error("onesignal", "Encountered an error serializing tags into hashmap: " + exception.getMessage() + "\n" + exception.getStackTrace(), null);
        }
    }

    @Override
    public void onFailure(SendTagsError error) {
        this.result.error("onesignal", "Encountered an error updating tags (" + String.valueOf(error.getCode()) + "): " + error.getMessage(), null);
    }
}

public class OneSignalTagsController implements MethodCallHandler {
    private MethodChannel channel;

    public static void registerWith(Registrar registrar) {
        OneSignalTagsController controller = new OneSignalTagsController();
        controller.channel = new MethodChannel(registrar.messenger(), "OneSignal#tags");
        controller.channel.setMethodCallHandler(controller);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.contentEquals("OneSignal#getTags")) {
            final Result res = result;
            OneSignal.getTags(new GetTagsHandler() {
                @Override
                public void tagsAvailable(JSONObject tags) {
                    try {
                        res.success(OneSignalSerializer.convertJSONObjectToHashMap(tags));
                    } catch (JSONException exception) {
                        res.error("onesignal", "Encountered an error serializing tags into hashmap: " + exception.getMessage() + "\n" + exception.getStackTrace(), null);
                    }
                }
            });
        } else if (call.method.contentEquals("OneSignal#sendTags")) {
            OneSignal.sendTags(new JSONObject((Map<String, Object>) call.arguments), new OSFlutterChangeTagsHandler(result));
        } else if (call.method.contentEquals("OneSignal#deleteTags")
                ) {
            OneSignal.deleteTags((List<String>)call.arguments, new OSFlutterChangeTagsHandler(result));
        }
    }
}
