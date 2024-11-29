import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_live_notification/src/impl/ios_live_activity_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_activities/live_activities.dart';

import 'impl/android_live_activity_manager.dart';

class LiveNotification {
  final String title;
  final String message;
  final Map<String, dynamic>? payload;

  const LiveNotification({
    required this.title,
    required this.message,
    this.payload,
  });

  factory LiveNotification.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final message = json['message'] as String;
    final payload = json['payload'] as Map<String, dynamic>?;

    return LiveNotification(
      title: title,
      message: message,
      payload: payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'payload': payload,
    };
  }
}

enum LiveAcitivityEventType {
  create,
  update,
  destroy,
}

class LiveActivityEvent<T> {
  final T? id;
  final LiveAcitivityEventType type;
  final LiveNotification? notification;

  const LiveActivityEvent({
    required this.id,
    required this.type,
    this.notification,
  });
  factory LiveActivityEvent.create(T? id, [LiveNotification? notification]) {
    return LiveActivityEvent(
      id: id,
      type: LiveAcitivityEventType.create,
      notification: notification,
    );
  }

  factory LiveActivityEvent.update(T? id, [LiveNotification? notification]) {
    return LiveActivityEvent(
      id: id,
      type: LiveAcitivityEventType.update,
      notification: notification,
    );
  }

  factory LiveActivityEvent.destroy(T? id, [LiveNotification? notification]) {
    return LiveActivityEvent(
      id: id,
      type: LiveAcitivityEventType.destroy,
      notification: notification,
    );
  }
}

abstract class LiveActivityManager<T> {
  final ValueNotifier<bool> isServiceActiveNotifier = ValueNotifier(false);

  /// App ID Prefix used to create notification and Live activity channel identifiers
  String? appIdPrefix;

  // Android ONLY : Default icon name. i.e.: ic_launcher
  String? defaultIcon;

  /// The liveActivity notification id notifier
  final ValueNotifier<T?> _liveActivityIdNotifier = ValueNotifier(null);

  T? get liveActivityId => _liveActivityIdNotifier.value;

  final StreamController<LiveActivityEvent<T>> liveActivityEventBroadcast =
      StreamController.broadcast();

  static LiveActivityManager getInstanceForPlatform() {
    switch (Platform.operatingSystem) {
      case "ios":
        return IosLiveActivityManager(
          liveActivitiesPlugin: LiveActivities(),
        );
      case "android":
        return AndroidLiveActivityManager(
          localNotificationsPlugin: FlutterLocalNotificationsPlugin(),
        );

      default:
        throw UnimplementedError(
          'Platform ${Platform.operatingSystem} has not assigned Live Activity Manager',
        );
    }
  }

  /// Direct Implementations
  Future<bool> get isServiceActive async => isServiceActiveNotifier.value;

  Stream<LiveActivityEvent<T>> get liveActivityEventStream =>
      liveActivityEventBroadcast.stream;

  void addStatusListener(ValueChanged<bool> listener) {
    isServiceActiveNotifier.addListener(
      () => listener(isServiceActiveNotifier.value),
    );
  }

  void removeStatusListener(ValueChanged<bool> listener) {
    isServiceActiveNotifier.removeListener(
      () => listener(isServiceActiveNotifier.value),
    );
  }

  Future dispose() async {
    return liveActivityEventBroadcast.close();
  }

  void logActivity(
    T? activityId,
    LiveAcitivityEventType type, {
    LiveNotification? notification,
  }) {
    // Log live activity event
    final event = LiveActivityEvent(
      id: activityId,
      type: type,
      notification: notification,
    );

    liveActivityEventBroadcast.sink.add(event);
  }

  /// Platform Implementations
  @mustCallSuper
  Future initialize({
    required String appIdPrefix,
    required String androidDefaultIcon,
    String? iOSUrlScheme,
  }) async {
    appIdPrefix = appIdPrefix;
    defaultIcon = defaultIcon;
  }

  Map<String, dynamic> encodeData(LiveNotification model);
  LiveNotification decodeData(Map<String, dynamic> json);

  @mustCallSuper
  Future startService() async {
    assert(
      appIdPrefix != null && appIdPrefix!.isNotEmpty,
      'Must call initialize() before starting the live activity service',
    );
    isServiceActiveNotifier.value = true;
  }

  @mustCallSuper
  Future stopService() async {
    logActivity(
      liveActivityId,
      LiveAcitivityEventType.destroy,
    );
    isServiceActiveNotifier.value = false;
  }

  @mustCallSuper
  Future<T?> updateLiveActivity(
    LiveNotification notification,
  ) async {
    if (liveActivityId == null) {
      final result = await createLiveActivity(notification);

      if (result == null) return null;
      _liveActivityIdNotifier.value = result;

      logActivity(
        liveActivityId,
        LiveAcitivityEventType.create,
        notification: notification,
      );
      // return id to indicate that the live activity has been created
      // no need to update content for now
      return result;
    }

    logActivity(
      liveActivityId,
      LiveAcitivityEventType.update,
      notification: notification,
    );
    // return null to indicate that update operation can proceed,
    return null;
  }

  Future<T?> createLiveActivity(LiveNotification notification);
}
