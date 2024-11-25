import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/province_card.dart';

class ProvinceListCard extends StatelessWidget {
  final List<ProvinceCard> cards;

  const ProvinceListCard({
    Key? key,
    required this.cards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: (cards.length / 2).ceil(),
        itemBuilder: (context, index) {
          final int startIndex = index * 2;
          return Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cards[startIndex],
                if (startIndex + 1 < cards.length)
                  cards[startIndex + 1]
                else
                  SizedBox(width: 160.w),
              ],
            ),
          );
        },
      ),
    );
  }
} 