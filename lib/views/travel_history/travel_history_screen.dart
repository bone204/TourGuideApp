import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/historical_province_card_list.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/province_view_model.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';

class TravelHistoryScreen extends StatefulWidget {
  const TravelHistoryScreen({super.key});

  @override
  _TravelHistoryScreenState createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProvinceViewModel>().fetchProvinces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProvinceViewModel>(
      builder: (context, provinceViewModel, child) {
        // Tạo danh sách ngày thăm giả lập
        final visitDates = List.generate(
          provinceViewModel.provinces.length,
          (index) => '26-27/01/2024'
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
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
                            AppLocalizations.of(context).translate('Travel History'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
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
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              children: [
                _buildSearchBar(provinceViewModel),
                if (provinceViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provinceViewModel.error.isNotEmpty)
                  Center(child: Text(provinceViewModel.error))
                else
                  HistoricalProvinceCardList(
                    provinces: provinceViewModel.provinces,
                    visitDates: visitDates,
                  ),
              ]
            ),
          )
        );
      }
    );
  }

  Widget _buildSearchBar(ProvinceViewModel provinceViewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: AppLocalizations.of(context).translate('Search'),
        onChanged: (value) => provinceViewModel.searchProvinces(value),
      ),
    );
  }
}
