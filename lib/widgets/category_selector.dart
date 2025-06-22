// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final bool showAddButton;
  final String? existingRouteId;
  final bool allowDelete;
  final Function(String)? onCategoryDelete;
  final bool isDayCategory;
  final Function()? onAddDay;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    this.showAddButton = false,
    this.existingRouteId,
    this.allowDelete = false,
    this.onCategoryDelete,
    this.isDayCategory = false,
    this.onAddDay,
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

  String displayCategory(String key, BuildContext context) {
    if (widget.isDayCategory) {
      final dayNumber = int.tryParse(key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      return '${AppLocalizations.of(context).translate('Day')} $dayNumber';
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.categories.map((categoryKey) {
            final isSelected = categoryKey == widget.selectedCategory;
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => widget.onCategorySelected(categoryKey),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        displayCategory(categoryKey, context),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (widget.allowDelete && widget.categories.length > 1)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => widget.onCategoryDelete?.call(categoryKey),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.close, size: 16, color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          if (widget.showAddButton) // Chỉ hiển thị nút Add khi cờ được bật
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primaryColor),
              onPressed: () {
                if (widget.onAddDay != null) {
                  widget.onAddDay!();
                }
              },
            ),
        ],
      ),
    );
  }
}
