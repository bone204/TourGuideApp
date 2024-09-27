import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/horizontal_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); // Initialize ScreenUtil

    final homeViewModel = Provider.of<HomeViewModel>(context);

    final List<HorizontalCardData> horizontalCards = [
      HorizontalCardData(
        imageUrl:
            'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 1',
        description: 'Description for Place 1',
        price: r'$160.05',
        rating: 4.5,
        ratingCount: 12,
      ),
      // Add other card data here
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w), // Use ScreenUtil for padding
          child: Column(
            children: [
              UserHeader(
                name: homeViewModel.name,
                profileImageUrl: homeViewModel.profileImageUrl,
              ),
              SizedBox(height: 20.h), // Adjust size with ScreenUtil
              const HeaderBar(),
              SizedBox(height: 20.h),
              const SectionHeadline(
                title: "Popular",
                subtitle: "The best destination for you",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: 10.h),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: 20.h),
              const SectionHeadline(
                title: "Nearest Places",
                subtitle: "The best destination close to you",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: 10.h),
              HorizontalCardListView(cardDataList: horizontalCards),
              // Add other sections similarly...
            ],
          ),
        ),
      ),
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(22.r), // Use ScreenUtil for radius
          ),
          padding: EdgeInsets.all(8.w), // Adjust padding
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.w, // Use ScreenUtil for radius
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[600], size: 20.sp) // Adjust icon size
                    : null,
              ),
              SizedBox(width: 12.w), // Adjust spacing
              Text(
                name,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp, // Adjust text size
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            iconSize: 24.sp, // Adjust icon size
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification button pressed')),
              );
            },
          ),
        ),
      ],
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
                fontSize: 38.sp, // Use ScreenUtil for text size
              ),
            ),
            SizedBox(height: 5.h), // Adjust size
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Beautiful ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 38.sp, // Adjust text size
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
                fontSize: 20.sp, // Adjust text size
              ),
            ),
            SizedBox(height: 5.h), // Adjust spacing
            Text(
              AppLocalizations.of(context).translate(subtitle),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp, // Adjust text size
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
              fontSize: 14.sp, // Adjust text size
            ),
          ),
        ),
      ],
    );
  }
}
