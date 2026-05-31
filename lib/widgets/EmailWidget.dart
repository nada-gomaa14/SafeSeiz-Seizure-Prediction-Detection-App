import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class EmailWidget extends StatelessWidget {
  const EmailWidget({super.key, this.emailController});

  final TextEditingController? emailController;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r);
    
    return TextFormField(
      validator: (value) {
        if(value == null || value.isEmpty) {
          return 'This field is required.';
        }
        if(!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value) || RegExp(r'\.\.').hasMatch(value) || value.endsWith('.')) {
          return "Incorrect email, make sure it's the right format.";
        }
        else {
          return null;
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      maxLines: 1,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp
      ),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey
        ),
        hintText: 'Enter your email',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        prefixIcon: const Icon(
          Icons.mail,
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
    );
  }
}