import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../locator.dart';
import '../services/ml_service.dart';
import '../vision_detector_views/camera_view.dart';
import '../vision_detector_views/painters/face_painter.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final MLService _mlService = locator<MLService>();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;
  String userRecognition = '';
  Offset offset = Offset(0, 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _processImage(InputImage inputImage, CameraImage cameraImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      if (!mounted) return;
      userRecognition = 'Not face';
    }
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = FacePainter(
        faces: faces,
        imageSize: inputImage.metadata!.size,
        rotation: inputImage.metadata!.rotation,
        cameraLensDirection: _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      final faceDetected = faces.first;
      locator<MLService>().setCurrentPrediction(cameraImage, faceDetected);
      final userData = await locator<MLService>().predict();
      if (!mounted) return;
      userRecognition = userData?.user ?? 'Not found';
      offset = Offset(faceDetected.boundingBox.top, faceDetected.boundingBox.left);
    } else {
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LOGIN"),
      ),
      body: Stack(
        children: [
          CameraView(
            customPaint: _customPaint,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
          ),
          Positioned(
              top: offset.dx,
              left: offset.dy,
              child: Text(
                userRecognition,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              )),
        ],
      ),
    );
  }
}
