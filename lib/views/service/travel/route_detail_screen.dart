// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_state.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/travel/add_destination_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/widgets/destination_route_card.dart';
import 'package:tourguideapp/views/service/travel/destination_edit_screen.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeName;
  final int numberOfDays;
  final String provinceName;
  final String? existingRouteId;

  const RouteDetailScreen({
    super.key,
    required this.routeName,
    required this.numberOfDays,
    required this.provinceName,
    this.existingRouteId,
  });

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late List<String> categories;
  late List<String> dayKeys;
  late String selectedCategory;
  bool _isInitialized = false;
  bool _showSuccessSnackbar = false;

  @override
  void initState() {
    super.initState();
    // KHÔNG khởi tạo categories ở đây nữa!
    dayKeys = List.generate(widget.numberOfDays, (index) => 'Day ${index + 1}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      categories = List.generate(widget.numberOfDays, (index) {
        return '${AppLocalizations.of(context).translate('Day')} ${index + 1}';
      });
      selectedCategory = categories.first; 
      _isInitialized = true;

      // Load destinations ngay khi vào màn hình
      final dayKey = dayKeys[0];
      if (widget.existingRouteId != null) {
        print('Requesting destinations for existing route: ${widget.existingRouteId}');
        context.read<TravelBloc>().setCurrentDay(dayKey);
        context.read<TravelBloc>().add(LoadRouteDestinations(widget.existingRouteId!));
      } else {
        print('Loading temporary destinations for new route, day: $dayKey');
        context.read<TravelBloc>().setCurrentDay(dayKey);
        context.read<TravelBloc>().add(LoadTemporaryDestinations(dayKey));
      }
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    // Lấy key kỹ thuật tương ứng
    final dayIndex = categories.indexOf(category);
    final dayKey = dayKeys[dayIndex];
    // Cập nhật ngày hiện tại trong bloc
    context.read<TravelBloc>().setCurrentDay(dayKey);
    // Load lại destinations cho ngày mới
    if (widget.existingRouteId != null) {
      print('Loading destinations for existing route, day: $dayKey');
      context.read<TravelBloc>().add(LoadRouteDestinations(widget.existingRouteId!));
    } else {
      print('Loading temporary destinations for new route, day: $dayKey');
      context.read<TravelBloc>().add(LoadTemporaryDestinations(dayKey));
    }
  }

  void _onDeleteDay(String categoryToDelete) async {
    if (categories.length > 1) {
      final bool? shouldDelete = await showAppDialog(
        context: context,
        title: AppLocalizations.of(context).translate("Delete Day"),
        content: AppLocalizations.of(context).translate(
          "Are you sure you want to delete this day? All destinations in this day will be deleted.",
        ),
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).translate("Cancel"),
              style: const TextStyle(color: AppColors.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).translate("Delete"),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );

      if (shouldDelete == true) {
        final currentIndex = categories.indexOf(categoryToDelete);
        final dayKeyToDelete = dayKeys[currentIndex];

        setState(() {
          categories.removeAt(currentIndex);
          dayKeys.removeAt(currentIndex);
          for (int i = 0; i < categories.length; i++) {
            categories[i] = '${AppLocalizations.of(context).translate('Day')} ${i + 1}';
            dayKeys[i] = 'Day ${i + 1}';
          }
          if (selectedCategory == categoryToDelete) {
            selectedCategory = categories[(currentIndex > 0) ? currentIndex - 1 : 0];
          }
        });

        final selectedDayKey = dayKeys[categories.indexOf(selectedCategory)];

        if (widget.existingRouteId != null) {
          // Cập nhật số ngày và xóa dữ liệu của ngày bị xóa trong database
          context.read<TravelBloc>().add(
            UpdateTravelRoute(
              travelRouteId: widget.existingRouteId!,
              numberOfDays: categories.length,
              dayToDelete: dayKeyToDelete,
            ),
          );

          // Load lại destinations cho ngày mới được chọn
          context.read<TravelBloc>().setCurrentDay(selectedDayKey);
          context.read<TravelBloc>().add(
            LoadRouteDestinations(widget.existingRouteId!),
          );
        } else {
          // Xóa dữ liệu tạm thời của ngày bị xóa
          context.read<TravelBloc>().deleteTemporaryDay(dayKeyToDelete);
          // Cập nhật lại tên các ngày trong dữ liệu tạm thời
          final bloc = context.read<TravelBloc>();
          for (int i = 0; i < categories.length; i++) {
            final oldDay = 'Day ${i + 2}';
            final newDay = 'Day ${i + 1}';
            if (bloc.hasDestinationsForDay(oldDay)) {
              bloc.moveTemporaryDestinations(oldDay, newDay);
            }
          }
          // Cập nhật ngày hiện tại và load lại destinations
          context.read<TravelBloc>().setCurrentDay(selectedDayKey);
          context.read<TravelBloc>().add(LoadTemporaryDestinations(selectedDayKey));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TravelBloc, TravelState>(
      listener: (context, state) {
        if (state is TravelRouteCreated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/travel',
            (route) => false,
          );
        }
        // Hiển thị thông báo lỗi khi có xung đột thời gian
        if (state is TravelError) {
          final errorMessage = state.message;
          if (errorMessage.contains('xung đột') || errorMessage.contains('conflict')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            // Hiển thị thông báo lỗi thông thường
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            );
          }
        }
        // Hiển thị thông báo thành công khi cập nhật detail
        if (state is RouteDetailLoaded && _showSuccessSnackbar) {
          _showSuccessSnackbar = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thành công!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: widget.routeName,
          actions: widget.existingRouteId != null
              ? [
                  CustomIconButton(
                    icon: Icons.delete,
                    onPressed: () async {
                      final shouldDelete = await showAppDialog(
                        context: context,
                        title: AppLocalizations.of(context).translate('Confirm'),
                        content: AppLocalizations.of(context).translate('Are you sure you want to delete this route?'),
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.orange,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context).translate('Cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context).translate('Delete')),
                          ),
                        ],
                      );
                      if (shouldDelete == true) {
                        context.read<TravelBloc>().add(
                          DeleteTravelRoute(widget.existingRouteId!)
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/travel',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ]
              : [
                  CustomIconButton(
                    icon: Icons.check,
                    onPressed: () async {
                      final shouldCreate = await showAppDialog<bool>(
                        context: context,
                        title: AppLocalizations.of(context).translate('Confirm'),
                        content: AppLocalizations.of(context).translate('Are you sure you want to create this route?'),
                        icon: Icons.info_outline,
                        iconColor: Theme.of(context).primaryColor,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context).translate('Cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context).translate('Create')),
                          ),
                        ],
                      );
                      if (shouldCreate == true) {
                        context.read<TravelBloc>().add(
                          CreateTravelRoute(
                            routeName: widget.routeName,
                            province: widget.provinceName,
                            numberOfDays: widget.numberOfDays,
                          ),
                        );
                      }
                    },
                  ),
                ],
          onBackPressed: () async {
            if (widget.existingRouteId == null && context.read<TravelBloc>().hasTemporaryData()) {
              final bool shouldPop = await showAppDialog<bool>(
                context: context,
                title: AppLocalizations.of(context).translate('Discard Changes?'),
                content: AppLocalizations.of(context).translate('You have unsaved changes. Do you want to discard them and exit?'),
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context).translate('Cancel')),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<TravelBloc>().clearTemporaryData();
                      context.read<TravelBloc>().resetCurrentRoute();
                      context.read<TravelBloc>().add(LoadTravelRoutes());
                      Navigator.of(context).pop(true);
                    },
                    child: Text(AppLocalizations.of(context).translate('Yes')),
                  ),
                ],
              ) ?? false;

              if (shouldPop) {
                context.read<TravelBloc>().clearTemporaryData();
                context.read<TravelBloc>().resetCurrentRoute();
                context.read<TravelBloc>().add(LoadTravelRoutes());
                Navigator.of(context).pop();
              }
            } else {
              context.read<TravelBloc>().resetCurrentRoute();
              context.read<TravelBloc>().add(LoadTravelRoutes());
              Navigator.of(context).pop();
            }
          },
        ),
        body: BlocBuilder<TravelBloc, TravelState>(
          builder: (context, state) {
            // Luôn lấy danh sách từ state (đã đồng bộ với Firestore)
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CategorySelector(
                      selectedCategory: selectedCategory,
                      categories: categories,
                      onCategorySelected: onCategorySelected,
                      showAddButton: true,
                      existingRouteId: widget.existingRouteId,
                      allowDelete: true,
                      onCategoryDelete: _onDeleteDay,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: _buildDestinationsList(state),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomElevatedButton(
                          text: AppLocalizations.of(context).translate("Add Destination"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<TravelBloc>(),
                                  child: AddDestinationScreen(
                                    provinceName: widget.provinceName,
                                    existingRouteId: widget.existingRouteId,
                                    maxDestinations: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDestinationsList(TravelState state) {
    
    if (state is RouteDetailLoaded) {
      final items = state.destinationWithIds ?? [];
      if (items.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRect(
              child: Image.asset(
                'assets/img/my_vehicle_1.png',
                height: 192.h,
                width: 192.w,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).translate("No destinations added yet."),
              style: TextStyle(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ],
        );
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final destination = item['destination'] as DestinationModel;
          final uniqueId = item['uniqueId'] as String;
          final startTime = item['startTime'] as String;
          final endTime = item['endTime'] as String;
          // Lấy key kỹ thuật cho ngày hiện tại
          final dayIndex = categories.indexOf(selectedCategory);
          final currentDayKey = dayKeys[dayIndex];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: DestinationRouteCard(
              name: destination.destinationName,
              imagePath: destination.photo.isNotEmpty 
                  ? destination.photo[0] 
                  : 'assets/images/default.jpg',
              timeRange: '$startTime - $endTime',
              onTap: () {
                // Lấy thông tin chi tiết của destination từ current route
                List<String> images = [];
                List<String> videos = [];
                String notes = '';
                // Lấy thông tin chi tiết từ state (hoạt động cho cả existing và temporary routes)
                if (state.destinationDetails != null) {
                  final destinationData = state.destinationDetails![uniqueId];
                  if (destinationData != null) {
                    images = List<String>.from(destinationData['images'] ?? []);
                    videos = List<String>.from(destinationData['videos'] ?? []);
                    notes = destinationData['notes']?.toString() ?? '';
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationEditScreen(
                      destinationName: destination.destinationName,
                      currentStartTime: startTime,
                      currentEndTime: endTime,
                      currentImages: images,
                      currentVideos: videos,
                      currentNotes: notes,
                      onUpdateTime: (newStartTime, newEndTime) {
                        setState(() { _showSuccessSnackbar = true; });
                        context.read<TravelBloc>().add(
                          UpdateDestinationTime(
                            uniqueId: uniqueId,
                            startTime: newStartTime,
                            endTime: newEndTime,
                            routeId: widget.existingRouteId,
                            currentDay: currentDayKey,
                          ),
                        );
                      },
                      onUpdateDetails: (newImages, newVideos, newNotes) {
                        setState(() { _showSuccessSnackbar = true; });
                        context.read<TravelBloc>().add(
                          UpdateDestinationDetails(
                            uniqueId: uniqueId,
                            routeId: widget.existingRouteId,
                            currentDay: currentDayKey,
                            images: newImages,
                            videos: newVideos,
                            notes: newNotes,
                          ),
                        );
                      },
                      onDelete: () {
                        context.read<TravelBloc>().add(
                          DeleteDestinationFromRoute(
                            uniqueId: uniqueId,
                            routeId: widget.existingRouteId,
                            currentDay: currentDayKey,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    if (state is RouteDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRect(
          child: Image.asset(
            'assets/img/my_vehicle_1.png',
            height: 192.h,
            width: 192.w,
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          AppLocalizations.of(context).translate("No destinations added yet."),
          style: TextStyle(
            color: const Color(0xFF6C6C6C),
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}