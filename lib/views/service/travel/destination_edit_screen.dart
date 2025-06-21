import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/core/utils/time_slot_manager.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
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
              SnackBar(
                content: const Text('Thời gian kết thúc phải lớn hơn thời gian bắt đầu'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
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
        SnackBar(
          content: Text('Lỗi khi chụp ảnh: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
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
        SnackBar(
          content: Text('Lỗi khi chọn video: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
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
        SnackBar(
          content: Text('Lỗi khi quay video: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        onBackPressed: () => Navigator.pop(context),
        title: widget.destinationName,
        actions: [
          CustomIconButton(
            icon: Icons.delete,
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  title: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600),
                      SizedBox(width: 8.w),
                      const Text('Xác nhận xóa'),
                    ],
                  ),
                  content: const Text('Bạn có chắc chắn muốn xóa địa điểm này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
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
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: AppColors.white,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Section
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                AppLocalizations.of(context).translate("Time"),
                                Icons.access_time,
                              ),
                              SizedBox(height: 20.h),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTimeSelector(
                                      'Thời gian bắt đầu',
                                      _formatTimeOfDay(startTime),
                                      () => _selectTime(context, true),
                                      Colors.blue.shade50,
                                      Colors.blue.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _buildTimeSelector(
                                      'Thời gian kết thúc',
                                      _formatTimeOfDay(endTime),
                                      () => _selectTime(context, false),
                                      Colors.green.shade50,
                                      Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Images Section
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                AppLocalizations.of(context).translate("Images"),
                                Icons.photo_library,
                              ),
                              SizedBox(height: 16.h),
                              
                              // Image Grid
                              if (_images.isNotEmpty)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                  ),
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    return _buildImageItem(index);
                                  },
                                ),
                              
                              SizedBox(height: 16.h),
                              
                              // Add Image Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: _pickImage,
                                      icon: Icons.photo_library,
                                      label: AppLocalizations.of(context).translate("Gallery"),
                                      color: Colors.purple.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: _takePhoto,
                                      icon: Icons.camera_alt,
                                      label: AppLocalizations.of(context).translate("Camera"),
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Videos Section
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                AppLocalizations.of(context).translate("Videos"),
                                Icons.videocam,
                              ),
                              SizedBox(height: 16.h),
                              
                              // Video List
                              if (_videos.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _videos.length,
                                  itemBuilder: (context, index) {
                                    return _buildVideoItem(index);
                                  },
                                ),
                              
                              SizedBox(height: 16.h),
                              
                              // Add Video Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: _pickVideo,
                                      icon: Icons.video_library,
                                      label: AppLocalizations.of(context).translate("Gallery"),
                                      color: Colors.indigo.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: _recordVideo,
                                      icon: Icons.videocam,
                                      label: AppLocalizations.of(context).translate("Record"),
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Notes Section
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                AppLocalizations.of(context).translate("Notes"),
                                Icons.note,
                              ),
                              SizedBox(height: 16.h),
                              
                              TextField(
                                controller: _notesController,
                                maxLines: 5,
                                style: TextStyle(fontSize: 14.sp),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context).translate("Add your notes here..."),
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
              // Save Button - Luôn hiển thị ở cuối
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(String label, String time, VoidCallback onTap, Color bgColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: textColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: textColor, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => _viewImage(index),
              child: Image.file(
                File(_images[index]),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
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
        ),
      ),
    );
  }

  Widget _buildVideoItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.videocam, color: Colors.red.shade600, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Video ${index + 1}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeVideo(index),
            icon: Icon(Icons.delete, color: Colors.red.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 2,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveAllChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Lưu tất cả',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 