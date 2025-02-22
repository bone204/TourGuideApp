import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/views/service/travel/province_list_screen.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/travel_route/travel_route_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TravelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TravelRouteBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          )..add(LoadTravelRoutes()),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context),
          body: BlocBuilder<TravelRouteBloc, TravelRouteState>(
            builder: (context, state) {
              if (state is TravelRouteLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is TravelRouteError) {
                return Center(child: Text(state.message));
              }
              
              if (state is TravelRouteLoaded) {
                if (state.userRoutes.isEmpty) {
                  return _buildEmptyView(context);
                }
                return _buildRouteList(context, state.userRoutes);
              }
              
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
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

  Widget _buildRouteList(BuildContext context, List<Map<String, dynamic>> routes) {
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
                    routes.length,
                    (index) {
                      final route = routes[index];
                      final routeTitle = route['routeTitle'] as String? ?? 'Untitled Route';
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: RouteCard(
                          name: routeTitle,
                          imagePath: route['avatar'] ?? 'assets/img/bg_route_1.png',
                          rating: (route['averageRating'] ?? 0.0).toDouble(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RouteDetailScreen(
                                  routeTitle: routeTitle,
                                  destinations: (route['destinations'] as List? ?? [])
                                    .map((d) => DestinationModel.fromJson(d))
                                    .toList(),
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now().add(const Duration(days: 1)),
                                  provinceName: route['province'] as String? ?? '',
                                  isCustomRoute: route['isCustomRoute'] ?? true,
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

  PreferredSize _buildAppBar(BuildContext context) {
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
