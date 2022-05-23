package com.example.my_target_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StringCodec


/** MyTargetFlutterPlugin */
class MyTargetFlutterPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val  CHANNEL_NAME = "my_target_flutter"
        private const val AD_LISTENER_CHANNEL_NAME = "my_target_flutter/ad_listener"
    }


    private lateinit var adListenerChannel:BasicMessageChannel<String>
    private  lateinit var dartChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger: BinaryMessenger = binding.binaryMessenger
         dartChannel = MethodChannel(
            messenger,
            CHANNEL_NAME,
        )
         val context = binding.applicationContext
         adListenerChannel = BasicMessageChannel(
            messenger, AD_LISTENER_CHANNEL_NAME, StringCodec.INSTANCE)
         val methodCallHandler = MethodCallHandler(context, adListenerChannel)
        dartChannel.setMethodCallHandler(methodCallHandler)

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {
        dartChannel.setMethodCallHandler(null)
        adListenerChannel.setMessageHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }


}
