import 'package:flutter/material.dart';

class InteractiveRowWidget extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final bool isSelected;

  const InteractiveRowWidget({
    required this.leadingIcon,
    required this.title,
    required this.trailingIcon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? const Color(0xFF24BAEC) : Colors.black;
    final iconColor = isSelected ? const Color(0xFF24BAEC) : Colors.grey;

    // Use MediaQuery to make the widget responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05, horizontal: screenWidth * 0.03), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Reduced border radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 2, // Reduced blur radius
              offset: const Offset(0, 2), // Reduced offset
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: textColor),
                const SizedBox(width: 12), // Reduced space
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Icon(trailingIcon, color: iconColor),
          ],
        ),
      ),
    );
  }
}
