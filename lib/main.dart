import 'package:flutter/material.dart';
import 'package:flutter_audio_app/screens/audio_recorder_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Recorder',
      home: AudioRecorderPage(),
    );
  }
}