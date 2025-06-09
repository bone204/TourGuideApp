import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/views/user/travel_history/destination_review_screen.dart';

class HistoricalDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final String visitDate;

  const HistoricalDestinationCard({
    required this.destination,
    required this.visitDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationReviewScreen(destination: destination),
          ),
        );
      },
      child: Container(
        width: 335.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.25),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  destination.photo.isNotEmpty ? destination.photo[0] : '',
                  height: 90.h,
                  width: 160.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: const Color(0xFF7D848D),
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          visitDate,
                          style: TextStyle(
                            color: const Color(0xFF7D848D),
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      destination.destinationName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      destination.specificAddress,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7D848D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
