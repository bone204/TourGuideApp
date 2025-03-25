import 'package:flutter/material.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
enum SeatStatus {
  available,
  selected,
  booked,
}

class SeatWidget extends StatelessWidget {
  final SeatStatus status;
  final VoidCallback onTap;
  final String label;

  const SeatWidget({
    super.key,
    required this.status,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    bool isSelectable = true;

    switch (status) {
      case SeatStatus.available:
        seatColor = AppColors.primaryColor;
        break;
      case SeatStatus.selected:
        seatColor = AppColors.green;
        break;
      case SeatStatus.booked:
        seatColor = AppColors.grey;
        isSelectable = false;
        break;
    }

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Column(
        children: [
          Icon(
            Icons.chair,
            color: seatColor,
            size: 48.sp,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: status == SeatStatus.booked
                  ? AppColors.grey
                  : AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 