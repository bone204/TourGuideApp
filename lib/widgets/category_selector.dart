import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Focus vào category được chọn sau khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.categories.indexOf(widget.selectedCategory) == 0) {
        _scrollToStart();
      }
    });
  }

  void _scrollToStart() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories.map((category) {
          final isSelected = category == widget.selectedCategory;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => widget.onCategorySelected(category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
