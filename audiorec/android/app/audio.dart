import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}
class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _recorder;
  StreamSubscription? _recorderSubscription;
  bool _isRecording = false;
  String _recordFilePath = '';
  int _recordNumber = 0;
  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
  }
  @override
  void dispose() {
    _recorder?.stopRecorder();
 //   _recorderSubscription?.cancel();
    super.dispose();
  }
  Future<String> _getAudioDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDirPath = '${appDir.path}/audio';
    final audioDir = Directory(audioDirPath);
    if (!await audioDir.exists()) {
      await audioDir.create();
    }
    return audioDirPath;
  }
  Future<String> _getNextFilePath() async {
    final audioDirPath = await _getAudioDirectoryPath();
    final filePath = '$audioDirPath/recording${++_recordNumber}.m4a';
    return filePath;
  }
  Future<void> _startRecording() async {
    try {
      final filePath = await _getNextFilePath();
      await _recorder?.openRecorder();
      await _recorder?.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
        _recordFilePath = filePath;
      });
    } catch (e) {
      debugPrint('Error while recording: $e');
    }
  }
  Future<void> _stopRecording() async {
    try {
      await _recorder?.stopRecorder();
      await _recorder?.closeRecorder();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      debugPrint('Error while stopping recording: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording)
              Text('Recording...'),
            if (!_isRecording)
              ElevatedButton(
                onPressed: _startRecording,
                child: Text('Start Recording'),
              ),
            if (_isRecording)
              ElevatedButton(
                onPressed: _stopRecording,
                child: Text('Stop Recording'),
              ),
            ],
          ),
        ),
      );
    }
  }
