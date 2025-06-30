import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription>? cameras;
  CameraController? _controller;
  bool isCameraInitialized = false;
  bool isRearCameraSelected = true;
  XFile? capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _startCamera(cameras!.first);
    }
  }

  void _startCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    setState(() {
      isCameraInitialized = false;
    });

    isRearCameraSelected = !isRearCameraSelected;
    CameraDescription newCamera = isRearCameraSelected ? cameras!.first : cameras![1];

    await _controller?.dispose();
    _startCamera(newCamera);
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _controller!.value.isTakingPicture) return;

    try {
      XFile image = await _controller!.takePicture();
      setState(() {
        capturedImage = image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil diambil!')),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kamera")),
      body: isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_controller!),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    heroTag: "switch",
                    child: const Icon(Icons.cameraswitch),
                    onPressed: _switchCamera,
                  ),
                  FloatingActionButton(
                    heroTag: "capture",
                    child: const Icon(Icons.camera),
                    onPressed: _takePicture,
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
