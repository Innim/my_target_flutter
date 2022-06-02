package ru.innim.my_target_flutter

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
        private const val METHOD_INITIAL = "initialize"
        private const val METHOD_CREATE_INTERSTITIAL_AD = "createInterstitialAd"
        private const val METHOD_LOAD = "load"
        private const val METHOD_SHOW = "show"
        private const val ERROR_CODE_INVALID_ARGS = "INVALID_ARGS"
        private const val ERROR_CODE_NOT_FOUND = "ADS_NOT_FOUND"
        private const val ERROR_MESSAGE_INVALID_ARGS = "value cant be null"

    }

    private val ads = mutableListOf<AdWithId>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_INITIAL -> {
                val data = InitialData.fromArgs(call)
                initAd(context, data.useDebugMode, data.testDevices, result)
            }
            METHOD_CREATE_INTERSTITIAL_AD -> {
                val slotId = call.argument<Int>("slotId")?.toInt()
                createInterstitialAd(slotId, result)
            }
            METHOD_LOAD -> {
                val id = call.arguments.toString()
                load(result, id)
            }
            METHOD_SHOW -> {
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
        MyTargetManager.initSdk(context)
        MyTargetManager.setDebugMode(useDebugMode)
        if (testDevices != null && testDevices.isNotEmpty()) {
            val configBuilder = MyTargetConfig.Builder().withTestDevices(testDevices).build()
            MyTargetManager.setSdkConfig(configBuilder)
        }
        result.success(true)
    }

    private fun createInterstitialAd(slotId: Int?, result: MethodChannel.Result) {
        if (slotId == null) {
            result.error(ERROR_CODE_INVALID_ARGS, ERROR_MESSAGE_INVALID_ARGS, "slotId: $slotId")
        } else {
            val interstitialAd = InterstitialAd(slotId, context)
            val random = UUID.randomUUID()
            val id = "${slotId}_${random}"
            val listener = AdListener(adEventHandler, id) { clear(it) }
            interstitialAd.setListener(listener)
            ads.add(AdWithId(interstitialAd, id))
            result.success(id)
        }
    }

    private fun load(result: MethodChannel.Result, id: String?) {
        findAdById(result, id) { it.load() }
    }

    private fun show(result: MethodChannel.Result, id: String?) {
        findAdById(result, id) {  it.show() }

    }

    private fun clear(id: String) {
        val ad = ads.find { it.id == id }
        ad?.ad?.setListener(null)
        ads.remove(ad)
    }

    private fun findAdById(result: MethodChannel.Result, id: String?, action: (ad:InterstitialAd) -> Unit) {
        if (id == null) {
            result.error(ERROR_CODE_INVALID_ARGS, ERROR_MESSAGE_INVALID_ARGS, "id: $id")
        } else {
            val ad = ads.find { it.id == id }?.ad
            if (ad == null) {
                result.error(ERROR_CODE_NOT_FOUND, "ads not found", "id: $id")
            } else {
                return action(ad)
            }
        }
    }

    data class InitialData(
        val useDebugMode: Boolean,
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

    data class AdWithId(
        var ad: InterstitialAd,
        val id: String
    )

}



