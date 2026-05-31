import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';

class StrengthWidget extends StatelessWidget {
  const StrengthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        int strength = 0;
        String label = '';

        // ✅ Only read data if it's PasswordStrengthState
        if (state is PasswordStrengthState) {
          strength = state.strength;
          label = state.strengthLabel;
        }

        if (state is! PasswordStrengthState) {
          return const SizedBox();
        }

        final activeColor = _getStrengthColor(context, strength);
        final inactiveColor = Colors.grey.withValues(alpha: 0.3);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Bars
            Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 6.w),
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: index < strength
                          ? activeColor
                          : inactiveColor,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 8.h),

            /// 🔹 Label
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const TextSpan(text: 'Password Strength: '),
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🎨 Theme-based blue shades
  Color _getStrengthColor(BuildContext context, int strength) {
    final base = Theme.of(context).colorScheme.primary;

    switch (strength) {
      case 1:
        return base.withValues(alpha: 0.45);
      case 2:
        return base.withValues(alpha: 0.65);
      case 3:
        return base.withValues(alpha: 0.85);
      case 4:
        return base;
      default:
        return base.withValues(alpha: 0.25);
    }
  }
}