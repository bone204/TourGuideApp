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
          child: Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  text: 'Delete',
                  foregroundColor: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                  onPressed: () {
                    context.read<TravelBloc>().add(
                      DeleteTravelRoute(widget.existingRouteId!)
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/travel',
                      (route) => false,
                    );
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Start',
                  onPressed: () {
                    context.read<TravelBloc>().add(
                      StartTravelRoute(widget.existingRouteId!)
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
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
    // Bỏ BlocProvider và sử dụng BlocListener trực tiếp
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
            print('Building with state: $state');
            
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
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: _buildDestinationsList(state),
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
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
    print('Building destinations list with state: $state');
    
    if (state is RouteDetailLoaded) {
      print('State is RouteDetailLoaded');
      print('Number of destinations: ${state.destinations.length}');
      print('Time slots: ${state.timeSlots}');
      
      if (state.destinations.isEmpty) {
        print('No destinations found');
        return const Center(
          child: Text('No destinations added yet'),
        );
      }

      // Tạo map để theo dõi số lần xuất hiện của mỗi destination
      final Map<String, int> destinationCount = {};
      
      return ListView.builder(
        itemCount: state.destinations.length,
        itemBuilder: (context, index) {
          final destination = state.destinations[index];
          print('Building card for destination: ${destination.destinationName}');
          print('Destination ID: ${destination.destinationId}');
          print('Available timeSlots: ${state.timeSlots}');
          
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
          
          print('Time for this destination: ${state.timeSlots?[uniqueId]}');
          
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
      print('State is RouteDetailLoading');
      return const Center(child: CircularProgressIndicator());
    }

    print('State is neither RouteDetailLoaded nor RouteDetailLoading');
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