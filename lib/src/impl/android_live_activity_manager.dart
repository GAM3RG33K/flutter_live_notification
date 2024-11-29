import 'dart:convert';

import 'package:flutter_live_notification/src/constants.dart';
import 'package:flutter_live_notification/src/live_activity_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AndroidLiveActivityManager extends LiveActivityManager<int> {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  AndroidLiveActivityManager({required this.localNotificationsPlugin});

  InitializationSettings getSettings(String androidDefaultIcon) =>
      InitializationSettings(
        android: AndroidInitializationSettings(androidDefaultIcon),
      );

  @override
  Future initialize({
    required String appIdPrefix,
    required String androidDefaultIcon,
    String? iOSUrlScheme,
  }) async {
    await super.initialize(
      appIdPrefix: appIdPrefix,
      androidDefaultIcon: androidDefaultIcon,
    );
    return localNotificationsPlugin.initialize(
      getSettings(
        androidDefaultIcon,
      ),
    );
  }


  @override
  Future dispose() async {
    super.dispose();
    return localNotificationsPlugin.cancelAll();
  }

  String get channelId => '${appIdPrefix ?? ''}.live_activity_channel';
  String get channelName => 'Live activities${appIdPrefix ?? ''}';

  @override
  Map<String, dynamic> encodeData(LiveNotification model) {
    return model.toJson();
  }

  @override
  LiveNotification decodeData(Map<String, dynamic> json) {
    return LiveNotification.fromJson(json);
  }

  @override
  Future stopService() async {
    await super.stopService();
    return localNotificationsPlugin.cancelAll();
  }

  @override
  Future<int?> createLiveActivity(
    LiveNotification notification,
  ) async {
    await localNotificationsPlugin.show(
      defaultNotificationId,
      notification.title,
      notification.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
        ),
      ),
      payload: jsonEncode(notification.payload),
    );

    return defaultNotificationId;
  }

  @override
  Future<int?> updateLiveActivity(
    LiveNotification notification,
  ) async {
    final result = await super.updateLiveActivity(notification);

    if (result != null) {
      return result;
    }

    final liveActivityId = super.liveActivityId;
    if (liveActivityId == null) {
      return null;
    }
    await localNotificationsPlugin.show(
      liveActivityId,
      notification.title,
      notification.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
        ),
      ),
      payload: jsonEncode(notification.payload),
    );

    return liveActivityId;
  }
}
