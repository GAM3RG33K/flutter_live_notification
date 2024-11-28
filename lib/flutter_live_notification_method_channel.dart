import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_live_notification_platform_interface.dart';

/// An implementation of [FlutterLiveNotificationPlatform] that uses method channels.
class MethodChannelFlutterLiveNotification extends FlutterLiveNotificationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_live_notification');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
