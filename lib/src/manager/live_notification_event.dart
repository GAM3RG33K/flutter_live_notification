
import 'live_notification.dart';

enum LiveAcitivityEventType {
  create,
  update,
  dismiss,
}

class LiveNotificationEvent<T> {
  final T? id;
  final LiveAcitivityEventType type;
  final LiveNotification? notification;

  const LiveNotificationEvent({
    required this.id,
    required this.type,
    this.notification,
  });
  factory LiveNotificationEvent.create(T? id, [LiveNotification? notification]) {
    return LiveNotificationEvent(
      id: id,
      type: LiveAcitivityEventType.create,
      notification: notification,
    );
  }

  factory LiveNotificationEvent.update(T? id, [LiveNotification? notification]) {
    return LiveNotificationEvent(
      id: id,
      type: LiveAcitivityEventType.update,
      notification: notification,
    );
  }

  factory LiveNotificationEvent.dismiss(T? id, [LiveNotification? notification]) {
    return LiveNotificationEvent(
      id: id,
      type: LiveAcitivityEventType.dismiss,
      notification: notification,
    );
  }
}