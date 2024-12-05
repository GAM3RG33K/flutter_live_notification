import 'dart:io';
import 'scripts/setup_ios.dart' as setup_ios;

void main(List<String> args) {
  switch (Platform.operatingSystem) {
    case "ios":
      return setup_ios.main(args);
    default:
      throw UnimplementedError(
          'Flutter Live Notification setup is not supported for ${Platform.operatingSystem} platform');
  }
}
