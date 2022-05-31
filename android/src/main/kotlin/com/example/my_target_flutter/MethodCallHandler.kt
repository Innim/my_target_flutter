package com.example.my_target_flutter

import android.content.Context
import com.my.target.common.BaseAd
import com.my.target.common.MyTargetConfig
import com.my.target.common.MyTargetManager
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import com.my.target.ads.InterstitialAd as InterstitialAd


class MethodCallHandler(
    private val context: Context,
    private val adListenerChannel: BasicMessageChannel<String>
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val INITIAL = "initial"
        private const val CREATE_INTERSTITIAL_AD = "create_interstitial_ad"
        private const val LOAD = "load"
        private const val SHOW = "show"
        private const val errorCode = "my_target_flutter error:"
    }

    private val ads = mutableListOf<AdWithId>()
    private var isInitialised = false

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
                val id = call.arguments<String>("id")?.toString()
                load(result, id)
            }
            SHOW -> show(result)
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
            isInitialised = true
            result.success(true)
        } catch (e: Exception) {
            result.error(errorCode, " can not initialise", null)
        }

    }

    private fun createInterstitialAd(slotId: Int?, result: MethodChannel.Result) {
        if (slotId == null) {
            result.error(errorCode, " slotId cant be null", null)
        } else {
            val interstitialAd = InterstitialAd(slotId, context)
            val random = UUID.randomUUID()
            val id = "${slotId}_${random}"
            ads.add(AdWithId(interstitialAd, id))
            result.success(id)
//            val listener = AdListener(adListenerChannel)
//            interstitialAd.setListener(listener)
        }
    }

    private fun load(result: MethodChannel.Result, id: String?) {
        if (id == null) {
            result.error(errorCode, "id can not be null", null)
        } else {
            val ad = findAdById(id)
            if (ad == null) {
                result.error(errorCode, "can not find Ads for this id", "id: $id")
            } else {
                if (isInitialised) {
                    ad.load()
                    result.success(true)
                } else {
                    result.error(errorCode, "Ad not initialised", null)
                }
            }
        }
    }

    private fun show(result: MethodChannel.Result, id: String?) {
        if (id == null) {
            result.error(errorCode, "id can not be null", null)
        } else {
            val ad = findAdById(id)
            if (ad == null) {
                result.error(errorCode, "can not find Ads for this id", "id: $id")
            } else {
                if (isInitialised) {
                    ad.show()
                    result.success(true)
                } else {
                    result.error(errorCode, "Ad not initialised", null)
                }
            }
        }

    }

    private fun addListener(result: MethodChannel.Result, id: String) {
        if (isInitialised) {

        } else {
            result.error(errorCode, "Ad not initialised", null)
        }

    }

    private fun findAdById(id: String): InterstitialAd? {
        return ads.find { it.id == id }?.ad
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



