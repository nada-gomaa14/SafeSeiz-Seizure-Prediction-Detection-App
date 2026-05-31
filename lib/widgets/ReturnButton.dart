import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
      },
      child: Container(
        height: 40.0.r,
        width: 40.0.r,
        padding: EdgeInsets.all(10.r),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        child: Icon(
          Icons.keyboard_arrow_left,
          size: 20.sp,
          color: Theme.of(context).colorScheme.primary,
        )          
      )  
    );
  }
}