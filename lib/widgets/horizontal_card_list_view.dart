import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class HorizontalCardListView extends StatelessWidget {
  final List<HorizontalCardData> cardDataList;
  final Function(HorizontalCardData) onCardTap; // Thêm callback cho khi nhấn vào card

  const HorizontalCardListView({
    required this.cardDataList,
    required this.onCardTap, // Thêm onCardTap vào constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 390.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          final data = cardDataList[index];
          return Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: HorizontalCard(
              data: data,
              onTap: () => onCardTap(data), // Gọi hàm khi nhấn vào card
            ),
          );
        },
      ),
    );
  }
}
