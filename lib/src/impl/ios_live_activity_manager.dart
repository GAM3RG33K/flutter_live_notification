import 'package:flutter_live_notification/src/live_activity_manager.dart';
import 'package:live_activities/live_activities.dart';

class IosLiveActivityManager extends LiveActivityManager<String> {
  final LiveActivities liveActivitiesPlugin;

  IosLiveActivityManager({required this.liveActivitiesPlugin});

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
    return liveActivitiesPlugin.init(
      appGroupId: '$appIdPrefix.live_activities',
      urlScheme: iOSUrlScheme,
    );
  }

  @override
  Future dispose() async {
    super.dispose();
    await liveActivitiesPlugin.endAllActivities();
    return liveActivitiesPlugin.dispose();
  }

  @override
  Future<bool> get isServiceActive async {
    final isActive = await liveActivitiesPlugin.areActivitiesEnabled();
    return isActive;
  }

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
    return liveActivitiesPlugin.endAllActivities();
  }

  @override
  Future<String?> createLiveActivity(
    LiveNotification notification,
  ) async {
    final result = await liveActivitiesPlugin.createActivity(
      notification.toJson(),
    );
    return result;
  }

  @override
  Future<String?> updateLiveActivity(
    LiveNotification notification,
  ) async {
    final result = await super.updateLiveActivity(notification);

    if (result != null) {
      return result;
    }

    final liveActivityId = super.liveActivityId;
    if (liveActivityId == null || liveActivityId.isEmpty) {
      return null;
    }
    final updateResult = await liveActivitiesPlugin.updateActivity(
      liveActivityId,
      notification.toJson(),
    );

    return updateResult;
  }
}
