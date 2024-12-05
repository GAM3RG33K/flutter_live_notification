import 'dart:io';

void main(List<String> args) {
  print("Starting Flutter Live Activity Setup...");

  final projectDir = Directory.current;
  final iosDir = Directory('${projectDir.path}/ios');

  if (!iosDir.existsSync()) {
    print(
        "Error: iOS directory not found. Please run this command in a Flutter project root.");
    exit(1);
  }

  updateInfoPlist(iosDir);
  updatePodfile(iosDir);

  print("Setup completed successfully!");
}

void updateInfoPlist(Directory iosDir) {
  final infoPlistFile = File('${iosDir.path}/Runner/Info.plist');

  if (!infoPlistFile.existsSync()) {
    print("Error: Info.plist not found in iOS project.");
    return;
  }

  String infoPlistContent = infoPlistFile.readAsStringSync();

  final Map<String, String> requiredEntries = {
    'NSSupportsLiveActivities':
        '<key>NSSupportsLiveActivities</key>\n    <true/>',
    'UIBackgroundModes': '''
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>processing</string>
        <string>remote-notification</string>
    </array>
    ''',
    'NSLiveActivityUsageDescription': '''
    <key>NSLiveActivityUsageDescription</key>
    <string>This app needs access to Live Activities to provide real-time information on your lock screen.</string>
    ''',
    'NSMicrophoneUsageDescription': '''
    <key>NSMicrophoneUsageDescription</key>
    <string>{YourAppName} wants to use your microphone</string>
    ''',
    'NSCameraUsageDescription': '''
    <key>NSCameraUsageDescription</key>
    <string>{YourAppName} wants to use your camera</string>
    ''',
    'NSLocalNetworkUsageDescription': '''
    <key>NSLocalNetworkUsageDescription</key>
    <string>{YourAppName} App wants to use your local network</string>
    '''
  };

  bool hasUpdates = false;

  requiredEntries.forEach((key, entry) {
    if (!infoPlistContent.contains(key)) {
      print("Adding missing entry: $key");
      infoPlistContent =
          infoPlistContent.replaceFirst('</dict>', '$entry\n</dict>');
      hasUpdates = true;
    } else {
      print("Entry already exists: $key");
    }
  });

  if (hasUpdates) {
    infoPlistFile.writeAsStringSync(infoPlistContent);
    print("Updated Info.plist successfully.");
  } else {
    print("No updates required for Info.plist.");
  }
}

void updatePodfile(Directory iosDir) {
  final podfile = File('${iosDir.path}/Podfile');

  if (!podfile.existsSync()) {
    print("Error: Podfile not found in iOS project.");
    return;
  }

  var podfileContent = podfile.readAsStringSync();

  final platformLineRegex = RegExp(r"platform\s*:ios,\s*'(\d+\.\d+)'");
  if (platformLineRegex.hasMatch(podfileContent)) {
    podfileContent = podfileContent.replaceAllMapped(
      platformLineRegex,
      (match) => "platform :ios, '16.2'",
    );

    podfile.writeAsStringSync(podfileContent);
    print("Updated Podfile successfully.");
  } else {
    print("No platform line found in Podfile. Adding new platform line.");
    podfile.writeAsStringSync("platform :ios, '16.2'\n" + podfileContent);
  }
}
