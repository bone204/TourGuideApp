import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/color/colors.dart';

class BudgetSlider extends StatefulWidget {
  @override
  _BudgetSliderState createState() => _BudgetSliderState();
}

class _BudgetSliderState extends State<BudgetSlider> {
  double _lowerValue = 100000;
  double _upperValue = 900000;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return FlutterSlider(
      values: [_lowerValue, _upperValue],
      rangeSlider: true,
      max: 1000000,
      min: 0,
      step: const FlutterSliderStep(step: 10000),
      tooltip: FlutterSliderTooltip(
        alwaysShowTooltip: true,
        format: (String value) {
          double parsedValue = double.tryParse(value) ?? 0;
          return _currencyFormat.format(parsedValue);
        },
        textStyle: TextStyle(
          fontSize: 10.sp,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
        boxStyle: FlutterSliderTooltipBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        positionOffset: FlutterSliderTooltipPositionOffset(
          top: -20,
        ),
      ),
      trackBar: const FlutterSliderTrackBar(
        activeTrackBarHeight: 8,
        inactiveTrackBarHeight: 8,
        activeTrackBar: BoxDecoration(color: AppColors.primaryColor),
      ),
      handler: FlutterSliderHandler(
        decoration: const BoxDecoration(),
        child: Material(
          type: MaterialType.circle,
          color: AppColors.white,
          elevation: 3,
          child: SizedBox(
            width: 16.sp,
            height: 16.sp,
          ),
        ),
      ),
      rightHandler: FlutterSliderHandler(
        decoration: const BoxDecoration(),
        child: Material(
          type: MaterialType.circle,
          color: AppColors.white,
          elevation: 3,
          child: SizedBox(
            width: 16.sp,
            height: 16.sp,
          ),
        ),
      ),
      hatchMark: FlutterSliderHatchMark(
        labels: List.generate(11, (index) {
          int value = index * 100000;
          String label = index == 10 ? '1M' : '${value ~/ 1000}K';
          return FlutterSliderHatchMarkLabel(
            percent: index * 10,
            label: Padding(
              padding: EdgeInsets.only(top: 36.h),
              child: Column(
                children: [
                  Container(width: 1.w, height: 4.h, color: AppColors.grey),
                  if (index % 2 == 0) Text(label, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                  if (index % 2 != 0) const Text(" ", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }),
      ),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _lowerValue = lowerValue;
          _upperValue = upperValue;
        });
      },
    );
  }
}