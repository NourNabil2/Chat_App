import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chats/Features/Camera_Screen/View/Widgets/button.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:video_player/video_player.dart';
import '../../../Core/Functions/show_snack_bar.dart';
import '../../../Core/Network/API.dart';
import 'Select_Page.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _imagePath;
  File? IMAGE;
  CameraDescription? _currentCamera;
  Timer? _recordingTimer;
  int _recordingTime = 0;
  bool _isRecording = false;
  Color _buttonColor = Colors.white; // Default button color
  VideoPlayerController? _videoController;
  String? VIDEO_PATH;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([CameraDescription? camera]) async {
    try {
      final cameras = await availableCameras();
      final cameraToInitialize = camera ?? cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _controller = CameraController(
        cameraToInitialize,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      setState(() {
        _currentCamera = cameraToInitialize;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoController?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;

        final image = await _controller!.takePicture();

        setState(() {
          IMAGE = File(image.path);
          _imagePath = image.path;
        });
      } else {
        print('Camera controller is not initialized.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || _isRecording) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingTime = 0;
      });

      _startTimer();
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;

    try {
      final video = await _controller!.stopVideoRecording();
       VIDEO_PATH = video.path;

      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;

        // Initialize the video player for preview
        _videoController = VideoPlayerController.file(File(video.path));
        _initializeVideoPlayerFuture = _videoController!.initialize();
        _videoController!.setLooping(true);
      });

      // Verify that the video file exists
      if (!File(video.path).existsSync()) {
        log('Video file does not exist at: ${video.path}');
      } else {
        log('Video recorded to: ${video.path}');
      }
    } catch (e) {
      log('Error stopping video recording: $e');
    }
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingTime += 1;
      });

      if (_recordingTime >= 30) {
        _stopRecording();
      }
    });
  }

  void _onTapDown(LongPressStartDetails details) {
    setState(() {
      _buttonColor = Colors.yellowAccent; // Change color when recording starts
    });
    _startRecording(); // Start recording video
  }

  void _onTapUp(LongPressEndDetails details) {
    setState(() {
      _buttonColor = Colors.white; // Revert color when recording stops
    });
    if (_isRecording) {
      _stopRecording(); // Stop recording after long press ends
    }
  }

  Future<void> _switchCamera() async {
    if (_controller == null || _currentCamera == null) return;

    try {
      final cameras = await availableCameras();
      final newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection != _currentCamera!.lensDirection,
      );

      await _initializeCamera(newCamera);
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  Future<void> _savePicture() async {
    if (_imagePath == null) return;
    try {
      final success = await SaverGallery.saveImage(
        IMAGE!.readAsBytesSync(),
        name: 'test.jpg',
        androidExistNotSave: false,
      );

      if (success.isSuccess != null && success.isSuccess) {
        Dialogs.showSnackbar(context, 'Image successfully saved!');
      } else {
        Dialogs.showSnackbar(context, 'Failed to save image.');
      }
    } catch (e) {
      log('Error while saving image: $e');
      Dialogs.showSnackbar(context, 'An error occurred while saving the image.');
    }
  }

  Future<void> _saveVideo() async {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      Dialogs.showSnackbar(context, 'Video controller not initialized.');
      return;
    }

    final String? videoPath = VIDEO_PATH;

    if (videoPath == null || videoPath.isEmpty) {
      Dialogs.showSnackbar(context, 'Invalid video path.');
      return;
    }

    final File tempVideoFile = File(videoPath);

    if (!tempVideoFile.existsSync()) {
      Dialogs.showSnackbar(context, 'Video file does not exist.');
      return;
    }

    try {
      // Get the Movies directory for saving the video
      final directory = await getExternalStorageDirectory();  // Gets the external storage directory
      final videoDirectory = Directory('${directory!.path}/Movies');
      if (!videoDirectory.existsSync()) {
        videoDirectory.createSync();
      }

      final newVideoPath = '${videoDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Copy the file to a permanent location with the correct extension
      final File permanentVideoFile = await tempVideoFile.copy(newVideoPath);

      // Save the video to the gallery using SaverGallery
      final success = await SaverGallery.saveFile(
        file: permanentVideoFile.path,
        name: '${DateTime.now().millisecondsSinceEpoch}.mp4',
        androidExistNotSave: true, // Adjust as needed
        androidRelativePath: 'Movies/MyAppVideos/', // Save to Movies directory
      );

      if (success.isSuccess != null && success.isSuccess) {
        Dialogs.showSnackbar(context, 'Video successfully saved!');
      } else {
        Dialogs.showSnackbar(context, 'Failed to save video.');
      }
    } catch (e) {
      log('Error while saving video: $e');
      log('Error while saving video: $videoPath');
      Dialogs.showSnackbar(context, 'An error occurred while saving the video.');
    }
  }



  void _sendPicture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPageScreen(selectedImage: IMAGE),
      ),
    );
    print("Picture sent!");
  }

  void _sendVideo() {
    if (VIDEO_PATH == null || VIDEO_PATH!.isEmpty) {
      Dialogs.showSnackbar(context, 'Invalid video path.');
      return;
    }

    APIs.sendStoryMedia(File(VIDEO_PATH!), isVideo: true, isPublic: false);

    // Navigate to SelectPageScreen with the selected video
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPageScreen(selectedVideo: File(VIDEO_PATH!)),
      ),
    );

    print("Video sent!");
  }

  void _cancelPicture() {
    setState(() {
      _imagePath = null;
    });
  }

  void _cancelVideo() {
    setState(() {
      if (_videoController != null) {
        _videoController!.dispose(); // Release resources associated with the video player
        _videoController = null; // Clear the reference to the video controller
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _imagePath == null && _videoController == null
              ? FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Transform(
                  alignment: Alignment.center,
                  transform: _currentCamera?.lensDirection ==
                      CameraLensDirection.front
                      ? Matrix4.rotationY(3.14159)
                      : Matrix4.identity(),
                  child: SizedBox.expand(
                    child: CameraPreview(_controller!),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
              : _videoController != null
              ? FutureBuilder<void>(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _videoController!.play();
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
              : Image.file(
            File(_imagePath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Recording timer
          Positioned(
            top: 50,
            left: 20,
            child: _isRecording
                ? Text(
              '${_recordingTime}s',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                : SizedBox.shrink(),
          ),

          // Close button (X icon)
          _imagePath == null ? Container() :  Positioned(
            top: 30, // Adjust the position as needed
            left: 20,
            child: CustomButton(
              context,
              _cancelPicture,
              '',
              Icons.close, // Use the close icon (X)
            ),
          ),
          VIDEO_PATH == null ? Container() :  Positioned(
            top: 30, // Adjust the position as needed
            left: 20,
            child: CustomButton(
              context,
              _cancelVideo,
              '',
              Icons.close, // Use the close icon (X)
            ),
          ),

          // Bottom buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _imagePath == null && _videoController == null
                ? Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _takePicture,
                  onLongPressStart: _onTapDown,
                  onLongPressEnd: (details) => _onTapUp(details),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _buttonColor,
                        width: 5.0,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _switchCamera,
                  ),
                ),
              ],
            )
                : _videoController != null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                    context, _saveVideo, 'Save', Icons.download),
                Spacer(),
                CustomButton(context, _sendVideo, 'Send to >', null),
                SizedBox(width: 10),

              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                    context, _savePicture, 'Save', Icons.download),
                Spacer(),
                CustomButton(context, _sendPicture, 'Send to >', null),
                SizedBox(width: 10),
                // Remove this CustomButton for 'X' since it's now at the top
              ],
            ),
          ),
        ],
      ),
    );
  }


}
