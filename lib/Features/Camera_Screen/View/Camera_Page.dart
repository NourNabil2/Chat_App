import 'dart:developer';
import 'dart:io';
import 'package:chats/Features/Camera_Screen/View/ChatList_Select_Page.dart';
import 'package:chats/Features/Camera_Screen/View/Widgets/button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:saver_gallery/saver_gallery.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../../Core/Functions/show_snack_bar.dart';
import 'Select_Page.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _imagePath; // To store the image path
  File? IMAGE;
  CameraDescription? _currentCamera; // To store the currently active camera

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([CameraDescription? camera]) async {
    try {
      final cameras = await availableCameras();
      final cameraToInitialize = camera ??
          cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
          );

      _controller = CameraController(
        cameraToInitialize,
        ResolutionPreset.high,
      );

      // Initialize the controller and assign the Future to the variable.
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture; // Wait for the controller to initialize before proceeding.

      setState(() {
        _currentCamera = cameraToInitialize; // Update the current camera
      }); // Trigger a rebuild to show the camera preview.
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;

        // Capture the picture and get the file path
        final image = await _controller!.takePicture();

        setState(() {
          IMAGE = File(image.path);
          _imagePath = image.path; // Save the image path
        });
      } else {
        print('Camera controller is not initialized.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _savePicture() async {
    if (_imagePath == null) return;
    try {
      final success = await SaverGallery.saveImage(
        IMAGE!.readAsBytesSync(),
        name: 'test.jpg',
        androidExistNotSave: false,
        // fileExtension: 'jpg',

        // albumName: 'We Chat',
      );

      if (success.isSuccess != null && success.isSuccess) {
        // Show success message
        Dialogs.showSnackbar(context, 'Image successfully saved!');
      } else {
        // Handle failure to save
        Dialogs.showSnackbar(context, 'Failed to save image.');
      }
    } catch (e) {
      // Handle any exceptions
      log('Error while saving image: $e');
      Dialogs.showSnackbar(context, 'An error occurred while saving the image.');
    }
  }
  _saveImage({required String url}) async {
    var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes));
    String picturesPath = "test_jpg.gif";
    debugPrint(picturesPath);
    final result = await SaverGallery.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: picturesPath,
      androidRelativePath: "Pictures/appName/xx",
      androidExistNotSave: false,
    );
    debugPrint(result.toString());
  }

  void _sendPicture() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SelectPageScreen(selectedImage: IMAGE),
    ));
    print("Picture sent!");
  }

  void _cancelPicture() {
    // Clear the image path to go back to the camera view
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _switchCamera() async {
    if (_controller == null || _currentCamera == null) return;

    try {
      final cameras = await availableCameras();
      final newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection != _currentCamera!.lensDirection,
      );

      // Reinitialize the camera with the new camera
      await _initializeCamera(newCamera);
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Make CameraPreview fill the entire screen
          _imagePath == null
              ? FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Apply a flip transformation if using the front camera
                return Transform(
                  alignment: Alignment.center,
                  transform: _currentCamera?.lensDirection ==
                      CameraLensDirection.front
                      ? Matrix4.rotationY(3.14159) // Flip the preview
                      : Matrix4.identity(),
                  child: SizedBox.expand(
                    child: CameraPreview(_controller!),
                  ),
                );
              } else {
                // Display a loading indicator while the camera is initializing.
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
              : Transform(
            alignment: Alignment.center,
            transform: _currentCamera?.lensDirection ==
                CameraLensDirection.front
                ? Matrix4.rotationY(3.14159) // Flip the image
                : Matrix4.identity(),
            child: Image.file(
              File(_imagePath!), // Display the captured image
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Display buttons to take picture or send/cancel
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _imagePath == null
                ? Stack(
              alignment: Alignment.center,
              children: [
                // Center the Take Picture button at the bottom
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Outer circle color
                        width: 5.0,
                      ),
                      color: Colors.transparent, // Inner circle color
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          Colors.transparent, // Inner circle button color
                        ),
                      ),
                    ),
                  ),
                ),
                // Camera switch button on the right side
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
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save button aligned to the left
                CustomButton(context, _savePicture, 'Save', Icons.download),
                // Spacer to push "Send" and "Cancel" buttons to the right
                Spacer(),
                CustomButton(context, _sendPicture, 'Send', null),
                SizedBox(width: 10),
                CustomButton(context, _cancelPicture, 'Cancel', null)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
