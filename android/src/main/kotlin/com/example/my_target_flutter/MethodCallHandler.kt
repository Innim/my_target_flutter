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


class MethodCallHandler(private val context: Context, private val adListenerChannel: BasicMessageChannel<String>) : MethodChannel.MethodCallHandler {
    companion object {
        private const val INITIAL = "initial"
        private const val LOAD = "load"
        private const val SHOW = "show"
    }

    private lateinit var ad: InterstitialAd
    private var isInitialised = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            INITIAL -> {
                val data = InitialData.fromArgs(call)
                if (data.slotId != null) {
                    val res =
                        initAd(context, data.slotId, data.useDebugMode ?: false, data.testDevises)
                    if(res) result.success(res)
                    else result.error("[my_target_flutter]", " can not initialise", null)
                }
            }
            LOAD -> load(result)
            SHOW -> show(result)
        }

    }

    private fun initAd(context: Context, slotId: Int, useDebugMode: Boolean, testDevises: String?): Boolean {
       try {
           MyTargetManager.initSdk( context)
           MyTargetManager.setDebugMode(useDebugMode)
           val configBuilder = MyTargetConfig.Builder().withTestDevices(testDevises).build()
           MyTargetManager.setSdkConfig(configBuilder)
           ad = InterstitialAd(slotId, context)
           val listener = AdListener(adListenerChannel)
           ad.setListener(listener)
       } catch (e: Exception) {
           return false
       }
        isInitialised = true
        return true
    }

    private fun load(result: MethodChannel.Result) {
        if(isInitialised) {
            ad.load()

            result.success(true)
        } else {
            result.error("Ad not initialised", null, null)
        }
    }

    private fun show(result: MethodChannel.Result) {
        if(isInitialised) {
            ad.show()
            result.success(true)
        } else {
            result.error("Ad not initialised", null, null)
        }

    }

    data class InitialData(
        val slotId: Int?,
        val useDebugMode: Boolean?,
        val testDevises: String?
    ) {
        companion object {
            fun fromArgs(call: MethodCall): InitialData {
                val slotId = call.argument<Int>("slotId")?.toInt()
                val useDebugMode = call.argument<Boolean>("useDebugMode") ?: false
                val testDevises = call.argument<String?>("testDevises")
                return InitialData(slotId, useDebugMode, testDevises)
            }
        }
    }

}
