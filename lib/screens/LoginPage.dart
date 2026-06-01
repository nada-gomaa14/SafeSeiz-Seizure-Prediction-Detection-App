import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/navigation/auth_gate.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/screens/RegistrationPage.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/EmailWidget.dart';
import 'package:safeseiz/widgets/PasswordWidget.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: BlocConsumer<AuthCubit, AuthStates>(
            listener: (context, state) {
              if (state is AuthAuthenticatedState) {
                FocusScope.of(context).unfocus();
                log('Login Success');
                notify(context, 'Login successful');

                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthGate()
                  ),
                  (route) => false
                );

                loginEmailController.clear();
                loginPasswordController.clear();
              } else if (state is LoginErrorState) {
                log(state.error);
                notify(context, state.error);
              }
            },
            builder: (context, state) {
              final authCubit = context.read<AuthCubit>();
              final isLoading = state is LoginLoadingState;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0.w,
                  vertical: 10.0.h
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),
                      // Logo
                      Container(
                        width: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/logo.png')
                        ),
                      ),
                      SizedBox(height: 40.h),
                      // Title
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      ),
                      SizedBox(height: 5.h),
                      // Subtitle
                      Text(
                        'Log into your SafeSeiz account',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 18.sp,
                          color: Theme.of(context).colorScheme.tertiary
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            EmailWidget(emailController: loginEmailController),
                            SizedBox(height: 20.h),
                            PasswordWidget(label: 'Password', passwordController: loginPasswordController)
                          ],
                        )
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              authCubit.resetPasswordVisibility();
                              //ADD NAVIGATION TO FORGOT PASSWORD PAGE
                            },
                            child: Text(
                              'Forgot password?',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15.h),
                      // Login Button
                      CustomButton(
                        text: "Login",
                        width: double.infinity,
                        onTap: isLoading ? null : () {
                          if (formKey.currentState!.validate()) {
                            authCubit.resetPasswordVisibility();

                            authCubit.login(
                              email: loginEmailController.text.trim(),
                              password: loginPasswordController.text.trim()
                            );
                          }
                        },
                        child: isLoading 
                          ? Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                              )
                            )
                          : null
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).colorScheme.tertiary, 
                              thickness: 1
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).colorScheme.tertiary, 
                              thickness: 1
                            )
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Google Login Button
                      CustomButton(
                        text: 'Continue with Google',
                        textColor: Colors.black,
                        color: Colors.transparent,
                        width: double.infinity,
                        border: Theme.of(context).colorScheme.tertiary,
                        onTap: () {
                          //ADD GOOGLE SIGN IN FUNCTIONALITY
                        },
                      ),
                      SizedBox(height: 10.h),
                      // Register Redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 14.sp
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationPage()
                               )
                              );
                              authCubit.resetPasswordVisibility();
                            },
                            child: Text(
                              'Register now',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            ),
                         )
                       ],
                     )
                    ],
                 ),
                )
              );
           }
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }
}