import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class ProvinceCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double rating;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const ProvinceCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    this.onTap,
    this.isFavorite = true,
    this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tỉnh
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(59.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 140.w),
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Rating và Favorite button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(59.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: AppColors.yellow,
                                size: 16.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                rating.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tightFor(
                            width: 24.r,
                            height: 24.r,
                          ),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 14.r,
                          ),
                          onPressed: onFavoritePressed,
                        ),
                      ),
                    ],
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
