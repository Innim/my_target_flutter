package ru.innim.my_target_flutter

import android.content.Context
import android.view.View
import com.my.target.ads.MyTargetView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.UUID

class BannerAd(private val api: AdEventHandler) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String?, Any?>?
        val id: Int = params?.get("id").toString().toInt()

        return Banner(context!!, id, api)
    }
}

class Banner(context: Context, slotId: Int, AdHandler: AdEventHandler) : PlatformView {
    private val banner: MyTargetView

    init {
        banner =
                MyTargetView(context).also { myTargetView ->
                    myTargetView.setSlotId(slotId)

                    myTargetView.load()
                }
        val random = UUID.randomUUID()
        val id = "${slotId}_${random}"

        val listener =
                BannerAdListener(
                        AdHandler,
                        id,
                )
        banner.setListener(listener)
    }

    override fun getView(): View {
        return banner
    }

    override fun dispose() {
        banner.setListener(null)
    }
}
