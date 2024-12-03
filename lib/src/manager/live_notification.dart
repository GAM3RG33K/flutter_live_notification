
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

  @override
  String toString() {
    return "LiveNotification( title: $title, message: $message, payload: $payload,)";
  }
}
