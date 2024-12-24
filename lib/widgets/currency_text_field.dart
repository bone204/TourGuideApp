import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextEditingController actualController;

  const CurrencyTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.actualController,
  });

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  final numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    // Đảm bảo actualController có giá trị trước
    if (widget.actualController.text.isEmpty) {
      widget.actualController.text = '0';
    }
    
    // Format giá trị hiển thị dựa trên actualController
    String value = widget.actualController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isNotEmpty && value != '0') {
      // Loại bỏ các số 0 ở đầu nếu có
      while (value.startsWith('0') && value.length > 1) {
        value = value.substring(1);
      }
      widget.controller.text = '${numberFormat.format(int.parse(value))} ₫';
    } else {
      widget.controller.text = '0 ₫';
      widget.actualController.text = '0';
    }
    
    widget.controller.addListener(_enforceSelectionConstraint);
  }

  void _enforceSelectionConstraint() {
    if (!widget.controller.selection.isValid) return;
    
    String text = widget.controller.text;
    if (text.isEmpty) return;

    int maxOffset = text.length - 2;
    if (widget.controller.selection.baseOffset > maxOffset) {
      widget.controller.selection = TextSelection.collapsed(offset: maxOffset);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_enforceSelectionConstraint);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CurrencyInputFormatter(widget.actualController),
      ],
      onTap: () {
        String text = widget.controller.text;
        if (text.isNotEmpty) {
          widget.controller.selection = TextSelection.collapsed(
            offset: text.length - 2,
          );
        }
      },
      decoration: InputDecoration(
        hintText: '0 ₫',
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value == '0 ₫') {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final TextEditingController actualController;
  final numberFormat = NumberFormat('#,###');

  _CurrencyInputFormatter(this.actualController);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nếu text rỗng, set về 0
    if (newValue.text.isEmpty || newValue.text == '0') {
      actualController.text = '0';
      return const TextEditingValue(
        text: '0 ₫',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    // Loại bỏ tất cả ký tự không phải số
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nếu sau khi loại bỏ mà rỗng, set về 0
    if (newText.isEmpty) {
      actualController.text = '0';
      return const TextEditingValue(
        text: '0 ₫',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    // Loại bỏ các số 0 ở đầu nếu có
    while (newText.startsWith('0') && newText.length > 1) {
      newText = newText.substring(1);
    }

    // Cập nhật giá trị thực
    actualController.text = newText;

    // Format số với dấu phẩy và thêm đơn vị tiền tệ
    String formattedText = '${numberFormat.format(int.parse(newText))} ₫';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length - 2),
    );
  }
} 