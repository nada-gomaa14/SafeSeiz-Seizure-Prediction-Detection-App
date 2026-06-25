import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';


class NameWidget extends StatelessWidget {
  const NameWidget({
    super.key, 
    required this.label, 
    required this.nameController,
    this.onChanged,
    this.hint
  });

  final String label;
  final TextEditingController nameController;
  final Function(String)? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r * Responsive.scale(context));

    return TextFormField(
      validator: (value) {
        if(value == null || value.trim().isEmpty) {
            return 'This field is required.';
        }
        else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value.trim())) {
          return 'Only letters are allowed.';
        }
        else {
          return null;
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: nameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      maxLines: 1,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
      ],
      onChanged: (value) {
        if (value.isEmpty) return;

        final capitalized = value[0].toUpperCase() + value.substring(1).toLowerCase();

        if (capitalized != value) {
          nameController.value = TextEditingValue(
            text: capitalized,
            selection: TextSelection.collapsed(offset: capitalized.length),
          );
        }
        onChanged?.call(capitalized);
      },
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp * Responsive.scale(context)
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary
        ),
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        prefixIcon: Icon(
          Icons.person,
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
            width: 2.r,
            color: Theme.of(context).colorScheme.error
          ),  
        ),
      ),
    );
  }
}