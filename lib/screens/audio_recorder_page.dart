import 'package:flutter/material.dart';
import 'package:flutter_audio_app/services/audio_recorder.dart';
import 'package:flutter_audio_app/services/email_sender.dart';

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  List<String> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _audioRecorder.initRecorder();
    _getAudioFiles();
  }

  Future<void> _getAudioFiles() async {
    final audioFiles = await _audioRecorder.getAudioFiles();
    setState(() {
      _audioFiles = audioFiles;
    });
  }

  Future<void> _startRecording() async {
    await _audioRecorder.startRecording();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecording();
    setState(() {
      _isRecording = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio recording finished')),
    );
    _getAudioFiles();
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
                EmailSender.sendEmail(
                  recipientEmail,
                  'Audio Recording',
                  'Here is the recorded audio.',
                  [_audioRecorder.path],
                  context,
                );
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
    _audioRecorder.dispose();
    super.dispose();
  }
}