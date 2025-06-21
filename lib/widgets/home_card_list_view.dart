import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class HomeCardListView extends StatelessWidget {
  final List<HomeCardData> cardDataList;
  final Function(HomeCardData) onCardTap; // Thêm callback cho khi nhấn vào card
  final ScrollController? scrollController;
  final bool isLoading;
  final bool hasMore;

  const HomeCardListView({
    required this.cardDataList,
    required this.onCardTap, // Thêm onCardTap vào constructor
    this.scrollController,
    this.isLoading = false,
    this.hasMore = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int itemCount = cardDataList.length + (hasMore ? 1 : 0);
    return SizedBox(
      height: 420.h,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < cardDataList.length) {
            final data = cardDataList[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 6.h),
              child: HomeCard(
                data: data,
                onTap: () => onCardTap(data), 
              ),
            );
          } else {
            // Loading indicator cuối list
            return SizedBox(
              width: 80.w,
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }
}
