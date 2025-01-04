import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

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
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate("Cancel Rental")),
      content: TextField(
        controller: _reasonController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)
              .translate("Enter reason for cancellation"),
        ),
        maxLines: 3,
      ),
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
    );
  }
}
