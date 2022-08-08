package ru.innim.my_target_flutter

import com.my.target.ads.Reward
import com.my.target.ads.RewardedAd

class RewardedAdListener(
        private val adEventHandler: AdEventHandler,
        private val id: String,
        private val onDone: (id: String) -> Unit
) : RewardedAd.RewardedAdListener {
    companion object {
        private const val ACTION_AD_LOADED = "ad_loaded"
        private const val ACTION_AD_REWARD = "ad_reward"
        private const val ACTION_NO_AD = "no_ad"
        private const val ACTION_CLICK_ON_AD = "click_on_ad"
        private const val ACTION_AD_DISPLAY = "ad_display"
        private const val ACTION_AD_DISMISS = "ad_dismiss"
    }

    override fun onLoad(ad: RewardedAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_LOADED)
    }
    override fun onNoAd(reason: String, ad: RewardedAd) {
        val data = mapOf("reason" to reason)
        adEventHandler.sendAdEvent(id, ACTION_NO_AD, data)
        onDone.invoke(id)
    }
    override fun onClick(ad: RewardedAd) {
        adEventHandler.sendAdEvent(id, ACTION_CLICK_ON_AD)
    }
    override fun onReward(reward: Reward, ad: RewardedAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_REWARD)
    }
    override fun onDisplay(ad: RewardedAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_DISPLAY)
    }
    override fun onDismiss(ad: RewardedAd) {
        adEventHandler.sendAdEvent(id, ACTION_AD_DISMISS)
        onDone.invoke(id)
    }
}
