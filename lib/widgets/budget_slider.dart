import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/color/colors.dart';

class BudgetSlider extends StatefulWidget {
  final Function(double, double) onBudgetChanged;
  final double initialMin;
  final double initialMax;
  final String type;

  const BudgetSlider({
    Key? key,
    required this.onBudgetChanged,
    required this.initialMin,
    required this.initialMax,
    required this.type,
  }) : super(key: key);

  @override
  State<BudgetSlider> createState() => _BudgetSliderState();
}

class _BudgetSliderState extends State<BudgetSlider> {
  late double _lowerValue;
  late double _upperValue;
  late double _minValue;
  late double _maxValue;
  late double _step;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();

    if (widget.type == 'Car') {
      _minValue = 300000;
      _maxValue = 1700000;
      _step = 50000;
      _lowerValue = 300000;
      _upperValue = 1700000;
    } else if (widget.type == 'Motorbike') {
      _minValue = 0;
      _maxValue = 500000;
      _step = 25000;
      _lowerValue = 0;
      _upperValue = 500000;
    } else {
      _minValue = 0;
      _maxValue = 1000000;
      _step = 50000;
      _lowerValue = 0;
      _upperValue = 500000;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return FlutterSlider(
      values: [_lowerValue, _upperValue],
      rangeSlider: true,
      max: _maxValue,
      min: _minValue,
      step: FlutterSliderStep(step: _step),
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
        labels: widget.type == 'Car'
            ? List.generate(15, (index) {
                int value = 300000 + (index * 100000);
                String label = value >= 1000000
                    ? '${(value / 1000000).toStringAsFixed(1)}M'
                    : '${value ~/ 1000}K';
                return FlutterSliderHatchMarkLabel(
                  percent: (index * 100000 / (1700000 - 300000)) * 100,
                  label: Padding(
                    padding: EdgeInsets.only(top: 36.h),
                    child: Column(
                      children: [
                        Container(
                            width: 1.w, height: 4.h, color: AppColors.grey),
                        if (index % 2 == 0)
                          Text(label,
                              style: const TextStyle(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.bold)),
                        if (index % 2 != 0)
                          const Text(" ",
                              style: TextStyle(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              })
            : List.generate(11, (index) {
                int value = index * 50000;
                String label = '${value ~/ 1000}K';
                return FlutterSliderHatchMarkLabel(
                  percent: index * 10,
                  label: Padding(
                    padding: EdgeInsets.only(top: 36.h),
                    child: Column(
                      children: [
                        Container(
                            width: 1.w, height: 4.h, color: AppColors.grey),
                        if (index % 2 == 0)
                          Text(label,
                              style: const TextStyle(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.bold)),
                        if (index % 2 != 0)
                          const Text(" ",
                              style: TextStyle(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
      ),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        print('\n[Budget Slider Change]');
        print(
            'Handler Index: $handlerIndex'); // 0 là lower handle, 1 là upper handle
        print('Previous Lower Value: $_lowerValue');
        print('Previous Upper Value: $_upperValue');
        print('New Lower Value: $lowerValue');
        print('New Upper Value: $upperValue');
        print('Formatted Lower Value: ${_currencyFormat.format(lowerValue)}');
        print('Formatted Upper Value: ${_currencyFormat.format(upperValue)}');

        setState(() {
          _lowerValue = lowerValue;
          _upperValue = upperValue;
        });

        widget.onBudgetChanged(lowerValue, upperValue);
        print('Budget values updated and callback triggered');
        print('============================');
      },
    );
  }
}
