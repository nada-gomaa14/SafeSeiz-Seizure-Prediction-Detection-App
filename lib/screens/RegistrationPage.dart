import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/screens/LoginPage.dart';
import 'package:safeseiz/screens/PersonalInfoPage.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/EmailWidget.dart';
import 'package:safeseiz/widgets/PasswordWidget.dart';
import 'package:safeseiz/widgets/StepIndicator.dart';
import 'package:safeseiz/widgets/StrengthWidget.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> formKey = GlobalKey();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: BlocConsumer<AuthCubit, AuthStates>(
              listener: (context, state) {
                if (state is RegisterSuccessState) {
                  FocusScope.of(context).unfocus();
                  log('Registration success');
                  notify(context, 'Account created successfully');
      
                  if (!context.mounted) return;
      
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder : (context) => const PersonalInfoPage()
                    )
                  );
                } else if (state is RegisterErrorState) {
                  log(state.error);
                  notify(context, state.error);
                }
              },
              builder: (context, state) {
                final authCubit = context.read<AuthCubit>();
                final isLoading = state is RegisterLoadingState;
      
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0.w * Responsive.scale(context),
                    vertical: 10.0.h * Responsive.scale(context),
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Indicator
                        Center(
                          child: StepIndicator(activeStep: 1),
                        ),
                        SizedBox(height: 50.h * Responsive.scale(context)),
                        // Title
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 30.sp * Responsive.scale(context),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 5.h * Responsive.scale(context)),
                        // Subtitle
                        Text(
                          'Step 1 of 3 - Account details',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 18.sp * Responsive.scale(context),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        SizedBox(height: 30.h * Responsive.scale(context)),
                        //Form
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              EmailWidget(emailController: emailController),
                              SizedBox(height: 20.h * Responsive.scale(context)),
                              PasswordWidget(
                                label: 'Password',
                                passwordController: passwordController,
                                isRegister: true,
                              ),
                              SizedBox(height: 20.h * Responsive.scale(context)),
                              PasswordWidget(
                                label: 'Confirm Password',
                                passwordController: confirmPasswordController,
                                test: passwordController,
                                isRegister: true,
                              ),
                              SizedBox(height: 20.h * Responsive.scale(context)),
                              StrengthWidget(),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h * Responsive.scale(context)),
                        // Continue Button
                        CustomButton(
                          text: "Continue",
                          width: double.infinity,
                          onTap: isLoading ? null : () {
                            if (formKey.currentState!.validate()) {
                              authCubit.resetPasswordVisibility();
                  
                              authCubit.register(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                username: usernameController.text.trim()
                              );
                            }
                          },
                          child: isLoading 
                            ? const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              )
                            : null
                        ),
                        SizedBox(height: 10.h * Responsive.scale(context)),
                        // Login Redirect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 14.sp * Responsive.scale(context),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                                authCubit.resetPasswordVisibility();
                              },
                              child: Text(
                                'Log in',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 14.sp * Responsive.scale(context),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    
                        SizedBox(height: 10.h * Responsive.scale(context)),
                    
                          /// SKIP (optional)
                        CustomButton(
                          text: "SKIP",
                          width: double.infinity,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PersonalInfoPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}