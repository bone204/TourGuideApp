import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/destination_card.dart';

class DestinationCardListView extends StatelessWidget {
  final List<DestinationCardData> cardDataList;

  const DestinationCardListView({required this.cardDataList, super.key});

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
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return DestinationCard(data: cardDataList[index]);
        },
      ),
    );
  }
}
