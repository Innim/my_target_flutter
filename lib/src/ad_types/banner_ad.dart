import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_target_flutter/src/ad_status_listener.dart';
import 'package:my_target_flutter/src/extensions.dart';
import 'package:my_target_flutter/src/my_target_flutter.dart';

class BannerAd extends StatefulWidget {
  const BannerAd(this._plugin, this.uid, {Key? key, this.listener}) : super(key: key);
  final MyTargetFlutter _plugin;
  final String uid;
  final AdStatusListener? listener;

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with AutomaticKeepAliveClientMixin {
  final _listeners = <AdStatusListener>{};

  @override
  void initState() {
    super.initState();
    if (widget.listener != null) _listeners.add(widget.listener!);
    widget._plugin.adListenStream.listen(_handleMessage);
  }

  Future<void> _handleMessage(AdEventMessage data) async {
    if (data.uid == widget.uid) {
      _listeners.handleEvent(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'mytarget-banner-ad';

    final creationParams = <String, dynamic>{
      'id': widget.uid,
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
