import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class HomeCardListView extends StatelessWidget {
  final List<HomeCardData> cardDataList;
  final Function(HomeCardData) onCardTap; // Thêm callback cho khi nhấn vào card

  const HomeCardListView({
    required this.cardDataList,
    required this.onCardTap, // Thêm onCardTap vào constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          final data = cardDataList[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 6.h),
            child: HomeCard(
              data: data,
              onTap: () => onCardTap(data), 
            ),
          );
        },
      ),
    );
  }
}
