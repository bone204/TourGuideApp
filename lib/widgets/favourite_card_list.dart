import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';

class FavouriteCardListView extends StatelessWidget {
  final List<FavouriteCardData> cardDataList;

  const FavouriteCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Expanded(  
      child: GridView.builder(
        padding: EdgeInsets.all(10.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          mainAxisSpacing: 20.h,
          childAspectRatio: 0.9, 
        ),
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return FavouriteCard(data: cardDataList[index]);
        },
      ),
    );
  }
}
