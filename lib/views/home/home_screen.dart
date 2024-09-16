import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/vertical_card.dart';
import 'package:tourguideapp/widgets/horizontal_card_list_view.dart';
import 'package:tourguideapp/widgets/vertical_card_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final List<HorizontalCardData> horizontalCards = [
      HorizontalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 1',
        description: 'Description for Place 1',
        price: r'$160.05',
        rating: 4.5,
        ratingCount: 12,
      ),
      HorizontalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 2',
        description: 'Description for Place 2',
        price: r'$180.75',
        rating: 4.0,
        ratingCount: 15,
      ),
      HorizontalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 3',
        description: 'Description for Place 3',
        price: r'$200.00',
        rating: 4.0,
        ratingCount: 15,
      ),
    ];

    final List<VerticalCardData> verticalCards = [
      VerticalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 1',
        description: 'Description for Place 1',
        price: r'$160.05',
      ),
      VerticalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 2',
        description: 'Description for Place 2',
        price: r'$180.75',
      ),
      VerticalCardData(
        imageUrl: 'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        placeName: 'Place 3',
        description: 'Description for Place 3',
        price: r'$200.00',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              UserHeader(
                name: homeViewModel.name,
                profileImageUrl: homeViewModel.profileImageUrl,
              ),
              const SizedBox(height: 20),
              const HeaderBar(),
              const SizedBox(height: 20),
              const SectionHeadline(
                title: "Popular",
                subtitle: "The best destination for you",
                viewAllColor: Color(0xFFFF7029),
              ),
              const SizedBox(height: 10),
              HorizontalCardListView(cardDataList: horizontalCards),
              const SizedBox(height: 20),
              const SectionHeadline(
                title: "Nearest Places",
                subtitle: "The best destination close to you",
                viewAllColor: Color(0xFFFF7029),
              ),
              const SizedBox(height: 10),
              VerticalCardListView(cardDataList: verticalCards),
              const SizedBox(height: 20),
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
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(15),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore the',
              style: TextStyle(
                color: Colors.black,
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Beautiful ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                    ),
                  ),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(
                      color: Color(0xFFFF7029),
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
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
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              AppLocalizations.of(context).translate(subtitle),
              style: const TextStyle(
                color: Color(0xFF6C6C6C),
                fontSize: 14,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Add navigation or action here
          },
          child: Text(
            AppLocalizations.of(context).translate('View All'),
            style: TextStyle(color: viewAllColor),
          ),
        ),
      ],
    );
  }
}
