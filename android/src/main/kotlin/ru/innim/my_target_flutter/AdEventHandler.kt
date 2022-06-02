package ru.innim.my_target_flutter

import io.flutter.plugin.common.EventChannel

class AdEventHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    fun sendAdEvent(id: String, event: String, data: Map<String, Any?>? = null) {
        sink?.success(
            mapOf(
                "uid" to id,
                "event" to event,
                "data" to data,
            )
        )
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}