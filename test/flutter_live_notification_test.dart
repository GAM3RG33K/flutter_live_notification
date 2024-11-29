// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_live_notification/flutter_live_notification.dart';
// import 'package:flutter_live_notification/flutter_live_notification_platform_interface.dart';
// import 'package:flutter_live_notification/flutter_live_notification_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterLiveNotificationPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterLiveNotificationPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterLiveNotificationPlatform initialPlatform = FlutterLiveNotificationPlatform.instance;

//   test('$MethodChannelFlutterLiveNotification is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterLiveNotification>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterLiveNotification flutterLiveNotificationPlugin = FlutterLiveNotification();
//     MockFlutterLiveNotificationPlatform fakePlatform = MockFlutterLiveNotificationPlatform();
//     FlutterLiveNotificationPlatform.instance = fakePlatform;

//     expect(await flutterLiveNotificationPlugin.getPlatformVersion(), '42');
//   });
// }
