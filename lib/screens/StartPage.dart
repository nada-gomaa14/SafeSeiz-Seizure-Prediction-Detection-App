import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'LoginPage.dart';
import 'RegistrationPage.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30.0.w * Responsive.scale(context),
            vertical: 10.0.h * Responsive.scale(context)
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', width: constraints.maxWidth * 0.6),
                      SizedBox(height: 30.0.h * Responsive.scale(context)),
                      Text(
                        'SafeSeiz', 
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 50.sp * Responsive.scale(context), 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).colorScheme.secondary
                        ),
                      ),
                      SizedBox(height: 10.0.h * Responsive.scale(context)),
                      Text(
                        'Your personal seizure\nmanagement companion',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 18.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
                        )
                      ),  
                      SizedBox(height: constraints.maxHeight * 0.1),
                      CustomButton(
                        text: 'Get Started', 
                        color: Theme.of(context).colorScheme.secondary,
                        textColor: Theme.of(context).colorScheme.primary,
                        width: double.infinity,
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const RegistrationPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15.0.h * Responsive.scale(context)),
                      CustomButton(
                        text: 'Login',
                        width: double.infinity,
                        border: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 50.0.h * Responsive.scale(context)),
                      Text(
                        'By continuing, you agree to our\nTerms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
                        )
                      )  
                    ],  
                  ),
                ),
              );
            }
          ),
        )
      ),
    );
  }
}