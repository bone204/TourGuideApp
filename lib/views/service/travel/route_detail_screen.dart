import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/travel/travel_event.dart';
import 'package:tourguideapp/blocs/travel/travel_state.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/travel/add_destination_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/blocs/travel/travel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/widgets/destination_route_card.dart';
import 'package:tourguideapp/utils/time_slot_manager.dart';
import 'package:tourguideapp/widgets/destination_edit_modal.dart';

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
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    categories = List.generate(widget.numberOfDays, (index) {
      return 'Day ${index + 1}';
    });
    selectedCategory = categories.first;

    // Load destinations ngay khi vào màn hình
    if (widget.existingRouteId != null) {
      print('Requesting destinations for route: ${widget.existingRouteId}');
      context.read<TravelBloc>().add(LoadRouteDestinations(widget.existingRouteId!));
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    // Cập nhật ngày hiện tại trong bloc
    context.read<TravelBloc>().setCurrentDay(category);
    // Load lại destinations cho ngày mới
    if (widget.existingRouteId != null) {
      context.read<TravelBloc>().add(LoadRouteDestinations(widget.existingRouteId!));
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    if (widget.existingRouteId != null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomElevatedButton(
          text: 'Create Route',
          onPressed: () {
            context.read<TravelBloc>().add(
              CreateTravelRoute(
                routeName: widget.routeName,
                province: widget.provinceName,
                numberOfDays: widget.numberOfDays,
              ),
            );
          },
        ),
      ),
    );
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
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: widget.routeName,
          actions: widget.existingRouteId != null
              ? [
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        context.read<TravelBloc>().add(
                          DeleteTravelRoute(widget.existingRouteId!)
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/travel',
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 1,
                        child: Text('Delete Route'),
                      ),
                    ],
                  ),
                ]
              : null,
          onBackPressed: () async {
            if (widget.existingRouteId == null && context.read<TravelBloc>().hasTemporaryData()) {
              final bool shouldPop = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard Changes?'),
                  content: const Text('You have unsaved changes. Do you want to discard them and exit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<TravelBloc>().clearTemporaryData();
                        context.read<TravelBloc>().resetCurrentRoute();
                        context.read<TravelBloc>().add(LoadTravelRoutes());
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
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
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        flex: 2,
                        child: CustomElevatedButton(
                          text: AppLocalizations.of(context).translate("Delete Day"),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                          onPressed: () async {
                            if (categories.length > 1) {
                              // Hiển thị hộp thoại xác nhận
                              final bool? shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(context).translate("Delete Day"),
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context).translate(
                                      "Are you sure you want to delete this day? All destinations in this day will be deleted.",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        AppLocalizations.of(context).translate("Cancel"),
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        AppLocalizations.of(context).translate("Delete"),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              // Chỉ xóa nếu người dùng xác nhận
                              if (shouldDelete == true) {
                                final currentIndex = categories.indexOf(selectedCategory);
                                final dayToDelete = selectedCategory;
                                
                                setState(() {
                                  // Xóa ngày hiện tại
                                  categories.removeAt(currentIndex);
                                  
                                  // Cập nhật lại tên các ngày sau khi xóa
                                  for (int i = 0; i < categories.length; i++) {
                                    categories[i] = 'Day ${i + 1}';
                                  }
                                  
                                  // Chọn ngày mới sau khi xóa
                                  if (currentIndex > 0) {
                                    selectedCategory = categories[currentIndex - 1];
                                  } else {
                                    selectedCategory = categories[0];
                                  }
                                });

                                if (widget.existingRouteId != null) {
                                  // Cập nhật số ngày và xóa dữ liệu của ngày bị xóa trong database
                                  context.read<TravelBloc>().add(
                                    UpdateTravelRoute(
                                      travelRouteId: widget.existingRouteId!,
                                      numberOfDays: categories.length,
                                      dayToDelete: dayToDelete,
                                    ),
                                  );

                                  // Load lại destinations cho ngày mới được chọn
                                  context.read<TravelBloc>().setCurrentDay(selectedCategory);
                                  context.read<TravelBloc>().add(
                                    LoadRouteDestinations(widget.existingRouteId!),
                                  );
                                } else {
                                  // Xóa dữ liệu tạm thời của ngày bị xóa
                                  context.read<TravelBloc>().deleteTemporaryDay(dayToDelete);
                                  
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
                                  context.read<TravelBloc>().setCurrentDay(selectedCategory);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildDestinationsList(TravelState state) {
    
    if (state is RouteDetailLoaded) {
      if (state.destinations.isEmpty) {
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
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        );
      }

      // Tạo map để theo dõi số lần xuất hiện của mỗi destination
      final Map<String, int> destinationCount = {};
      
      return ListView.builder(
        itemCount: state.destinations.length,
        itemBuilder: (context, index) {
          final destination = state.destinations[index];  
          // Tăng số lần xuất hiện của destination này
          destinationCount[destination.destinationId] = (destinationCount[destination.destinationId] ?? 0) + 1;
          final currentCount = destinationCount[destination.destinationId]! - 1;
          
          // Lấy tất cả uniqueId cho destination này
          final uniqueIds = state.timeSlots?.keys
              .where((key) => key.startsWith(destination.destinationId))
              .toList() ?? [];
          
          print('Found uniqueIds for this destination: $uniqueIds');
          
          // Lấy uniqueId tương ứng với vị trí hiện tại của destination này
          final uniqueId = uniqueIds.length > currentCount ? uniqueIds[currentCount] : destination.destinationId;
          
          print('Selected uniqueId: $uniqueId');
          
          final timeRange = state.timeSlots?[uniqueId] ?? 
                    TimeSlotManager.formatTimeRange('08:00', '09:00');
          
          final startTime = timeRange.split(' - ')[0];
          final endTime = timeRange.split(' - ')[1];
          
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: DestinationRouteCard(
              name: destination.destinationName,
              imagePath: destination.photo.isNotEmpty 
                  ? destination.photo[0] 
                  : 'assets/images/default.jpg',
              timeRange: timeRange,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DestinationEditModal(
                    destinationName: destination.destinationName,
                    currentStartTime: startTime,
                    currentEndTime: endTime,
                    onUpdateTime: (newStartTime, newEndTime) {
                      context.read<TravelBloc>().add(
                        UpdateDestinationTime(
                          uniqueId: uniqueId,
                          startTime: newStartTime,
                          endTime: newEndTime,
                          routeId: widget.existingRouteId,
                          currentDay: selectedCategory,
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<TravelBloc>().add(
                        DeleteDestinationFromRoute(
                          uniqueId: uniqueId,
                          routeId: widget.existingRouteId,
                          currentDay: selectedCategory,
                        ),
                      );
                    },
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
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}