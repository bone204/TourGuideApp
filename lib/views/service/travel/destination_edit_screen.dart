import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/core/utils/time_slot_manager.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/views/service/travel/image_viewer_screen.dart';
import 'dart:io';

class DestinationEditScreen extends StatefulWidget {
  final String destinationName;
  final String currentStartTime;
  final String currentEndTime;
  final List<String> currentImages;
  final List<String> currentVideos;
  final String currentNotes;
  final Function(String startTime, String endTime) onUpdateTime;
  final Function(List<String> images, List<String> videos, String notes) onUpdateDetails;
  final VoidCallback onDelete;

  const DestinationEditScreen({
    Key? key,
    required this.destinationName,
    required this.currentStartTime,
    required this.currentEndTime,
    required this.currentImages,
    required this.currentVideos,
    required this.currentNotes,
    required this.onUpdateTime,
    required this.onUpdateDetails,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DestinationEditScreen> createState() => _DestinationEditScreenState();
}

class _DestinationEditScreenState extends State<DestinationEditScreen> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late TextEditingController _notesController;
  late List<String> _images;
  late List<String> _videos;
  final ImagePicker _imagePicker = ImagePicker();
  final ImagePicker _videoPicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Chuyển đổi thời gian từ định dạng 12h sang 24h nếu cần
    final normalizedStartTime = TimeSlotManager.convertTo24Hour(widget.currentStartTime);
    final normalizedEndTime = TimeSlotManager.convertTo24Hour(widget.currentEndTime);
    
    // Chuyển đổi chuỗi thời gian thành TimeOfDay
    final startParts = normalizedStartTime.split(':');
    final endParts = normalizedEndTime.split(':');
    
    startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    
    endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    // Khởi tạo controller và danh sách
    _notesController = TextEditingController(text: widget.currentNotes);
    _images = List.from(widget.currentImages);
    _videos = List.from(widget.currentVideos);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
          // Nếu thời gian bắt đầu lớn hơn hoặc bằng thời gian kết thúc
          if (_compareTimeOfDay(startTime, endTime) >= 0) {
            // Tự động đặt thời gian kết thúc là 1 giờ sau thời gian bắt đầu
            endTime = TimeOfDay(
              hour: (startTime.hour + 1) % 24,
              minute: startTime.minute,
            );
          }
        } else {
          // Nếu thời gian kết thúc nhỏ hơn hoặc bằng thời gian bắt đầu
          if (_compareTimeOfDay(picked, startTime) <= 0) {
            // Hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thời gian kết thúc phải lớn hơn thời gian bắt đầu'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          endTime = picked;
        }
      });
    }
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1.compareTo(minutes2);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _videoPicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        setState(() {
          _videos.add(video.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _videoPicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        setState(() {
          _videos.add(video.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording video: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
  }

  void _viewImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          images: _images,
          initialIndex: index,
        ),
      ),
    );
  }

  void _saveAllChanges() {
    print('Saving all changes...');
    print('Notes to save: ${_notesController.text}');
    print('Images to save: $_images');
    print('Videos to save: $_videos');
    print('Start time: ${_formatTimeOfDay(startTime)}');
    print('End time: ${_formatTimeOfDay(endTime)}');
    
    // Cập nhật cả thời gian và thông tin chi tiết
    widget.onUpdateTime(
      _formatTimeOfDay(startTime),
      _formatTimeOfDay(endTime),
    );
    widget.onUpdateDetails(_images, _videos, _notesController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onBackPressed: () => Navigator.pop(context),
        title: widget.destinationName,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text('Bạn có chắc chắn muốn xóa địa điểm này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
              
              if (shouldDelete == true) {
                widget.onDelete();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Section
            _buildSectionHeader(
              AppLocalizations.of(context).translate("Time"),
              Icons.access_time,
            ),
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian bắt đầu',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () => _selectTime(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _formatTimeOfDay(startTime),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian kết thúc',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () => _selectTime(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _formatTimeOfDay(endTime),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Images Section
            _buildSectionHeader(
              AppLocalizations.of(context).translate("Images"),
              Icons.photo_library,
            ),
            SizedBox(height: 8.h),
            
            // Image Grid
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _viewImage(index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(_images[index]),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            // Add Image Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context).translate("Gallery")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(AppLocalizations.of(context).translate("Camera")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Videos Section
            _buildSectionHeader(
              AppLocalizations.of(context).translate("Videos"),
              Icons.videocam,
            ),
            SizedBox(height: 8.h),
            
            // Video List
            if (_videos.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.videocam, color: AppColors.primaryColor),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Video ${index + 1}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeVideo(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            // Add Video Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: Text(AppLocalizations.of(context).translate("Gallery")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: Text(AppLocalizations.of(context).translate("Record")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Notes Section
            _buildSectionHeader(
              AppLocalizations.of(context).translate("Notes"),
              Icons.note,
            ),
            SizedBox(height: 8.h),
            
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate("Add your notes here..."),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAllChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Lưu tất cả',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
} 