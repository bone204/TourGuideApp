import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadioOptionsWidget extends StatelessWidget {
  final List<String> titles;
  final int selectedOption;
  final Function(int?) onOptionChanged;

  const RadioOptionsWidget({
    Key? key,
    required this.titles,
    required this.selectedOption,
    required this.onOptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        titles.length,
        (index) => Expanded(
          child: Row(
            children: [
              Radio<int>(
                value: index + 1,
                groupValue: selectedOption,
                onChanged: onOptionChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Flexible(
                child: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 