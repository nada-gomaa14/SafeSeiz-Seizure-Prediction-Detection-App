import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({
    super.key,
    required this.dateController,
    required this.label,
    this.initialDate,
    required this.onDateSelected,
    this.enabled = true
  });

  final TextEditingController dateController;
  final String label;
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  final bool enabled;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    final initialDate = this.initialDate ?? DateTime(now.year - 20, now.month, now.day);
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D2DB8),
              onPrimary: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r);

    return TextFormField(
      validator: (value) {
        if (!enabled) return null;

        if (value == null || value.isEmpty) {
          return 'This field is required.';
        }
        return null;
      },
      onTap: () => enabled ? _pickDate(context) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: dateController,
      readOnly: true,
      enabled: enabled,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp,
          color: Theme.of(context).colorScheme.tertiary
        ),
        hintText: 'Select date',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          size: 18.sp,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp,
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
            width: 2.r,
            color: Theme.of(context).colorScheme.error
          ),  
        ),
      )
    );
  }
}