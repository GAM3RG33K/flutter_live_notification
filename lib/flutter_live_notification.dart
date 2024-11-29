import 'package:flutter/foundation.dart';
import 'package:flutter_live_notification/src/live_activity_manager.dart';

import 'flutter_live_notification_platform_interface.dart';

class FlutterLiveNotification {
  Future<String?> getPlatformVersion() {
    return FlutterLiveNotificationPlatform.instance.getPlatformVersion();
  }

  final LiveActivityManager _liveActivityManager;
  FlutterLiveNotification._(
    this._liveActivityManager,
  );

  static final FlutterLiveNotification _singletonInstance =
      FlutterLiveNotification._(
    LiveActivityManager.getInstanceForPlatform(),
  );

  static FlutterLiveNotification getInstance() {
    return _singletonInstance;
  }

  static FlutterLiveNotification get I {
    return getInstance();
  }

  static final ValueNotifier<bool> _debugMode = ValueNotifier(kDebugMode);

  static set debugMode(bool v) => _debugMode.value = v;

  Future initialize({
    required String appIdPrefix,
    required String androidDefaultIcon,
  }) async {
    return _liveActivityManager.initialize(
      appIdPrefix: appIdPrefix,
      androidDefaultIcon: androidDefaultIcon,
    );
  }

  Future dispose() async {
    return _liveActivityManager.dispose();
  }

  Future<bool> get isServiceActive => _liveActivityManager.isServiceActive;

  Future startService() async => _liveActivityManager.startService();
  Future stopService() async => _liveActivityManager.stopService();

  Stream<LiveActivityEvent> get liveActivityEventStream =>
      _liveActivityManager.liveActivityEventStream;

  Future updateLiveActivity(LiveNotification notification) =>
      _liveActivityManager.updateLiveActivity(notification);
}
