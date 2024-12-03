import 'package:flutter/services.dart';
import 'package:flutter_live_notification/src/live_notification_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LiveNotificationManager platform;
  const MethodChannel channel = MethodChannel('flutter_live_notification');

  setUp(() {
    platform = LiveNotificationManager(methodChannel: channel);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
