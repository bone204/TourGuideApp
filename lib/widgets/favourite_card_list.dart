import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';

class FavouriteCardListView extends StatelessWidget {
  final List<FavouriteCardData> cardDataList;
  final Function(FavouriteCardData) onCardTap;

  const FavouriteCardListView({
    Key? key,
    required this.cardDataList,
    required this.onCardTap,
  }) : super(key: key);

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
          final data = cardDataList[index];
          return GestureDetector(
            onTap: () => onCardTap(data),
            child: FavouriteCard(data: data),
          );
        },
      ),
    );
  }
}
