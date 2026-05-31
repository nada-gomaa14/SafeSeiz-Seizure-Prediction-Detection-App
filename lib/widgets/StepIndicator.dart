import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.activeStep});

  final int activeStep;
  
  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).colorScheme.onSurface;

    Widget buildNode(int step) {
      final isCompleted = step < activeStep;
      final isActive = step == activeStep;

      return Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isCompleted || isActive)
              ? activeColor
              : inactiveColor.withValues(alpha: 0.15),
          border: Border.all(
            color: (isCompleted || isActive) ? activeColor : inactiveColor,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: isCompleted
            ? Icon(Icons.check, color: Colors.white, size: 18.r)
            : Text(
                '$step',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : inactiveColor,
                ),
              ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StepItem(
          node: buildNode(1),
          label: 'Account',
          step: 1,
          activeStep: activeStep,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Divider(
              color: activeStep > 1 ? activeColor : inactiveColor,
              thickness: 1,
            )
          )
        ),
        _StepItem(
          node: buildNode(2),
          label: 'Personal',
          step: 2,
          activeStep: activeStep,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Divider(
              color: activeStep > 2 ? activeColor : inactiveColor,
              thickness: 1,
            )
          )
        ),
        _StepItem(
          node: buildNode(3),
          label: 'Medical',
          step: 3,
          activeStep: activeStep,
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.node,
    required this.label,
    required this.step,
    required this.activeStep,
  });

  final Widget node;
  final String label;
  final int step;
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step < activeStep;
    final isActive = step == activeStep;

    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        node,
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: (isCompleted || isActive)
                ? activeColor
                : inactiveColor,
          ),
        ),
      ],
    );
  }
}
