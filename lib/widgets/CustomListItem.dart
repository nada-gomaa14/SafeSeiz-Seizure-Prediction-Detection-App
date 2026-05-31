import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    super.key,
    required this.title,
    required this.color,
    this.subtitle,
    this.leading,
    this.trailing,
    this.trailingWidgets,
    this.trailingBackground,
    this.onTap,
  });

  final String title;
  final Color color;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? trailingBackground;
  final List<Widget>? trailingWidgets;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0.w,
        vertical: 10.0.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading
          if (leading != null) ...[
            leading!,
            SizedBox(width: 10.0.w),
          ],
          // Title + subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14.0.sp,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.0.h),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.0.w),
          /// Trailing widgets
          if (trailingWidgets != null)
            Expanded(
              child: Wrap(
                spacing: 7.0.w,
                runSpacing: 7.0.h,
                alignment: WrapAlignment.end,
                children: trailingWidgets!.map((widget) {
                  return Container(
                    padding: EdgeInsets.all(8.0.r),
                    decoration: trailingBackground != null
                      ? BoxDecoration(
                        color: trailingBackground,
                        borderRadius: BorderRadius.circular(20.r),
                      )
                    : null,  
                  child: widget
                  );
                }).toList(),
              ),
            )

          else if (trailing != null)
            Container(
              padding: EdgeInsets.all(8.0.r),
              decoration: trailingBackground != null
                ? BoxDecoration(
                  color: trailingBackground,
                  borderRadius: BorderRadius.circular(20.r),
                )
              : null,  
            child: trailing!
            ),
          ],
        ),
      ),
    );
  }
}