import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/horizontal_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); // Khởi tạo ScreenUtil

    final homeViewModel = Provider.of<HomeViewModel>(context);

    final List<HorizontalCardData> horizontalCards = [
      HorizontalCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
        rating: 4.5,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w), // Sử dụng ScreenUtil cho padding
          child: Column(
            children: [
              UserHeader(
                name: homeViewModel.name,
                profileImageUrl: homeViewModel.profileImageUrl,
              ),
              SizedBox(height: 20.h), // Điều chỉnh kích thước bằng ScreenUtil
              const HeaderBar(),
              SizedBox(height: 20.h),
              buildSectionHeadline(context, "Popular", "The best destination for you", horizontalCards),
              SizedBox(height: 20.h),
              buildSectionHeadline(context, "Nearest Places", "The best destination close to you", horizontalCards),
              // Thêm các phần khác tương tự...
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeadline(BuildContext context, String title, String subtitle, List<HorizontalCardData> cardDataList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeadline(
          title: title,
          subtitle: subtitle,
          viewAllColor: const Color(0xFFFF7029),
        ),
        SizedBox(height: 12.h),
        HorizontalCardListView(cardDataList: cardDataList),
      ],
    );
  }
}

class UserHeader extends StatelessWidget {
  final String name;
  final String profileImageUrl;

  const UserHeader({
    required this.name,
    required this.profileImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProfileContainer(),
        _buildNotificationButton(context),
      ],
    );
  }

  Widget _buildProfileContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.black, width: 1.w),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 4.w, 12.w, 4.w), // Điều chỉnh padding
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.w, // Sử dụng ScreenUtil cho radius
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? Icon(Icons.person, color: Colors.grey[600], size: 20.sp) // Điều chỉnh kích thước icon
                : null,
          ),
          SizedBox(width: 12.w), // Điều chỉnh khoảng cách
          Text(
            name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp, // Điều chỉnh kích thước văn bản
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications),
        iconSize: 24.sp, // Điều chỉnh kích thước icon
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification button pressed')),
          );
        },
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore the',
              style: TextStyle(
                color: Colors.black,
                fontSize: 38.sp, 
              ),
            ),
            SizedBox(height: 5.h), 
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Beautiful ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 38.sp, 
                    ),
                  ),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(
                      color: const Color(0xFFFF7029),
                      fontWeight: FontWeight.bold,
                      fontSize: 34.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionHeadline extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color viewAllColor;

  const SectionHeadline({
    required this.title,
    required this.subtitle,
    required this.viewAllColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate(title),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp, 
              ),
            ),
            SizedBox(height: 5.h), 
            Text(
              AppLocalizations.of(context).translate(subtitle),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp, 
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            AppLocalizations.of(context).translate("View all"),
            style: TextStyle(
              color: viewAllColor,
              fontSize: 14.sp, // Điều chỉnh kích thước văn bản
            ),
          ),
        ),
      ],
    );
  }
}
