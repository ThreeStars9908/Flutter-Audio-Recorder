import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecorder {
  FlutterSoundRecorder? _audioRecorder;
  String _path = '';

  Future<void> initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String audioDirectory = '${appDirectory.path}/audio_recordings';
    await Directory(audioDirectory).create(recursive: true);
    _path = '$audioDirectory/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await Permission.microphone.request();
    await Permission.storage.request();
    await _audioRecorder!.openRecorder();
    _audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future<void> startRecording() async {
    await _audioRecorder!.startRecorder(toFile: _path);
  }

  Future<void> stopRecording() async {
    await _audioRecorder!.stopRecorder();
  }

  Future<List<String>> getAudioFiles() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String audioDirectory = '${appDirectory.path}/audio_recordings';
    final dir = Directory(audioDirectory);
    final files = await dir.list().toList();
    return files.map((file) => file.path.split('/').last).toList();
  }

  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
  }

  String get path => _path;
}