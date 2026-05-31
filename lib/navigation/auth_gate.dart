import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/navigation/navigation_layout.dart';
import 'package:safeseiz/screens/ProfilePage.dart';
import 'package:safeseiz/screens/StartPage.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final hasMinimumContacts = context.select<EmergencyContactsCubit, bool>((cubit) => cubit.hasMinimumContacts);

    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        if (state is AuthInitialState) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              )
            )  
          );
        }

        if (state is AuthUnauthenticatedState) {
          return const StartPage();
        }

        if (state is AuthAuthenticatedState && !hasMinimumContacts) {
          return const ProfilePage();
        }

        return const NavigationLayout();
      },
    );
  }
}