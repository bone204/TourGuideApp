import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class HorizontalCardListView extends StatelessWidget {
  final List<HorizontalCardData> cardDataList;

  const HorizontalCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 390.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: HorizontalCard(
              data: cardDataList[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetailPage(data: cardDataList[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
