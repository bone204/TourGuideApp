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
        backgroundColor: Colors.white,
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
                fontWeight: FontWeight.w700,
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
                        numberOfDays: route.numberOfDays,
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