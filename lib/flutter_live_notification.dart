import 'package:flutter/foundation.dart';
import 'package:flutter_live_notification/src/live_notification_manager.dart';
import 'src/manager/live_notification_event.dart';
import 'src/manager/live_notification.dart';

export 'src/manager/live_notification_event.dart';
export 'src/manager/live_notification.dart';

class FlutterLiveNotification {
  final LiveNotificationManager _liveNotificationManager;
  FlutterLiveNotification._(
    this._liveNotificationManager,
  );

  static final FlutterLiveNotification _singletonInstance =
      FlutterLiveNotification._(
    LiveNotificationManager(),
  );

  static FlutterLiveNotification getInstance() {
    return _singletonInstance;
  }

  static FlutterLiveNotification get I {
    return getInstance();
  }

  static final ValueNotifier<bool> _debugMode = ValueNotifier(kDebugMode);

  static set debugMode(bool v) => _debugMode.value = v;

  Future<String?> getPlatformVersion() {
    return _liveNotificationManager.getPlatformVersion();
  }

  Future<bool?> initialize({
    required String appIdPrefix,
    required String androidDefaultIcon,
  }) async {
    return _liveNotificationManager.initialize(
      appIdPrefix: appIdPrefix,
      androidDefaultIcon: androidDefaultIcon,
    );
  }

  Future<bool?> dispose() async {
    return _liveNotificationManager.dispose();
  }

  Future<bool> get isServiceActive => _liveNotificationManager.isServiceActive;

  Stream<LiveNotificationEvent> get liveNotificationEventStream =>
      _liveNotificationManager.liveNotificationEventStream;

  Future updateLiveNotification(LiveNotification notification) =>
      _liveNotificationManager.updateLiveNotification(notification);
  
  Future dismiss() =>_liveNotificationManager.dismiss();
}
