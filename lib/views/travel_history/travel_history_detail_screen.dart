import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/historical_destination_list.dart';

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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
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
                            widget.province.provinceName,
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
          body: Column(
            children: [
              // TabBar
              Container(
                height: 40.h,
                margin: EdgeInsets.only(top: 20.h),
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
                        text: AppLocalizations.of(context).translate('Car Rental'),
                      ),
                    ),
                  ],
                ),
              ),
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    // Tab Destinations
                    _buildDestinationsTab(destinationsViewModel, visitDates),

                    // Tab Vehicles (Placeholder)
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate('Coming soon'),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
