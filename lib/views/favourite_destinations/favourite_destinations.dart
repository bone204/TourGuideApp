import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/favourite_card_list.dart';
// import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import '../../widgets/custom_icon_button.dart';

class FavouriteDestinationsScreen extends StatefulWidget {
  const FavouriteDestinationsScreen({super.key});

  @override
  _FavouriteDestinationsState createState() => _FavouriteDestinationsState();
}

class _FavouriteDestinationsState extends State<FavouriteDestinationsScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
    final List<FavouriteCardData> favouriteCards = [
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
      FavouriteCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
      ),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h), // Chiều cao app bar
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).translate('Favourite Destinations'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp, 
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 88.w),
                      ],
                    );
                  },
                ),
              ]
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 10.h),
              FavouriteCardListView(cardDataList: favouriteCards),
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
          hintText: 'Search',
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
