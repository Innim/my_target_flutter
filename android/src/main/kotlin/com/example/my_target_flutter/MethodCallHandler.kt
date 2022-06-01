package com.example.my_target_flutter

import android.content.Context
import com.my.target.common.MyTargetConfig
import com.my.target.common.MyTargetManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import com.my.target.ads.InterstitialAd as InterstitialAd


class MethodCallHandler(
    private val context: Context,
    private val adEventHandler: AdEventHandler
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val INITIAL = "initial"
        private const val CREATE_INTERSTITIAL_AD = "createInterstitialAd"
        private const val LOAD = "load"
        private const val SHOW = "show"
        private const val errorCode = "my_target_flutter_error:"
    }

    private val ads = mutableListOf<AdWithId>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            INITIAL -> {
                val data = InitialData.fromArgs(call)
                initAd(context, data.useDebugMode ?: false, data.testDevices, result)
            }
            CREATE_INTERSTITIAL_AD -> {
                val slotId = call.argument<Int>("slotId")?.toInt()
                createInterstitialAd(slotId, result)
            }
            LOAD -> {
                val id = call.arguments.toString()
                load(result, id)
            }
            SHOW -> {
                val id = call.arguments.toString()
                show(result, id)
            }
        }

    }

    private fun initAd(
        context: Context,
        useDebugMode: Boolean,
        testDevices: String?,
        result: MethodChannel.Result,
    ) {
        try {
            MyTargetManager.initSdk(context)
            MyTargetManager.setDebugMode(useDebugMode)
            val configBuilder = MyTargetConfig.Builder().withTestDevices(testDevices).build()
            MyTargetManager.setSdkConfig(configBuilder)
            result.success(true)
        } catch (e: Exception) {
            result.error(errorCode, " can not initialize", null)
        }

    }

    private fun createInterstitialAd(slotId: Int?, result: MethodChannel.Result) {
        if (slotId == null) {
            result.error(errorCode, " slotId cant be null", null)
        } else {
            val interstitialAd = InterstitialAd(slotId, context)
            val random = UUID.randomUUID()
            val id = "${slotId}_${random}"
            val listener = AdListener(adEventHandler, id) { id: String -> clear(id) }
            interstitialAd.setListener(listener)
            ads.add(AdWithId(interstitialAd, id))
            result.success(id)
        }
    }

    private fun load(result: MethodChannel.Result, id: String?) {
        val ad = findAdById(result, id)
        ad?.load()
    }

    private fun show(result: MethodChannel.Result, id: String?) {
        val ad = findAdById(result, id)
        ad?.show()
    }

    private fun clear(id: String) {
        val ad = ads.find { it.id == id }
        ads.remove(ad)
    }

    private fun findAdById(result: MethodChannel.Result, id: String?): InterstitialAd? {
        if (id == null) {
            result.error(errorCode, "id can not be null", null)
        } else {
            val ad = ads.find { it.id == id }?.ad
            if (ad == null) {
                result.error(errorCode, "ads not found", "id: $id")
            } else {
                return ad
            }
        }
        return null
    }

    data class InitialData(
        val useDebugMode: Boolean?,
        val testDevices: String?
    ) {
        companion object {
            fun fromArgs(call: MethodCall): InitialData {
                val useDebugMode = call.argument<Boolean>("useDebugMode") ?: false
                val testDevices = call.argument<String?>("testDevices")
                return InitialData(useDebugMode, testDevices)
            }
        }
    }

    data class AdWithId
        (
        var ad: InterstitialAd,
        val id: String
    )

}



