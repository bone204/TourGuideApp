import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourguideapp/color/colors.dart';


class ImagePickerWidget extends StatefulWidget {
  final String title;
  final String initialImagePath;
  final ValueChanged<String> onImagePicked;
  final bool isRequired;
  final bool isNetworkImage;

  const ImagePickerWidget({
    Key? key,
    required this.title,
    this.initialImagePath = '',
    required this.onImagePicked,
    this.isRequired = false,
    this.isNetworkImage = false,
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
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.isRequired)
              Text(
                " (*)",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
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
                : widget.isNetworkImage
                    ? Image.network(
                        _selectedImagePath!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
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