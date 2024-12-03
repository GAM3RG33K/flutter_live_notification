import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'manager/live_notification_event.dart';
import 'manager/live_notification.dart';

class LiveNotificationManager<T> {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel;

  final ValueNotifier<bool> isServiceActiveNotifier = ValueNotifier(false);

  /// App ID Prefix used to create notification and Live notification channel identifiers
  String? appIdPrefix;

  // Android ONLY : Default icon name. i.e.: ic_launcher
  String? defaultIcon;

  /// The LiveNotification notification id notifier
  final ValueNotifier<T?> _liveNotificationIdNotifier = ValueNotifier(null);

  T? get liveNotificationId => _liveNotificationIdNotifier.value;

  final StreamController<LiveNotificationEvent<T>>
      liveNotificationEventBroadcast = StreamController.broadcast();

  LiveNotificationManager({
    this.methodChannel = const MethodChannel('flutter_live_notification'),
  });

  /// Direct Implementations
  Future<bool> get isServiceActive async {
    print(
        '[isServiceActive] Checking if service is active: ${isServiceActiveNotifier.value}');
    return isServiceActiveNotifier.value;
  }

  Stream<LiveNotificationEvent<T>> get liveNotificationEventStream {
    print(
        '[liveNotificationEventStream] Subscribing to live notification event stream.');
    return liveNotificationEventBroadcast.stream;
  }

  void addStatusListener(ValueChanged<bool> listener) {
    print('[addStatusListener] Adding status listener.');
    isServiceActiveNotifier.addListener(
      () => listener(isServiceActiveNotifier.value),
    );
  }

  void removeStatusListener(ValueChanged<bool> listener) {
    print('[removeStatusListener] Removing status listener.');
    isServiceActiveNotifier.removeListener(
      () => listener(isServiceActiveNotifier.value),
    );
  }

  void logActivity(
    T? notificationId,
    LiveAcitivityEventType type, {
    LiveNotification? notification,
  }) {
    print(
        '[logActivity] Logging live notification event. ID: $notificationId, Type: $type, Notification: $notification');

    // Log live notification event
    final event = LiveNotificationEvent(
      id: notificationId,
      type: type,
      notification: notification,
    );

    liveNotificationEventBroadcast.sink.add(event);
  }

  Future<String?> getPlatformVersion() async {
    print(
        '[getPlatformVersion] Requesting platform version from native platform.');
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<bool?> dispose() async {
    print(
        '[dispose] Disposing live notification manager and closing broadcast stream.');
    await liveNotificationEventBroadcast.close();
    return methodChannel.invokeMethod<bool>('dispose');
  }

  /// Platform Implementations
  Future<bool?> initialize({
    required String appIdPrefix,
    required String androidDefaultIcon,
    String? iOSUrlScheme,
  }) async {
    print(
        '[initialize] Initializing with appIdPrefix: $appIdPrefix, androidDefaultIcon: $androidDefaultIcon, iOSUrlScheme: $iOSUrlScheme');

    this.appIdPrefix = appIdPrefix;
    defaultIcon = androidDefaultIcon;

    return methodChannel.invokeMethod<bool>('initialize');
  }

  Map<String, dynamic> encodeData(LiveNotification model) {
    print('[encodeData] Encoding data for notification: ${model.toJson()}');
    return model.toJson();
  }

  @mustCallSuper
  Future<bool?> startService() async {
    print('[startService] Starting live notification service.');
    assert(
      appIdPrefix != null && appIdPrefix!.isNotEmpty,
      'Must call initialize() before starting the live notification service',
    );
    isServiceActiveNotifier.value = true;

    final response = await methodChannel.invokeMethod<bool>(
      'startService',
    );
    print(
        '[startService] Live notification service started with response: $response');
    return response;
  }

  @mustCallSuper
  Future<bool?> stopService() async {
    print('[stopService] Stopping live notification service.');
    logActivity(
      liveNotificationId,
      LiveAcitivityEventType.destroy,
    );
    isServiceActiveNotifier.value = false;

    final response = await methodChannel.invokeMethod<bool>(
      'stopService',
    );
    print(
        '[stopService] Live notification service stopped with response: $response');
    return response;
  }

  @mustCallSuper
  Future<T?> updateLiveNotification(
    LiveNotification notification,
  ) async {
    print(
        '[updateLiveNotification] Updating live notification with notification: ${notification.toJson()}');

    if (liveNotificationId == null) {
      print(
          '[updateLiveNotification] No existing live notification found, creating new live notification.');
      final result = await createLiveNotification(notification);

      if (result == null) {
        print('[updateLiveNotification] Failed to create live notification.');
        return null;
      }

      print('[updateLiveNotification] new live notification: $result');
      _liveNotificationIdNotifier.value = result;

      logActivity(
        liveNotificationId,
        LiveAcitivityEventType.create,
        notification: notification,
      );

      // Return id to indicate that the live notification has been created
      return result;
    }

    logActivity(
      liveNotificationId,
      LiveAcitivityEventType.update,
      notification: notification,
    );

    final response =
        await methodChannel.invokeMethod<dynamic>('updateLiveNotification', {
      'id': liveNotificationId,
      ...encodeData(notification),
    });

    print(
        '[updateLiveNotification] Live notification updated with response: $response');
    return response as T?;
  }

  Future<T?> createLiveNotification(LiveNotification notification) async {
    print(
        '[createLiveNotification] Creating new live notification with notification: ${notification.toJson()}');

    logActivity(
      liveNotificationId,
      LiveAcitivityEventType.create,
      notification: notification,
    );

    final response = await methodChannel.invokeMethod<dynamic>(
      'createLiveNotification',
      encodeData(notification),
    );

    print(
        '[createLiveNotification] Live notification created with response: $response');
    return response as T?;
  }
}
