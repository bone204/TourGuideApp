import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';

class CancelRentalDialog extends StatefulWidget {
  final Function(String) onConfirm;

  const CancelRentalDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CancelRentalDialog> createState() => _CancelRentalDialogState();
}

class _CancelRentalDialogState extends State<CancelRentalDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: AppLocalizations.of(context).translate("Cancel Rental"),
      content: null,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).translate("Back")),
        ),
        TextButton(
          onPressed: () {
            if (_reasonController.text.isNotEmpty) {
              widget.onConfirm(_reasonController.text);
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context).translate("Confirm")),
        ),
      ],
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      backgroundColor: Colors.white,
    );
  }
}
