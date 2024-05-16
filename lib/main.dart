import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String _path = '';
  List<String> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String audioDirectory = '${appDirectory.path}/audio_recordings';
    await Directory(audioDirectory).create(recursive: true);
    _path = '$audioDirectory/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await Permission.microphone.request();
    await Permission.storage.request();
    await _audioRecorder!.openRecorder();
    _audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 10));

    _getAudioFiles();
  }

  Future<void> _getAudioFiles() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String audioDirectory = '${appDirectory.path}/audio_recordings';
    final dir = Directory(audioDirectory);
    final files = await dir.list().toList();
    setState(() {
      _audioFiles = files.map((file) => file.path.split('/').last).toList();
    });
  }

  Future<void> _startRecording() async {
    await _audioRecorder!.startRecorder(toFile: _path);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio recording finished')),
    );
    _getAudioFiles();
  }

  Future<void> _sendEmail(String recipientEmail) async {
    print('saved path' + _path);

    final Email email = Email(
      body: 'Here is the recorded audio.',
      subject: 'Audio Recording',
      recipients: [recipientEmail],
      attachmentPaths: [_path],
      isHTML: false,
    );

    String platformResponse;
    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  void _showEmailModal(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Recipient Email'),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email Address',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Send'),
              onPressed: () {
                final String recipientEmail = _emailController.text.trim();
                Navigator.of(context).pop();
                _sendEmail(recipientEmail);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Audio and Send'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _audioFiles.length,
              itemBuilder: (context, index) {
                final audioFile = _audioFiles[index];
                return ListTile(
                  title: Text(audioFile),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 50,
                      color: Colors.white,
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showEmailModal(context);
                  },
                  child: Text('Send via Email'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    super.dispose();
  }
}