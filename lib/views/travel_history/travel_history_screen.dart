import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/destination_card.dart';
import 'package:tourguideapp/widgets/destinations_card_list.dart';
// import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import '../../widgets/custom_icon_button.dart';

class TravelHistoryScreen extends StatefulWidget {
  const TravelHistoryScreen({super.key});

  @override
  _TravelHistoryScreenState createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
    final List<DestinationCardData> destinationCards = [
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
      DestinationCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        time: '26-27/01/2024',
      ),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Travel History'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 10.h),
              DestinationsCardListView(cardDataList: destinationCards),
            ]
          ),
        )
      ),
    );
  }
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('Search'),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
