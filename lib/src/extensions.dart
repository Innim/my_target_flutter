import 'ad_status_listener.dart';

extension SetAdStatusListenerExtensionX on Set<AdStatusListener> {
  void handleEvent(AdEventMessage data) {
    var listeners = toList();
    for (final listener in listeners) {
      listener.handleEvent(data);
    }
  }
}
