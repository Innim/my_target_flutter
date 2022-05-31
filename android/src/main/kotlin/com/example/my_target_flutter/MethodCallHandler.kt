package com.example.my_target_flutter

import android.content.Context
import com.my.target.ads.InterstitialAd
import com.my.target.ads.InterstitialAd.InterstitialAdListener
import com.my.target.common.MyTargetConfig
import com.my.target.common.MyTargetManager
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*


class MethodCallHandler(
    private val context: Context,
    private val adListenerChannel: BasicMessageChannel<String>
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val INITIAL = "initial"
        private const val LOAD = "load"
        private const val SHOW = "show"
        private const val errorCode = "my_target_flutter error:"
    }

    private lateinit var ad: InterstitialAd
    private var isInitialised = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            INITIAL -> {
                val data = InitialData.fromArgs(call)
                initAd(context, data.slotId, data.useDebugMode ?: false, data.testDevices, result)

            }
            LOAD -> load(result)
            SHOW -> show(result)
        }

    }

    private fun initAd(
        context: Context,
        slotId: Int?,
        useDebugMode: Boolean,
        testDevices: String?,
        result: MethodChannel.Result,
    ) {
        if (slotId == null) {
            result.error(errorCode, " slotId cant be null", null)
        } else {
            try {
                MyTargetManager.initSdk(context)
                MyTargetManager.setDebugMode(useDebugMode)
                val configBuilder = MyTargetConfig.Builder().withTestDevices(testDevices).build()
                MyTargetManager.setSdkConfig(configBuilder)
                ad = InterstitialAd(slotId, context)
                val listener = AdListener(adListenerChannel)
                ad.setListener(listener)
                isInitialised = true
                result.success(true)
            } catch (e: Exception) {
                result.error(errorCode, " can not initialise", null)
            }
        }

    }

    private fun load(result: MethodChannel.Result) {
        if (isInitialised) {
            ad.load()

            result.success(true)
        } else {
            result.error(errorCode, "Ad not initialised", null)
        }
    }

    private fun show(result: MethodChannel.Result) {
        if (isInitialised) {
            ad.show()
            result.success(true)
        } else {
            result.error(errorCode,"Ad not initialised", null)
        }

    }

    data class InitialData(
        val slotId: Int?,
        val useDebugMode: Boolean?,
        val testDevices: String?
    ) {
        companion object {
            fun fromArgs(call: MethodCall): InitialData {
                val slotId = call.argument<Int>("slotId")?.toInt()
                val useDebugMode = call.argument<Boolean>("useDebugMode") ?: false
                val testDevices = call.argument<String?>("testDevices")
                return InitialData(slotId, useDebugMode, testDevices)
            }
        }
    }

}
