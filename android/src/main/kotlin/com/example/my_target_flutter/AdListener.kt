package com.example.my_target_flutter

import com.my.target.ads.InterstitialAd
import io.flutter.plugin.common.BasicMessageChannel

class AdListener( private val adListenerChannel: BasicMessageChannel<String>) : InterstitialAd.InterstitialAdListener {

    companion object{
        private const val ACTION_AD_LOADED = "ad_loaded"
        private const val ACTION_NO_AD = "no_ad"
        private const val ACTION_CLICK_ON_AD = "click_on_ad"
        private const val ACTION_AD_DISPLAY = "ad_display"
        private const val ACTION_AD_DISMISS = "ad_dismiss"
        private const val ACTION_AD_VIDEO_COMPLETED = "ad_video_completed"
    }

    override fun onLoad(ad: InterstitialAd) {
        adListenerChannel.send(ACTION_AD_LOADED)
    }
    override fun onNoAd(reason: String, ad: InterstitialAd) {
        adListenerChannel.send(ACTION_NO_AD)
    }
    override fun onClick(ad: InterstitialAd) {
        adListenerChannel.send(ACTION_CLICK_ON_AD)
    }
    override fun onDisplay(ad: InterstitialAd) {
        adListenerChannel.send(ACTION_AD_DISPLAY)
    }
    override fun onDismiss(ad: InterstitialAd) {
        adListenerChannel.send(ACTION_AD_DISMISS)
    }
    override fun onVideoCompleted(ad: InterstitialAd) {
        adListenerChannel.send(ACTION_AD_VIDEO_COMPLETED)
    }
}