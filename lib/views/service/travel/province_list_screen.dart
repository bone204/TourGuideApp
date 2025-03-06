import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/travel/travel_bloc.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/province_card.dart';
import 'package:tourguideapp/viewmodels/province_view_model.dart';
import 'package:tourguideapp/views/service/travel/suggest_route_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProvinceListScreen extends StatefulWidget {
  const ProvinceListScreen({super.key});

  @override
  _ProvinceListScreenState createState() => _ProvinceListScreenState();
}

class _ProvinceListScreenState extends State<ProvinceListScreen> {
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
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return BlocProvider.value(
      value: context.read<TravelBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('Choose Province'),
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
          child: Column(
            children: [
              CustomSearchBar(
                controller: _searchController,
                hintText: AppLocalizations.of(context).translate("Search province to travel"),
                onChanged: (value) {
                  _viewModel.searchProvinces(value);
                },
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    if (_viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final provinces = _viewModel.provinces;
                    
                    if (provinces.isEmpty) {
                      return Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? AppLocalizations.of(context).translate('No provinces available')
                              : AppLocalizations.of(context).translate('No results found'),
                          style: TextStyle(
                            color: const Color(0xFF6C6C6C),
                            fontSize: 16.sp,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15.w,
                        mainAxisSpacing: 15.h,
                        childAspectRatio: 160/180,
                      ),
                      itemCount: _viewModel.provinceCards.length,
                      itemBuilder: (context, index) {
                        final card = _viewModel.provinceCards[index];
                        return ProvinceCard(
                          name: card.name,
                          imageUrl: card.imageUrl,
                          rating: card.rating,
                          isFavorite: card.isFavorite,
                          onFavoritePressed: () {
                            // Handle favorite if needed
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<TravelBloc>(),
                                  child: SuggestRouteScreen(
                                    provinceName: card.name,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 