package com.example.swift_test


import Adv
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.os.Bundle
import android.util.Log
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.exampleDL.swiftTest/battery")
        val channelScan = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.exampleDL.swiftTest/scan")
        val adv = Adv(context,activity,channel)
        val scan = Scan(context,activity,channelScan)

        channel.setMethodCallHandler {
                call, result ->
            if (call.method.equals("getBatteryLevel")) {
                result.success("12");
            }else if(call.method.equals("send")){
                var message = call.argument("message") ?: "empty message"
                adv.bleIndicate(message)
            }else if(call.method.equals("getState")){
                result.success(adv.textViewConnectionState);
            }else if(call.method.equals("advertise")){
                 adv.prepareAndStartAdvertising();
                result.success("adv");
            }
            else {
                result.notImplemented();
            }
        }


        channelScan.setMethodCallHandler {
                call, result ->
            if (call.method.equals("init")) {
                scan.prepareAndStartBleScan()
            }else if(call.method.equals("send")){
                var message = call.argument("message") ?: "empty message"
                scan.onTapWrite(message)

            }else if(call.method.equals("getState")){
                result.success(scan.lifecycleState);
            }else if(call.method.equals("scan")){
                scan.safeStartBleScan()
                result.success("scan");
            }
            else {
                result.notImplemented();
            }
        }
    }
}
