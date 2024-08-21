import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/pages/widgets/app_button.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../locator.dart';
import '../services/ml_service.dart';
import '../vision_detector_views/camera_view.dart';
import '../vision_detector_views/painters/dotted_circle_painter.dart';
import 'db/databse_helper.dart';
import 'models/user.model.dart';
import 'widgets/app_text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp();

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  Face? faceDetected;
  Size? imageSize;
  TextEditingController userTxt = TextEditingController();
  final MLService _mlService = locator<MLService>();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  var _cameraLensDirection = CameraLensDirection.front;
  List<int> faceDetectStatus = [];
  ValueNotifier<String> showGuide = ValueNotifier('');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  _signUp() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    final dataSignUp = _mlService.dataSignUp;
    String user = userTxt.text;
    User userToSave = User(
      user: user,
      password: '',
      modelData: dataSignUp,
    );
    await databaseHelper.insert(userToSave);
    _mlService.dataSignUp = [];
    Navigator.pop(context);
  }

  bool nextStep({
    required double ox,
    required double oy,
  }) {
    int n1 = 0;
    int n2 = 0;
    int n3 = 0;
    int n4 = 0;
    int n5 = 0;
    for (final e in faceDetectStatus) {
      switch (e) {
        case 1:
          n1++;
          continue;
        case 2:
          n2++;
          continue;
        case 3:
          n3++;
          continue;
        case 4:
          n4++;
          continue;
        case 5:
          n5++;
          continue;
        default:
          continue;
      }
    }
    if (ox.abs() < 5 && oy.abs() < 5 && n1 < 5) {
      n1++;
      faceDetectStatus.add(1);
      print('thẳng');
      return true;
    }
    if (ox > 5 && n2 < 5) {
      n2++;
      faceDetectStatus.add(2);
      print('quay lên');
      return true;
    }
    if ((Platform.isAndroid ? oy < -30 : oy > 30) && n3 < 5) {
      n3++;
      faceDetectStatus.add(3);
      print('quay phải');
      return true;
    }
    if (ox < -10 && n4 < 5) {
      n4++;
      faceDetectStatus.add(4);
      print('quay xuống');
      return true;
    }
    if ((Platform.isAndroid ? oy > 30 : oy < -30) && n5 < 5) {
      n5++;
      faceDetectStatus.add(5);
      print('quay trái');
      return true;
    }
    if (n1 < 5) {
      showGuide.value = 'Nhìn thẳng';
      return false;
    }
    if (n2 < 5) {
      showGuide.value = 'Quay lên';
      return false;
    }
    if (n3 < 5) {
      showGuide.value = 'Quay phải';
      return false;
    }
    if (n4 < 5) {
      showGuide.value = 'Quay xuống';
      return false;
    }
    if (n5 < 5) {
      showGuide.value = 'Quay trái';
      return false;
    }
    showGuide.value = 'Done';
    return false;
  }

  Future<void> _processImage(InputImage inputImage, CameraImage cameraImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    try {
      if (faceDetectStatus.length == 25) {
        showGuide.value = 'Done';
      } else {
        final faces = await _faceDetector.processImage(inputImage);
        if (faces.isEmpty) {
          showGuide.value = 'Not face';
        } else {
          faceDetected = faces.first;
          if (faceDetected!.boundingBox.top < 200 || faceDetected!.boundingBox.top > 600) {
            showGuide.value = ' Đưa mặt vào trong vòng nhận diện';
          } else {
            nextStep(ox: faceDetected!.headEulerAngleX ?? 0, oy: faceDetected!.headEulerAngleY ?? 0);
            locator<MLService>().setCurrentPrediction(cameraImage, faceDetected);
            locator<MLService>().dataSignUp.add(locator<MLService>().predictedData);
          }
        }
      }
    } catch (_) {}
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SIGN UP")),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ValueListenableBuilder(
              valueListenable: showGuide,
              builder: (context, v, c) {
                if (showGuide.value == 'Done') {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: userTxt,
                          labelText: 'Nhập tên',
                        ),
                        SizedBox(height: 16),
                        AppButton(
                          onPressed: () {
                            _signUp();
                          },
                          text: 'Lưu',
                        ),
                      ],
                    ),
                  );
                }
                return CameraView(
                  customPaint: CustomPaint(
                    painter: DottedCirclePainter(radius: 180, angle: faceDetectStatus.length.angle),
                  ),
                  onImage: _processImage,
                  initialCameraLensDirection: _cameraLensDirection,
                  onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
                );
              }),
          Positioned(
            top: 100,
            child: ValueListenableBuilder(
                valueListenable: showGuide,
                builder: (context, v, c) {
                  if (showGuide.value == 'Done') {
                    return SizedBox();
                  }
                  return Text(
                    showGuide.value,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),
                  );
                }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

extension FaceStatusExt on int {
  double get angle {
    switch (this) {
      case -1:
        return -90.0;
      case 0:
        return -90.0;
      case 1:
        return 0;
      default:
        return (this - 1) * 270 / 24;
    }
  }

  String get faceString {
    switch (this) {
      case 1:
        return '';
      case 2:
        return '';
      case 3:
        return '';
      case 4:
        return '';
      case 5:
        return '';
      default:
        return '';
    }
  }
}
