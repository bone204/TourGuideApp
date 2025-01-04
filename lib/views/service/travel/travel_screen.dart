import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/views/service/travel/province_list_screen.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:tourguideapp/models/destination_model.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<RouteViewModel>(context, listen: false).loadSavedRoutes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Consumer<RouteViewModel>(
          builder: (context, routeViewModel, child) {
            if (routeViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (routeViewModel.routes.isEmpty) {
              return _buildEmptyView();
            }

            return _buildRouteList(routeViewModel);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ClipRRect(
              child: Image.asset(
                'assets/img/my_vehicle_1.png',
                height: 192.h,
                width: 192.w,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).translate("You haven't created any travel routes yet."),
              style: TextStyle(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            CustomElevatedButton(
              text: "Create Route",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProvinceListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteList(RouteViewModel routeViewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(
                    routeViewModel.routes.length,
                    (index) {
                      final route = routeViewModel.routes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: RouteCard(
                          name: route['name'],
                          imagePath: routeViewModel.getImagePath(index % 4),
                          rating: route['rating'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RouteDetailScreen(
                                  routeTitle: route['name'],
                                  destinations: (routeViewModel.savedRoutes.firstWhere(
                                    (r) => r['title'] == route['name'],
                                    orElse: () => {'destinations': []},
                                  )['destinations'] as List? ?? []).cast<DestinationModel>(),
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now().add(const Duration(days: 1)),
                                  provinceName: route['province'],
                                  isCustomRoute: true,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  CustomElevatedButton(
                    text: "Create Route",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProvinceListScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
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
                      AppLocalizations.of(context).translate('Travel'),
                      style: TextStyle(
                        color: Colors.black,
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
    );
  }
}
