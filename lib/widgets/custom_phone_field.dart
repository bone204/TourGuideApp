import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final List<String> countryCodes;
  final Function(String) onCountryCodeChanged;
  final String? hintText;

  const CustomPhoneField({
    Key? key,
    required this.controller,
    required this.selectedCountryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    this.hintText,
  }) : super(key: key);

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _isFocused ? Colors.black : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
            child: DropdownButton<String>(
              value: widget.selectedCountryCode,
              items: widget.countryCodes
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(code, style: TextStyle(fontSize: 14.sp)),
                      ))
                  .toList(),
              onChanged: (value) => widget.onCountryCodeChanged(value!),
              underline: const SizedBox(),
            ),
          ),
          Container(
            width: 1,
            height: 24.h,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: TextFormField(
                controller: widget.controller,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 