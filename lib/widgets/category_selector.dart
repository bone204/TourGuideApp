import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/category_button.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories; // Receive the categories list
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: CategoryButton(
                category: category,
                isSelected: selectedCategory == category,
                onTap: onCategorySelected,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
