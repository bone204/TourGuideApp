import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/historical_destination_list.dart';
import 'package:tourguideapp/widgets/service_card.dart';

class TravelHistoryDetailScreen extends StatefulWidget {
  final Province province;

  const TravelHistoryDetailScreen({
    required this.province,
    super.key,
  });

  @override
  State<TravelHistoryDetailScreen> createState() => _TravelHistoryDetailScreenState();
}

class _TravelHistoryDetailScreenState extends State<TravelHistoryDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDestinationsTab(DestinationsViewModel viewModel, List<String> visitDates) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error.isNotEmpty) {
      return Center(child: Text(viewModel.error));
    }
    return HistoricalDestinationList(
      destinations: viewModel.destinations
          .where((dest) => dest.province == widget.province.provinceName)
          .toList(),
      visitDates: visitDates,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DestinationsViewModel>(
      builder: (context, destinationsViewModel, child) {
        final visitDates = List.generate(
          destinationsViewModel.destinations
              .where((dest) => dest.province == widget.province.provinceName)
              .length,
          (index) => '26-27/01/2024',
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: widget.province.provinceName,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              widget.province.imageUrl,
                              width: 335.w,
                              height: 188.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context).translate("Rate")}:",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(width: 30.w),
                              ...List.generate(5, (index) => Padding(
                                padding: EdgeInsets.only(right: 18.w),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 24.sp,
                                ),
                              )),
                            ],
                          ),
                          SizedBox(height: 30.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(
                              child: Text(
                                "This travel route is so exciting! Thanks for that.",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF007BFF),
                                    side: const BorderSide(color: Color(0xFF007BFF)),
                                    minimumSize: Size(double.infinity, 50.h),
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).translate("Cancel"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007BFF),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50.h),
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).translate("Give Review"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // TabBar
                    Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFEEEEEE),
                            width: 1.h,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
                          insets: EdgeInsets.zero,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.zero,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: const Color(0xFF7D848D),
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        tabs: [
                          SizedBox(
                            width: double.infinity,
                            child: Tab(
                              text: AppLocalizations.of(context).translate('Route'),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Tab(
                              text: AppLocalizations.of(context).translate('Service'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // TabBarView
                SizedBox(
                  height: 500.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // Tab Destinations
                      _buildDestinationsTab(destinationsViewModel, visitDates),
              
                      // Tab Vehicles (Placeholder)
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: const ServiceCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
