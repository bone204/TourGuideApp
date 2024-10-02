import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/widgets/horizontal_card.dart';

class HorizontalCardListView extends StatelessWidget {
  final List<HorizontalCardData> cardDataList;

  const HorizontalCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return SizedBox(
      height: 390.h, // Sử dụng chiều cao dựa trên ScreenUtil
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 15.w), // Khoảng cách giữa các card sử dụng ScreenUtil
            child: HorizontalCard(data: cardDataList[index]),
          );
        },
      ),
    );
  }
}
