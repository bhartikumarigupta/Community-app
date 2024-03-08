import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoRecordingScreen(),
    );
  }
}

class VideoRecordingScreen extends StatefulWidget {
  @override
  _VideoRecordingScreenState createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  String videoPath = "";
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _isRecording = false;
  bool _isVideoRecorded = false;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recording'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(_controller!),
                        if (_videoPlayerController != null &&
                            _videoPlayerController!.value.isInitialized)
                          AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                      ],
                    )
                  : CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isRecording ? null : _startRecording,
            child: Text('Start Recording'),
          ),
          ElevatedButton(
            onPressed: _isRecording ? _stopRecording : null,
            child: Text('Stop Recording'),
          ),
          ElevatedButton(
            onPressed: _isVideoRecorded ? _previewVideo : null,
            child: Text('Preview Video'),
          ),
          ElevatedButton(
            onPressed: _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized
                ? _submitVideo
                : null,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _startRecording() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final Directory appDir = await getTemporaryDirectory();
        final String videoFileName = '${DateTime.now()}.mp4';
        videoPath = '${appDir.path}/$videoFileName';

        await _controller!.startVideoRecording();

        setState(() {
          _isRecording = true;
          _isVideoRecorded = false; // Set to false when starting recording.
        });
      }
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  void _stopRecording() async {
    try {
      await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _isVideoRecorded = true; // Set to true when the video is recorded.
      });

      await _initializeVideoPlayer();
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    await _videoPlayerController!.initialize();

    setState(() {});
  }

  void _previewVideo() {
    // Navigate to a new screen/widget to preview the recorded video and pass the controller.
    if (_isVideoRecorded) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPreviewScreen(_videoPlayerController)),
      );
    }
  }

  Future<void> _submitVideo() async {
    try {
      await _uploadVideo();
      await _saveVideoMetadata();
      // Optionally, you can navigate to a success page or show a success message.
    } catch (e) {
      print('Error submitting video: $e');
    }
  }

  Future<void> _uploadVideo() async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('videos')
          .child(DateTime.now().toString() + '.mp4');
      final metadata = firebase_storage.SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {
          'title': titleController.text,
          'description': descriptionController.text,
        },
      );

      await ref.putFile(File(videoPath), metadata);
      final downloadURL = await ref.getDownloadURL();

      print('Video uploaded to Firebase Storage: $downloadURL');
    } catch (e) {
      print('Error uploading video to Firebase Storage: $e');
    }
  }

  Future<void> _saveVideoMetadata() async {
    try {
      final collection = FirebaseFirestore.instance.collection('videos');
      await collection.add({
        'title': titleController.text,
        'description': descriptionController.text,
        'videoURL': 'URL_TO_THE_VIDEO',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Video metadata saved to Firestore');
    } catch (e) {
      print('Error saving video metadata to Firestore: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}

class VideoPreviewScreen extends StatelessWidget {
  final VideoPlayerController? videoPlayerController;

  VideoPreviewScreen(this.videoPlayerController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Video'),
      ),
      body: Center(
        child: videoPlayerController != null &&
                videoPlayerController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(videoPlayerController!),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
