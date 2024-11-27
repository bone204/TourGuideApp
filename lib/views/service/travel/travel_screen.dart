import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/province_card.dart';
import 'package:tourguideapp/widgets/province_list_card.dart';
import 'package:tourguideapp/viewmodels/province_view_model.dart';
import 'package:tourguideapp/views/service/travel/suggest_route_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final ProvinceViewModel _viewModel = ProvinceViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchProvinces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
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
        body: Padding(
          padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
          child: Column(
            children: [
              CustomSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  _viewModel.searchProvinces(value);
                },
              ),
              SizedBox(height: 10.h),
              AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  if (_viewModel.isLoading) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (_viewModel.error.isNotEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(_viewModel.error),
                      ),
                    );
                  }

                  if (_viewModel.provinces.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          _searchController.text.isEmpty 
                              ? 'Không có dữ liệu' 
                              : 'Không tìm thấy kết quả',
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ProvinceListCard(
                      cards: _viewModel.provinceCards.map((card) {
                        return ProvinceCard(
                          name: card.name,
                          imageUrl: card.imageUrl,
                          rating: card.rating,
                          isFavorite: card.isFavorite,
                          onFavoritePressed: () {
                            // Xử lý favorite
                          },
                          onTap: () {
                            // Điều hướng đến SuggestRouteScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuggestRouteScreen(
                                  provinceName: card.name,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ),
    );
  }
}
