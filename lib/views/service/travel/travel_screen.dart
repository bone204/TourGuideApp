import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/travel/travel_event.dart';
import 'package:tourguideapp/blocs/travel/travel_state.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/travel/province_list_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/travel/travel_bloc.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';

class TravelScreen extends StatelessWidget {
  static const routeName = '/travel';

  @override
  Widget build(BuildContext context) {
    // Đảm bảo luôn gọi LoadTravelRoutes khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<TravelBloc>().add(LoadTravelRoutes());
      }
    });
    
    return const TravelScreenContent();
  }
}

class TravelScreenContent extends StatelessWidget {
  const TravelScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('Travel'),
          onBackPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
        body: BlocConsumer<TravelBloc, TravelState>(
          listener: (context, state) {
            if (state is TravelRouteCreated || state is TravelRouteUpdated) {
              context.read<TravelBloc>().add(LoadTravelRoutes());
            }
          },
          builder: (context, state) {
            // Xử lý state TravelEmpty ngay sau TravelLoading
            if (state is TravelLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Hiển thị màn hình thêm route khi không có route nào
            if (state is TravelEmpty || state is TravelInitial) {
              return _buildEmptyView(context);
            }
            
            if (state is TravelLoaded) {
              return _buildRouteList(context, state.routes);
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
              AppLocalizations.of(context).translate("You haven't created any travel routes yet."),
              style: TextStyle(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Builder(
              builder: (context) => CustomElevatedButton(
                text: 'Create Route',
                onPressed: () {
                  final bloc = context.read<TravelBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: const ProvinceListScreen(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteList(BuildContext context, List<TravelRouteModel> routes) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: ListView.builder(
        itemCount: routes.length + 1,
        itemBuilder: (context, index) {
          if (index == routes.length) {
            return CustomElevatedButton(
              text: AppLocalizations.of(context).translate("Add New Route"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<TravelBloc>(context),
                      child: const ProvinceListScreen(),
                    ),
                  ),
                );
              },
            );
          }
          
          final route = routes[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: RouteCard(
              name: route.routeName,
              imagePath: 'assets/img/bg_route_${index % 4 + 1}.png', 
              rating: 5.0, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<TravelBloc>(),
                      child: RouteDetailScreen(
                        routeName: route.routeName,
                        startDate: route.startDate,
                        endDate: route.endDate,
                        provinceName: route.province,
                        existingRouteId: route.travelRouteId,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tourguideapp/localization/app_localizations.dart';
// import 'package:tourguideapp/widgets/custom_elevated_button.dart';
// import 'package:tourguideapp/widgets/custom_icon_button.dart';
// import 'package:tourguideapp/views/service/travel/province_list_screen.dart';
// import 'package:tourguideapp/widgets/route_card.dart';
// import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
// import 'package:tourguideapp/models/destination_model.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tourguideapp/blocs/travel_route/travel_route_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class TravelScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => TravelRouteBloc(
//             firestore: FirebaseFirestore.instance,
//             auth: FirebaseAuth.instance,
//           )..add(LoadTravelRoutes()),
//         ),
//       ],
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: _buildAppBar(context),
//           body: BlocBuilder<TravelRouteBloc, TravelRouteState>(
//             builder: (context, state) {
//               if (state is TravelRouteLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
              
//               if (state is TravelRouteError) {
//                 return Center(child: Text(state.message));
//               }
              
//               if (state is TravelRouteLoaded) {
//                 if (state.userRoutes.isEmpty) {
//                   return _buildEmptyView(context);
//                 }
//                 return _buildRouteList(context, state.userRoutes);
//               }
              
//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyView(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
//       child: Align(
//         alignment: Alignment.center,
//         child: Column(
//           children: [
//             ClipRRect(
//               child: Image.asset(
//                 'assets/img/my_vehicle_1.png',
//                 height: 192.h,
//                 width: 192.w,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               AppLocalizations.of(context).translate("You haven't created any travel routes yet."),
//               style: TextStyle(
//                 color: const Color(0xFF6C6C6C),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16.sp,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             CustomElevatedButton(
//               text: "Create Route",
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ProvinceListScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRouteList(BuildContext context, List<Map<String, dynamic>> routes) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Column(
//         children: [
//           SizedBox(height: 20.h),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ...List.generate(
//                     routes.length,
//                     (index) {
//                       final route = routes[index];
//                       final routeTitle = route['routeTitle'] as String? ?? 'Untitled Route';
                      
//                       return Padding(
//                         padding: EdgeInsets.only(bottom: 16.h),
//                         child: RouteCard(
//                           name: routeTitle,
//                           imagePath: route['avatar'] ?? 'assets/img/bg_route_1.png',
//                           rating: (route['averageRating'] ?? 0.0).toDouble(),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => RouteDetailScreen(
//                                   routeTitle: routeTitle,
//                                   destinations: (route['destinations'] as List? ?? [])
//                                     .map((d) => DestinationModel.fromJson(d))
//                                     .toList(),
//                                   startDate: DateTime.now(),
//                                   endDate: DateTime.now().add(const Duration(days: 1)),
//                                   provinceName: route['province'] as String? ?? '',
//                                   isCustomRoute: route['isCustomRoute'] ?? true,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                   CustomElevatedButton(
//                     text: "Create Route",
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ProvinceListScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSize _buildAppBar(BuildContext context) {
//     return PreferredSize(
//       preferredSize: Size.fromHeight(60.h),
//       child: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         scrolledUnderElevation: 0,
//         shadowColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         flexibleSpace: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             SizedBox(
//               height: 40.h,
//               child: Stack(
//                 children: [
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: CustomIconButton(
//                       icon: Icons.chevron_left,
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       AppLocalizations.of(context).translate('Travel'),
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
