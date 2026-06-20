import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notify(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // Hide the existing one

  return messenger.showSnackBar(
    SnackBar(
      margin: EdgeInsets.all(16.r * Responsive.scale(context)),
      elevation: 4,
      backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 16.sp * Responsive.scale(context),
          fontWeight: FontWeight.bold
        ),
      ),
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.horizontal,
    )
  );
}