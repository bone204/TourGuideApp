import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tourguideapp/color/colors.dart';


class ImagePickerWidget extends StatefulWidget {
  final String title;
  final String initialImagePath;
  final ValueChanged<String> onImagePicked;
  final bool isRequired;

  const ImagePickerWidget({
    Key? key,
    required this.title,
    this.initialImagePath = '',
    required this.onImagePicked,
    this.isRequired = false,
  }) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
      widget.onImagePicked(_selectedImagePath!); // Trả về đường dẫn cục bộ
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
      return '';
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isRequired)
              Text(
                " (*)",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: _showPickerOptions,
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: _selectedImagePath == null || _selectedImagePath!.isEmpty
                ? Center(
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF007BFF), width: 2.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                    ),
                  )
                : Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }
}