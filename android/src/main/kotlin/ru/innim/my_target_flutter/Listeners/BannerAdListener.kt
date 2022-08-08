package ru.innim.my_target_flutter

import com.my.target.ads.MyTargetView

class BannerAdListener(
        private val adEventHandler: AdEventHandler,
        private val id: String,
) : MyTargetView.MyTargetViewListener {
    companion object {
        private const val ACTION_AD_LOADED = "ad_loaded"
        private const val ACTION_NO_AD = "no_ad"
        private const val ACTION_CLICK_ON_AD = "click_on_ad"
        private const val ACTION_AD_SHOW = "ad_show"
    }

    override fun onLoad(ad: MyTargetView) {
        adEventHandler.sendAdEvent(id, ACTION_AD_LOADED)
    }
    override fun onNoAd(reason: String, ad: MyTargetView) {
        val data = mapOf("reason" to reason)
        adEventHandler.sendAdEvent(id, ACTION_NO_AD, data)
    }
    override fun onClick(ad: MyTargetView) {
        adEventHandler.sendAdEvent(id, ACTION_CLICK_ON_AD)
    }
    override fun onShow(ad: MyTargetView) {
        adEventHandler.sendAdEvent(id, ACTION_AD_SHOW)
    }
}
