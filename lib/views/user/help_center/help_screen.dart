import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Help Screen"),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: const Text("Helloooooooooooo", style: TextStyle(fontSize: 100)),
    );
  }
}