import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: suffixIcon,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}


class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key, 
    required this.controller,
    this.hintText,
    this.validator,
  });

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText ?? AppLocalizations.of(context).translate('Password'),
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator ?? (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).translate('Please enter your password');
        } else if (value.length < 8) {
          return AppLocalizations.of(context).translate('Password must be at least 8 characters long');
        }
        return null;
      },
    );
  }
}

class CustomExpandableTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  const CustomExpandableTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 5,
  });

  @override
  State<CustomExpandableTextField> createState() =>
      _CustomExpandableTextFieldState();
}

class _CustomExpandableTextFieldState
    extends State<CustomExpandableTextField> {
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final text = widget.controller.text;

    // Xóa text thì không xử lý gì thêm
    if (text.length < _lastText.length) {
      _lastText = text;
      return;
    }

    // Xử lý khi nhấn Enter và text không rỗng
    if (text.endsWith('\n')) {
      final lines = text.split('\n');
      if (lines.isNotEmpty) {
        final lastLine = lines.last.trim();

        // Thêm bullet nếu dòng trước đó không rỗng
        if (lines.length >= 2 && lastLine.isEmpty) {
          final modifiedText = text + '• ';
          widget.controller.value = TextEditingValue(
            text: modifiedText,
            selection: TextSelection.collapsed(
              offset: modifiedText.length,
            ),
          );
        }
      }
    } else if (text.isEmpty) {
      // Thêm bullet khi text ban đầu trống
      widget.controller.value = const TextEditingValue(
        text: '• ',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    _lastText = widget.controller.text;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.multiline,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
