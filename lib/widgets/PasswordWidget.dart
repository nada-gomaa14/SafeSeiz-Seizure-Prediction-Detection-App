import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';


class PasswordWidget extends StatefulWidget {
  const PasswordWidget({super.key, required this.label, required this.passwordController, this.test, this.isRegister = false});

  final String label;
  final TextEditingController passwordController;
  final TextEditingController? test;
  final bool isRegister;

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15.r);

    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        AuthCubit authCubit = context.watch<AuthCubit>();
        return TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required.';
            }
            if (widget.isRegister) {
              if (value.length < 8) {
                return 'Must be at least 8 characters long.';
              }
              else if(!RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[a-z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
                return 'Must contain at least 1 uppercase letter, 1 lowercase letter, and 1 digit.';
              } 
            }  
            if(widget.test != null && value != widget.test!.text) {
              return 'Make sure both passwords are the same.';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.passwordController,
          obscureText: authCubit.isObscure,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.isRegister
            ? (widget.test != null
                ? TextInputAction.done
                : TextInputAction.next
            )
            : TextInputAction.done,
          maxLines: 1,
          onChanged: (value) {
            if (widget.isRegister && widget.label == 'Password') {
            context.read<AuthCubit>().showPasswordStrength(value);
            }
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16.sp
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey
            ),
            hintText: 'Enter your password',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            prefixIcon: const Icon(
              Icons.lock,
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
            suffixIcon: IconButton(
              onPressed: () {
                authCubit.changePasswordVisibility();
              },
              icon: authCubit.isObscure
                ? Icon(Icons.visibility, color: Colors.grey)
                : Icon(Icons.visibility_off, color: Colors.grey)
            )
          ),
        );
      },
    );
  }
}