package com.onesignal.onesignalexample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

open class MainActivity: FlutterActivity() {

    companion object {
        @JvmStatic
        var flutterEngineInstance: FlutterEngine? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineInstance = flutterEngine
    }

}
