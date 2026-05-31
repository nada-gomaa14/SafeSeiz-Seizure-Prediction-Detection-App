import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UsernameWidget extends StatelessWidget {
  const UsernameWidget({super.key, required this.usernameController});
  
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r);
    
    return TextFormField(
      validator: (value) {
        if(value == null || value.isEmpty) {
            return 'This field is required.';
        }
        else {
          return null;
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: usernameController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp
      ),
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey
        ),
        hintText: 'Enter your username',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
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
      ),
      keyboardType: TextInputType.text,
    );
  }
}