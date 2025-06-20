import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/feedback_viewmodel.dart';

class FeedbackForm extends StatelessWidget {
  const FeedbackForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating stars
            Row(
              children: [
                Text(
                  "${AppLocalizations.of(context).translate("Rate")}:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: 30.w),
                ...List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => viewModel.setRating(index + 1),
                    child: Padding(
                      padding: EdgeInsets.only(right: 18.w),
                      child: Icon(
                        Icons.star,
                        color: index < viewModel.rating
                            ? Colors.amber
                            : Colors.grey,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),

            // Comment text field
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                maxLines: 4,
                onChanged: viewModel.setComment,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)
                      .translate("Write your review"),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Media attachments
            Row(
              children: [
                _buildMediaButton(
                  context,
                  Icons.image,
                  AppLocalizations.of(context).translate("Add Image"),
                  viewModel.addImage,
                ),
                SizedBox(width: 16.w),
                _buildMediaButton(
                  context,
                  Icons.videocam,
                  AppLocalizations.of(context).translate("Add Video"),
                  viewModel.addVideo,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Media preview
            if (viewModel.images.isNotEmpty || viewModel.videos.isNotEmpty)
              Container(
                height: 100.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...viewModel.images.map((image) => _buildMediaPreview(
                          context,
                          image.path,
                          true,
                          () => viewModel
                              .removeImage(viewModel.images.indexOf(image)),
                        )),
                    ...viewModel.videos.map((video) => _buildMediaPreview(
                          context,
                          video.path,
                          false,
                          () => viewModel
                              .removeVideo(viewModel.videos.indexOf(video)),
                        )),
                  ],
                ),
              ),

            // Error message
            if (viewModel.error.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  viewModel.error,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMediaButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryColor,
          side: BorderSide(color: AppColors.primaryColor),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(
    BuildContext context,
    String path,
    bool isImage,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: isImage
                  ? DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !isImage
                ? Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 40.sp,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
