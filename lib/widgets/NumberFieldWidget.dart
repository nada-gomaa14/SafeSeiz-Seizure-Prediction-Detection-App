import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';

class NumberFieldWidget extends StatelessWidget {
  const NumberFieldWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.hintText = '0',
    this.suffixText,
  });

  final String label;
  final String hintText;
  final String? suffixText;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r * Responsive.scale(context),
    );

    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: onChanged,
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
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        suffixText: 
          suffixText,
          suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
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