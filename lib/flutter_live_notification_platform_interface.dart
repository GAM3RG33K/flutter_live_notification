import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_live_notification_method_channel.dart';

abstract class FlutterLiveNotificationPlatform extends PlatformInterface {
  /// Constructs a FlutterLiveNotificationPlatform.
  FlutterLiveNotificationPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLiveNotificationPlatform _instance = MethodChannelFlutterLiveNotification();

  /// The default instance of [FlutterLiveNotificationPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterLiveNotification].
  static FlutterLiveNotificationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLiveNotificationPlatform] when
  /// they register themselves.
  static set instance(FlutterLiveNotificationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
