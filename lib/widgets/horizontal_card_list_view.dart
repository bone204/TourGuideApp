import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class HorizontalCardListView extends StatelessWidget {
  final List<HorizontalCardData> cardDataList;

  const HorizontalCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.6, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04), 
            child: HorizontalCard(data: cardDataList[index]),
          );
        },
      ),
    );
  }
}
