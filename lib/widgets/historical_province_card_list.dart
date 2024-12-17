import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/widgets/historical_province_card.dart';

class HistoricalProvinceCardList extends StatelessWidget {
  final List<Province> provinces;
  final List<String> visitDates;

  const HistoricalProvinceCardList({
    required this.provinces,
    required this.visitDates,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Expanded(  
      child: GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 335.w,
          mainAxisSpacing: 16.h, 
          crossAxisSpacing: 16.w, 
          childAspectRatio: 3,
        ),
        itemCount: provinces.length,
        itemBuilder: (context, index) {
          return HistoricalProvinceCard(
            province: provinces[index],
            visitDate: visitDates[index],
          );
        },
      ),
    );
  }
} 