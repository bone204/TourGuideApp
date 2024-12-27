import 'package:flutter/material.dart';

class CustomComboBox extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final DateTime? selectedDate;

  const CustomComboBox({
    super.key,
    required this.hintText,
    this.value,
    required this.items,
    required this.onChanged,
    this.selectedDate,
  });

  List<String> _getFilteredItems() {
    if (selectedDate == null) return items;

    final now = DateTime.now();
    if (selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day) {
      final currentHour = now.hour;
      List<String> availableItems = [];

      if (currentHour <= 13) {
        availableItems.add('4 Hours');
      }
      if (currentHour <= 9) {
        availableItems.add('8 Hours');
      }

      return availableItems;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();
    final currentValue =
        value != null && filteredItems.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: currentValue,
      hint: Text(hintText),
      items: filteredItems.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      isExpanded: true,
    );
  }
}
