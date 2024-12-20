import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_live_notification/flutter_live_notification.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background services
  final flutterLiveNotification = FlutterLiveNotification.getInstance();
  flutterLiveNotification.initialize(
    appIdPrefix: 'com.example',
    androidDefaultIcon: 'ic_launcher',
  );
  
//   // setupPip();

  runApp(TimerApp(
    flutterLiveNotification: flutterLiveNotification,
  ));
}

// Future<void> setupPip() async {
//   final isPipSetupSuccessful = await HMSIOSPIPController.setup(
//       autoEnterPip: true, // Automatically enter PIP when minimized
//       aspectRatio: [16, 9], // Set desired aspect ratio
//       scaleType: ScaleType.SCALE_ASPECT_FILL, // Choose scaling type
//       backgroundColor: Colors.black // Background color of PIP window
//       );

//   print('setupPip:  ${isPipSetupSuccessful?.toMap()}');
// }

// Future<void> enterPipMode() async {
//   HMSIOSPIPController.start();
//   final isPipEnteredSuccessfully = await HMSIOSPIPController.isActive();

//   if (isPipEnteredSuccessfully is HMSException) {
//     print("Failed with error: $isPipEnteredSuccessfully");
//   }
//   if (isPipEnteredSuccessfully) {
//     print("Entered PIP mode successfully.");
//   } else {
//     print("Failed to enter PIP mode.");
//   }
// }

// Time formatting utility
String _formatTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

class TimerApp extends StatelessWidget {
  final FlutterLiveNotification flutterLiveNotification;

  const TimerApp({super.key, required this.flutterLiveNotification});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimerScreen(
        flutterLiveNotification: flutterLiveNotification,
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final FlutterLiveNotification flutterLiveNotification;

  const TimerScreen({super.key, required this.flutterLiveNotification});
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    if (_isRunning) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        widget.flutterLiveNotification.updateLiveNotification(
          LiveNotification(
            title: 'Live Timer',
            message: _formatTime(_elapsedSeconds),
          ),
        );
      });
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
       widget.flutterLiveNotification.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          // enterPipMode();
          },
        child: const Icon(Icons.picture_in_picture),
      ),
      appBar: AppBar(title: const Text('Cross-Platform Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_elapsedSeconds),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
