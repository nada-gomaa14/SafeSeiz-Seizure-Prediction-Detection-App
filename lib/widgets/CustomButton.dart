import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.text, this.textColor, this.color, this.width, this.height, this.border, required this.onTap, this.child});

  final String? text;
  final Color? textColor;
  final Color? color;
  final double? width;
  final double? height;
  final Color? border;
  final void Function()? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height ?? 60.h,
          width: width,
          padding: EdgeInsets.all(10.r),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.r)),
            color: color ?? Theme.of(context).colorScheme.primary,
            border: border != null
              ? Border.all(
                  color: border!,
                  width: 1.0.r,
                )
              : null
          ),
          child: child ??
            Text(
              text!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              )
            )  
        ),
      ),
    );
  }
}