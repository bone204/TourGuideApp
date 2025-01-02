import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/views/service/travel/province_list_screen.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/travel'),
          builder: (context) => _buildTravelScreen(),
        );
      },
    );
  }

  Widget _buildTravelScreen() {
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
                          onPressed: () => Navigator.of(context).pop(),
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
        ),
        body: Consumer<RouteViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.selectedRouteTitle == null) {
              return _buildEmptyView();
            }
            return _buildRouteList();
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
                'assets/img/my_vehicle_1.png', // You may want to use a different image
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

  Widget _buildRouteList() {
    return Consumer<RouteViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              children: [
                ...viewModel.savedRoutes.map((route) => Column(
                  children: [
                    RouteCard(
                      name: route['title'] as String,
                      imagePath: "assets/img/bg_route_1.png",
                      rating: 4.5,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteDetailScreen(
                              routeTitle: route['title'] as String,
                              destinations: route['destinations'] as List<DestinationModel>,
                              startDate: route['startDate'] as DateTime,
                              endDate: route['endDate'] as DateTime,
                              provinceName: route['provinceName'] as String,
                              isCustomRoute: route['isCustom'] as bool,
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                  ]
                )).toList(),
                
                CustomElevatedButton(
                  text: "Create New Route",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProvinceListScreen()),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
