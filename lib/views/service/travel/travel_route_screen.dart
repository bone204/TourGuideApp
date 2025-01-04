import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart'; 
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/destination_route_card.dart';
import 'package:provider/provider.dart';

class TravelRouteScreen extends StatefulWidget {
  final String routeTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String provinceName;
  final int routeIndex;
  
  const TravelRouteScreen({
    super.key,
    required this.routeTitle,
    required this.startDate,
    required this.endDate,
    required this.provinceName,
    required this.routeIndex,
  });

  @override
  _TravelRouteScreenState createState() => _TravelRouteScreenState();
}

class _TravelRouteScreenState extends State<TravelRouteScreen> {
  late List<String> categories;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    int numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    
    categories = List.generate(numberOfDays, (index) {
      return (index + 1) == 1 ? 'Day 1' : 'Day ${index + 1}';
    });
    
    selectedCategory = categories.first;
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.routeTitle,
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelector(
                categories: categories, 
                selectedCategory: selectedCategory, 
                onCategorySelected: onCategorySelected
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Consumer<RouteViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final route = viewModel.suggestedRoutes[widget.routeIndex];
                    final destinations = route['destinations'] as List<DestinationModel>;

                    if (destinations.isEmpty) {
                      return const Center(
                        child: Text('No destinations in this route'),
                      );
                    }

                    return ListView.builder(
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        final routeData = route['routes'] as List;
                        final destinationRoute = routeData.firstWhere(
                          (r) => r['destinationId'] == destination.destinationId,
                          orElse: () => {'timeline': '${8 + index}:00 AM - ${9 + index}:00 AM'},
                        );

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: DestinationRouteCard(
                            name: destination.destinationName,
                            imagePath: destination.photo.isNotEmpty 
                                ? destination.photo[0] 
                                : 'assets/img/bg_route_1.png',
                            timeRange: destinationRoute['timeline'] as String,
                            onTap: () {
                              // Handle destination tap
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () async {
                  final viewModel = Provider.of<RouteViewModel>(context, listen: false);
                  final selectedRoute = viewModel.suggestedRoutes[widget.routeIndex];
                  
                  // Chỉ lưu route đã có
                  await viewModel.saveExistingRoute(
                    route: selectedRoute,
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                  );

                  Navigator.of(context, rootNavigator: true).popUntil(
                    (route) => route.isFirst || route.settings.name == '/home'
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Choose This Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
