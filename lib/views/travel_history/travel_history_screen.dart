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

  String _normalizeString(String text) {
    var output = text.toLowerCase();
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ|Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ|Ỳ|Ý|Ỵ|Ỷ|Ỹ': 'y',
      'đ|Đ': 'd'
    };

    vietnameseMap.forEach((key, value) {
      output = output.replaceAll(RegExp(key), value);
    });
    return output;
  }

  void _onSearchChanged(String query, ProvinceViewModel provinceViewModel) {
    if (query.isEmpty) {
      provinceViewModel.resetSearch();
    } else {
      final normalizedQuery = _normalizeString(query);
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

      provinceViewModel.filterProvinces((province) {
        final normalizedName = _normalizeString(province.provinceName);
        
        return queryWords.every((word) {
          return normalizedName.split(' ').any((nameWord) => nameWord.startsWith(word));
        });
      });
    }
  }

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

        return SafeArea(
          child: Scaffold(
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
          ),
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
