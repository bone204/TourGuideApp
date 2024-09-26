import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/horizontal_card_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
      HorizontalCardData(
        imageUrl:
            'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 2',
        description: 'Description for Place 2',
        price: r'$180.75',
        rating: 4.0,
        ratingCount: 15,
      ),
      HorizontalCardData(
        imageUrl:
            'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 3',
        description: 'Description for Place 3',
        price: r'$200.00',
        rating: 4.0,
        ratingCount: 15,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              UserHeader(
                name: homeViewModel.name,
                profileImageUrl: homeViewModel.profileImageUrl,
              ),
              SizedBox(height: screenWidth * 0.05),
              const HeaderBar(),
              SizedBox(height: screenWidth * 0.05),
              const SectionHeadline(
                title: "Popular",
                subtitle: "The best destination for you",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: screenWidth * 0.025),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: screenWidth * 0.05),
              const SectionHeadline(
                title: "Nearest Places",
                subtitle: "The best destination close to you",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: screenWidth * 0.025),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: screenWidth * 0.05),
              const SectionHeadline(
                title: "Recommended",
                subtitle: "Top picks for you",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: screenWidth * 0.025),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: screenWidth * 0.05),
              const SectionHeadline(
                title: "Trending",
                subtitle: "Popular destinations",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: screenWidth * 0.025),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: screenWidth * 0.05),
              const SectionHeadline(
                title: "New Arrivals",
                subtitle: "Recently added places",
                viewAllColor: Color(0xFFFF7029),
              ),
              SizedBox(height: screenWidth * 0.025),
              HorizontalCardListView(cardDataList: horizontalCards),
              SizedBox(height: screenWidth * 0.05),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                name,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore the',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.09,
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Beautiful ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.09,
                    ),
                  ),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(
                      color: const Color(0xFFFF7029),
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.09,
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
    final screenWidth = MediaQuery.of(context).size.width;

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
                fontSize: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              AppLocalizations.of(context).translate(subtitle),
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.04,
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
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
