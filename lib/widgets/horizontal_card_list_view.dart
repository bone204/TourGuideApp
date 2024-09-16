import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class HorizontalCardListView extends StatelessWidget {
  final List<HorizontalCardData> cardDataList;

  const HorizontalCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardDataList.length,
        itemBuilder: (context, index) {
          return HorizontalCard(data: cardDataList[index]);
        },
      ),
    );
  }
}
