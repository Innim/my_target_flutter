package com.example.my_target_flutter
import com.my.target.ads.InterstitialAd


class AdListener(private val adEventHandler: AdEventHandler, private val id: String) : InterstitialAd.InterstitialAdListener {
    companion object{
        private const val ACTION_AD_LOADED = "ad_loaded"
        private const val ACTION_NO_AD = "no_ad"
        private const val ACTION_CLICK_ON_AD = "click_on_ad"
        private const val ACTION_AD_DISPLAY = "ad_display"
        private const val ACTION_AD_DISMISS = "ad_dismiss"
        private const val ACTION_AD_VIDEO_COMPLETED = "ad_video_completed"
    }

    override fun onLoad(ad: InterstitialAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_LOADED)
    }
    override fun onNoAd(reason: String, ad: InterstitialAd) {
        val data = mapOf("reason" to reason)
        adEventHandler.sendAdEvent(id, ACTION_NO_AD, data)
    }
    override fun onClick(ad: InterstitialAd) {
        adEventHandler.sendAdEvent(id,ACTION_CLICK_ON_AD)
    }
    override fun onDisplay(ad: InterstitialAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_DISPLAY)
    }
    override fun onDismiss(ad: InterstitialAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_DISMISS)
    }
    override fun onVideoCompleted(ad: InterstitialAd) {
        adEventHandler.sendAdEvent(id,ACTION_AD_VIDEO_COMPLETED)
    }

}