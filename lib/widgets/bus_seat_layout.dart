import 'package:flutter/material.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'seat_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class BusSeatLayout extends StatelessWidget {
  final List<List<SeatStatus>> upperDeckLayout;
  final List<List<SeatStatus>> lowerDeckLayout;
  final Function(int, int, bool) onSeatTap;
  final String Function(int, int, bool) getSeatLabel;

  const BusSeatLayout({
    super.key,
    required this.upperDeckLayout,
    required this.lowerDeckLayout,
    required this.onSeatTap,
    required this.getSeatLabel,
  });

  Widget _buildDeck(BuildContext context, List<List<SeatStatus>> deckLayout, bool isUpper) {
    return Column(
      children: [
        // Deck title
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            isUpper ? AppLocalizations.of(context).translate("Upper deck") : AppLocalizations.of(context).translate("Lower deck"),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16.h),

        if (!isUpper) 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/ic_steering_wheel.png', width: 48.w, height: 48.h),
              SizedBox(width: 136.w),
              Icon(Icons.arrow_right_alt, color: AppColors.grey, size: 48.sp),
            ]
          ),
        if (!isUpper) 
          SizedBox(height: 16.h),
          
        // Seat rows
        ...List.generate(
          deckLayout.length,
          (row) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left side seats
                SeatWidget(
                  status: deckLayout[row][0],
                  onTap: () => onSeatTap(row, 0, isUpper),
                  label: getSeatLabel(row, 0, isUpper),
                ),

                // Aisle
                SizedBox(width: 40.h),

                // Middle seat
                SeatWidget(
                  status: deckLayout[row][1],
                  onTap: () => onSeatTap(row, 1, isUpper),
                  label: getSeatLabel(row, 1, isUpper),
                ),
                
                // Aisle
                SizedBox(width: 40.h),
                
                // Right side seats
                SeatWidget(
                  status: deckLayout[row][2],
                  onTap: () => onSeatTap(row, 2, isUpper),
                  label: getSeatLabel(row, 2, isUpper),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDeck(context, lowerDeckLayout, false),
        SizedBox(height: 32.h),
        _buildDeck(context, upperDeckLayout, true),
      ],
    );
  }
}

class SeatPosition {
  final int row;
  final int col;

  SeatPosition(this.row, this.col);
} 