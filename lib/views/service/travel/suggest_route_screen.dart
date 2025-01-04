import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:tourguideapp/views/service/travel/travel_route_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class SuggestRouteScreen extends StatefulWidget {
  final String provinceName;
  
  const SuggestRouteScreen({
    super.key,
    required this.provinceName,
  });

  @override
  _SuggestRouteScreenState createState() => _SuggestRouteScreenState();
}

class _SuggestRouteScreenState extends State<SuggestRouteScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    // Load suggested routes khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<RouteViewModel>(context, listen: false)
            .loadSuggestedRoutes(widget.provinceName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.provinceName,
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
              RangeDateTimePicker(
                startDate: _startDate,
                endDate: _endDate,
                onDateRangeSelected: (DateTimeRange range) {
                  setState(() {
                    _startDate = range.start;
                    _endDate = range.end;
                  });
                },
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                text: "Create Custom Route",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final textController = TextEditingController();
                      return AlertDialog(
                        title: const Text('Create New Route'),
                        content: TextField(
                          controller: textController,
                          decoration: const InputDecoration(
                            hintText: 'Enter route name',
                            labelText: 'Route Name',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final routeName = textController.text;
                              if (routeName.isNotEmpty) {
                                final routeViewModel = Provider.of<RouteViewModel>(context, listen: false);
                                final routeTitle = await routeViewModel.createNewCustomRoute(
                                  provinceName: widget.provinceName,
                                  routeTitle: routeName,
                                );
                                Navigator.pop(context);
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RouteDetailScreen(
                                      routeTitle: routeTitle,
                                      destinations: const [],
                                      startDate: _startDate,
                                      endDate: _endDate,
                                      provinceName: widget.provinceName,
                                      isCustomRoute: true,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context).translate('Suggested Route'),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Consumer<RouteViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.suggestedRoutes.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context).translate('No suggested routes available'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: viewModel.suggestedRoutes.length,
                      itemBuilder: (context, index) {
                        final route = viewModel.suggestedRoutes[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: RouteCard(
                            name: route['name'],
                            imagePath: viewModel.getImagePath(index % 4 + 1),
                            rating: route['rating'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TravelRouteScreen(
                                    routeTitle: route['name'],
                                    startDate: _startDate,
                                    endDate: _endDate,
                                    provinceName: route['province'],
                                    routeIndex: index,
                                  ),
                                ),
                              );
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
        )
      ),
    );
  }
}
