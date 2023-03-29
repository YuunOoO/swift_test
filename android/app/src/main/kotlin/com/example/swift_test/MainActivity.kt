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
        val adv = Adv(context,activity,channel)


        channel.setMethodCallHandler {
                call, result ->
            if (call.method.equals("getBatteryLevel")) {
                adv.grantBluetoothPeripheralPermissions(Adv.AskType.InsistUntilSuccess){ print("wdym")}
                result.success("12");


            }else if(call.method.equals("send")){

                var message = call.argument("message") ?: "empty message"
                print("sending?");
                adv.bleIndicate(message)

            }else if(call.method.equals("getState")){

                result.success(adv.textViewConnectionState);
            }else if(call.method.equals("advertise")){
                //adv.bleStartAdvertising()
                 adv.prepareAndStartAdvertising();
                result.success("adv");
            }
            else {
                result.notImplemented();
            }
        }
    }




}
