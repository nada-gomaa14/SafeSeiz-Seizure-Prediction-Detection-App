import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/navigation/navigation_layout.dart';
import 'package:safeseiz/screens/ProfilePage.dart';
import 'package:safeseiz/screens/StartPage.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_states.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        if (state is AuthInitialState || state is AuthLoadingState) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              ),
            ),  
          );
        }

        if (state is AuthUnauthenticatedState) {
          return const StartPage();
        }

        final contactsCubit = context.watch<EmergencyContactsCubit>();
        final contactsState = context.watch<EmergencyContactsCubit>().state;
        bool hasMinimumContacts = false;

        if (contactsState is EmergencyContactsLoadedState) {
          hasMinimumContacts = contactsCubit.hasMinimumContacts;
        }

        debugPrint(
          'AUTH GATE => '
          'auth=${state.runtimeType}, '
          'contactsState=${contactsState.runtimeType}, '
          'contacts=${contactsCubit.contacts.length}, '
          'hasMinimum=${contactsCubit.hasMinimumContacts}',
        );

        if (contactsState is EmergencyContactsLoadingState || contactsState is EmergencyContactsInitialState) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),  
          );
        }

        if (state is AuthAuthenticatedState && !hasMinimumContacts) {
          return const ProfilePage();
        }

        return const NavigationLayout();
      },
    );
  }
}