
import 'flutter_live_notification_platform_interface.dart';

class FlutterLiveNotification {
  Future<String?> getPlatformVersion() {
    return FlutterLiveNotificationPlatform.instance.getPlatformVersion();
  }
}
