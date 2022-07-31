package ru.innim.my_target_flutter

import android.content.Context
import com.my.target.ads.BaseInterstitialAd
import com.my.target.ads.InterstitialAd as InterstitialAd
import com.my.target.ads.RewardedAd as RewardedAd
import com.my.target.common.MyTargetConfig
import com.my.target.common.MyTargetManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MethodCallHandler(private val context: Context, private val adEventHandler: AdEventHandler) :
        MethodChannel.MethodCallHandler {
    companion object {
        private const val METHOD_INITIAL = "initialize"
        private const val METHOD_CREATE_INTERSTITIAL_AD = "createInterstitialAd"
        private const val METHOD_CREATE_REWARDED_AD = "createRewardedAd"
        private const val METHOD_LOAD = "load"
        private const val METHOD_SHOW = "show"
        private const val ERROR_CODE_INVALID_ARGS = "INVALID_ARGS"
        private const val ERROR_CODE_NOT_FOUND = "ADS_NOT_FOUND"
        private const val ERROR_MESSAGE_INVALID_ARGS = "value cant be null"
    }

    private val ads = mutableListOf<IndexedAd>()

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
            METHOD_CREATE_REWARDED_AD -> {
                val slotId = call.argument<Int>("slotId")?.toInt()
                createRewardedAd(slotId, result)
            }
            METHOD_CREATE_BANNER_AD -> {
                val slotId = call.argument<Int>("slotId")?.toInt()

                createBannerAd(slotId, result)
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
            val listener = InterstitialAdListener(adEventHandler, id) { clear(it) }
            interstitialAd.setListener(listener)
            ads.add(IndexedAd(interstitialAd, id))
            result.success(id)
        }
    }

    private fun createRewardedAd(slotId: Int?, result: MethodChannel.Result) {
        if (slotId == null) {
            result.error(ERROR_CODE_INVALID_ARGS, ERROR_MESSAGE_INVALID_ARGS, "slotId: $slotId")
        } else {
            val rewardedAd = RewardedAd(slotId, context)
            val random = UUID.randomUUID()
            val id = "${slotId}_${random}"
            val listener = RewardedAdListener(adEventHandler, id) { clear(it) }
            rewardedAd.setListener(listener)
            ads.add(IndexedAd(rewardedAd, id))
            result.success(id)
        }
    }

    private fun load(result: MethodChannel.Result, id: String?) {
        findAdById(result, id) { it.load() }
    }

    private fun show(result: MethodChannel.Result, id: String?) {
        findAdById(result, id) { it.show() }
    }

    private fun clear(id: String) {
        val ad = ads.find { it.id == id }
        ads.remove(ad)
        ad?.ad?.destroy()
    }

    private fun findAdById(
            result: MethodChannel.Result,
            id: String?,
            action: (ad: BaseInterstitialAd) -> Unit
    ) {
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

    data class InitialData(val useDebugMode: Boolean, val testDevices: String?) {
        companion object {
            fun fromArgs(call: MethodCall): InitialData {
                val useDebugMode = call.argument<Boolean>("useDebugMode") ?: false
                val testDevices = call.argument<String?>("testDevices")
                return InitialData(useDebugMode, testDevices)
            }
        }
    }
    data class IndexedAd(var ad: BaseInterstitialAd, val id: String)
}
