import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final bool showAddButton;
  final String? existingRouteId;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    this.showAddButton = false,
    this.existingRouteId,
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
        children: [
          ...widget.categories.map((category) {
            final isSelected = category == widget.selectedCategory;
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => widget.onCategorySelected(category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        if (widget.showAddButton) // Chỉ hiển thị nút Add khi cờ được bật
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () {
              final newDay = 'Day ${widget.categories.length + 1}';
              setState(() {
                widget.categories.add(newDay);
              });
              widget.onCategorySelected(newDay);
              
              // Chỉ gọi UpdateTravelRoute khi có existingRouteId
              if (widget.existingRouteId != null) {
                context.read<TravelBloc>().add(UpdateTravelRoute(
                  travelRouteId: widget.existingRouteId!,
                  numberOfDays: widget.categories.length,
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
