import 'package:flutter/material.dart';
import 'package:track_vision/features/user/alerts/widgets/alerts_popup.dart';

void showAlertsPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      return const AlertsPopup();
    },
  );
}
