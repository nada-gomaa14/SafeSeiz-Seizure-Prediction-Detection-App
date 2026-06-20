import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
      },
      child: Container(
        height: 40.0.r * Responsive.scale(context),
        width: 40.0.r * Responsive.scale(context),
        padding: EdgeInsets.all(10.r * Responsive.scale(context)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        child: Icon(
          Icons.keyboard_arrow_left,
          size: 20.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.primary,
        )          
      )  
    );
  }
}