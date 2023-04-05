package com.example.swift_test

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)
        val channelAdvertise = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.exampleDL.swiftTest/advertise")
        val channelScan = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.exampleDL.swiftTest/scan")
        val advertise = Advertise(context,activity,channelAdvertise)
        val scan = Scan(context,activity,channelScan)

        channelAdvertise.setMethodCallHandler {
                call, result ->
            if(call.method.equals("sendMessage")){
                val message = call.argument("message") ?: "empty message"
                advertise.bleIndicate(message)
            }else if(call.method.equals("getState")){
                result.success(advertise.textViewConnectionState)
            }else if(call.method.equals("advertise")){
                advertise.prepareAndStartAdvertising()
            } else if(call.method.equals("stopAdvertising")){
                advertise.bleStopAdvertising()
            } else {
                result.notImplemented()
            }
        }

        channelScan.setMethodCallHandler {
                call, result ->
            if (call.method.equals("init")) {
                scan.prepareAndStartBleScan()
            }else if(call.method.equals("sendMessage")){
                val message = call.argument("message") ?: "empty message"
                scan.onTapWrite(message)
            }else if(call.method.equals("getState")){
                result.success(scan.lifecycleState)
            }else if(call.method.equals("scan")){
                scan.safeStartBleScan()
                result.success("scan")
            }else if(call.method.equals("stopScan")){
                scan.bleEndLifecycle()
            }
            else {
                result.notImplemented()
            }
        }
    }
}
