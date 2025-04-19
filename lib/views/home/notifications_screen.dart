import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

