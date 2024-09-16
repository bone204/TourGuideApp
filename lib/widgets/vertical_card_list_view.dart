import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/vertical_card.dart';

class VerticalCardListView extends StatelessWidget {
  final List<VerticalCardData> cardDataList;

  const VerticalCardListView({required this.cardDataList, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cardDataList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: VerticalCard(data: cardDataList[index]),
        );
      },
    );
  }
}
