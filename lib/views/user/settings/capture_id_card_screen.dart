// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/core/services/id_card_service.dart';
import 'package:tourguideapp/views/user/settings/id_card_confirmation_screen.dart';

class CaptureIdCardScreen extends StatefulWidget {
  const CaptureIdCardScreen({super.key});

  @override
  _CaptureIdCardScreenState createState() => _CaptureIdCardScreenState();
}

class _CaptureIdCardScreenState extends State<CaptureIdCardScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final IdCardService _idCardService = IdCardService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _checkPermissionsAndInitialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate("Camera permission is required")),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Không tìm thấy camera');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      await _disposeCamera();

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.yuv420 
            : ImageFormatGroup.jpeg,
      );

      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Khởi tạo camera timeout');
        },
      );

      if (!mounted) return;

      await _controller!.setExposureMode(ExposureMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);
      
      if (Platform.isAndroid) {
        await _controller!.setDescription(backCamera);
      }

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Lỗi khởi tạo camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khởi tạo camera: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () {
                _initializeCamera();
              },
            ),
          ),
        );
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (!mounted) return;

      // Tắt camera trước khi chụp
      await _controller!.pausePreview();
      
      final XFile image = await _controller!.takePicture();
      
      if (!mounted) return;

      final File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        throw Exception('Không thể lưu ảnh');
      }

      final int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Kích thước ảnh vượt quá 5MB');
      }

      // Dispose camera sau khi chụp xong
      await _disposeCamera();

      if (!mounted) return;

      final result = await _idCardService.processIdCardImage(image.path);
      
      if (!mounted) return;

      final confirmedData = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => IdCardConfirmationScreen(idCardData: result),
        ),
      );

      if (confirmedData != null) {
        await _idCardService.saveIdCardInfo(confirmedData);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          await _initializeCamera();
        }
      }
    } catch (e) {
      print('Lỗi chụp ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
        await _initializeCamera();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disposeCamera();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate("Capture ID Card"),
          onBackPressed: () async {
            await _disposeCamera();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Stack(
          children: [
            if (_isCameraInitialized && _controller != null)
              Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1 / _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.586,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Capture Requirements"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            AppLocalizations.of(context).translate("• Ensure all 4 corners are visible"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("• Keep the card flat and well-lit"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("• Make sure all text is clear and readable"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("• Avoid shadows and glare"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            if (!_isCameraInitialized)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: _initializeCamera,
                      child: Text(
                        'Khởi tạo lại camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Place your ID card within the frame"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  if (_isCameraInitialized && _controller != null)
                    FloatingActionButton(
                      onPressed: _isProcessing ? null : _captureImage,
                      backgroundColor: _isProcessing ? Colors.grey : Theme.of(context).primaryColor,
                      child: _isProcessing
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 