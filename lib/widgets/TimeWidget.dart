import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.timeController,
    required this.label,
    required this.onTimeSelected,
    this.initialTime,
    this.enabled = true,
  });

  final TextEditingController timeController;
  final String label;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool enabled;

  Future<void> _pickTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.secondary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.secondary,

              hourMinuteColor: Theme.of(context).colorScheme.primary,
              hourMinuteTextColor: Theme.of(context).colorScheme.secondary,
              hourMinuteTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 35.sp * Responsive.scale(context),
                fontWeight: FontWeight.bold,
              ),

              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Theme.of(context).colorScheme.secondary;
              }), 
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.secondary;
                }
                return Theme.of(context).colorScheme.primary;
              }), 
              dayPeriodTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp * Responsive.scale(context),
              ),

              dayPeriodBorderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),

              helpTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.primary,
              ),

              cancelButtonStyle: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp * Responsive.scale(context),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              confirmButtonStyle: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp * Responsive.scale(context),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selectedTime != null) {
      onTimeSelected(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r * Responsive.scale(context));

    return TextFormField(
      controller: timeController,
      readOnly: true,
      enabled: enabled,
      onTap: enabled
        ? () => _pickTime(context)
        : null,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 16.sp * Responsive.scale(context),
        color: Theme.of(context).colorScheme.primary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        hintText: 'Select time',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color:Theme.of(context).colorScheme.tertiary,
        ),
        suffixIcon: Icon(
          Icons.access_time,
          size: 18.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.error,
        ),
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            width: 2.r * Responsive.scale(context),
            color: Theme.of(context).colorScheme.error
          ),  
        ),
      ),
    );
  }
}