import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.5,
      child: Checkbox(
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.maximumDensity,
          vertical: 0.0,
        ),
        value: widget.value,
        onChanged: widget.onChanged,
        checkColor: Colors.white,
        activeColor: const Color(0xFF007BFF),
        side: BorderSide(
          color: widget.value ? const Color(0xFF007BFF) : Colors.grey,
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
