import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/navigation/auth_gate.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';
import 'package:safeseiz/widgets/ReturnButton.dart';
import 'package:safeseiz/functions/settings_prefs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool medicalReminders = false;
  bool sosAlerts = false;
  bool weeklyReport = false;
  bool darkMode = false;
  bool isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    checkDeletionRequest();
    _loadSettings(); // ← ADDED
  }

  // ← ADDED: loads saved toggle value from device storage
  Future<void> _loadSettings() async {
    final val = await SettingsPrefs.getMedReminders();
    if (!mounted) return;
    setState(() => medicalReminders = val);
  }

  Future<void> checkDeletionRequest() async {
    try {
      final authCubit = context.read<AuthCubit>();

      final hasPendingRequest = await authCubit.hasPendingDeletionRequest();

      if (!mounted) return;

      setState(() {
        isDeletingAccount = hasPendingRequest;
      });
    } catch (e) {
      debugPrint('Check deletion request error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 60.h * Responsive.scale(context),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp * Responsive.scale(context),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w * Responsive.scale(context)),
          child: ReturnButton(),
        ),
        leadingWidth: 60.w * Responsive.scale(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h * Responsive.scale(context)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w * Responsive.scale(context), vertical: 5.h * Responsive.scale(context)),
            child: Divider(
              color: Theme.of(context).colorScheme.tertiary,
              thickness: 1,
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthStates>(
              listener: (context, state) {
                if (state is AuthUnauthenticatedState) {
                  log('Log Out Success');
                  notify(context, 'Log out successful');

                  if (!context.mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const AuthGate()
                      ),
                          (route) => false
                  );
                }
                if (state is LogoutErrorState) {
                  log(state.error);
                  notify(context, state.error);
                }
              },
              builder: (context, state) {
                final authCubit = context.read<AuthCubit>();
                final isLoading = state is LogoutLoadingState;

                return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 30.0.w * Responsive.scale(context),
                        vertical: 10.0.h * Responsive.scale(context)
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notifications
                          Text(
                              'NOTIFICATIONS',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                          ),
                          SizedBox(height: 10.0.h * Responsive.scale(context)),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                            ),
                            child: Column(
                              children: [
                                CustomListItem(
                                  title: 'Medication reminders',
                                  color: Theme.of(context).colorScheme.primary,
                                  subtitle: 'Alert before each dose',
                                  trailing: Switch(
                                    value: medicalReminders,
                                    padding: EdgeInsets.zero,
                                    activeColor: Theme.of(context).colorScheme.secondary,
                                    activeTrackColor: Theme.of(context).colorScheme.primary,
                                    inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                                    inactiveTrackColor: Theme.of(context).colorScheme.tertiary,
                                    trackOutlineWidth: WidgetStateProperty.all(0),
                                    // ← CHANGED: now saves to device storage
                                    onChanged: (value) async {
                                      setState(() => medicalReminders = value);
                                      await SettingsPrefs.setMedReminders(value);
                                    },
                                  ),
                                ),
                                SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                CustomListItem(
                                  title: 'SOS alerts',
                                  color: Theme.of(context).colorScheme.primary,
                                  subtitle: 'Notify emergency contacts',
                                  trailing: Switch(
                                      value: sosAlerts,
                                      padding: EdgeInsets.zero,
                                      activeColor: Theme.of(context).colorScheme.secondary,
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                      inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                                      inactiveTrackColor: Theme.of(context).colorScheme.tertiary,
                                      trackOutlineWidth: WidgetStateProperty.all(0),
                                      onChanged: (value) {
                                        setState(() {
                                          sosAlerts = value;
                                        });
                                      }
                                  ),
                                ),
                                SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                CustomListItem(
                                  title: 'Weekly report',
                                  color: Theme.of(context).colorScheme.primary,
                                  subtitle: 'Summary every Sunday',
                                  trailing: Switch(
                                      value: weeklyReport,
                                      padding: EdgeInsets.zero,
                                      activeColor: Theme.of(context).colorScheme.secondary,
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                      inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                                      inactiveTrackColor: Theme.of(context).colorScheme.tertiary,
                                      trackOutlineWidth: WidgetStateProperty.all(0),
                                      onChanged: (value) {
                                        setState(() {
                                          weeklyReport = value;
                                        });
                                      }
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0.h * Responsive.scale(context)),
                          // Preferences
                          Text(
                              'PREFERENCES',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                          ),
                          SizedBox(height: 10.0.h * Responsive.scale(context)),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                            ),
                            child: Column(
                              children: [
                                CustomListItem(
                                  title: 'Language',
                                  color: Theme.of(context).colorScheme.primary,
                                  trailing: Text(
                                    'English',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12.sp * Responsive.scale(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                CustomListItem(
                                  title: 'Dark mode',
                                  color: Theme.of(context).colorScheme.primary,
                                  trailing: Switch(
                                      value: darkMode,
                                      padding: EdgeInsets.zero,
                                      activeColor: Theme.of(context).colorScheme.secondary,
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                      inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                                      inactiveTrackColor: Theme.of(context).colorScheme.tertiary,
                                      trackOutlineWidth: WidgetStateProperty.all(0),
                                      onChanged: (value) {
                                        setState(() {
                                          darkMode = value;
                                        });
                                      }
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0.h * Responsive.scale(context)),
                          // Support
                          Text(
                              'SUPPORT',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                          ),
                          SizedBox(height: 10.0.h * Responsive.scale(context)),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                            ),
                            child: Column(
                              children: [
                                CustomListItem(
                                    title: 'Privacy policy',
                                    color: Theme.of(context).colorScheme.primary,
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 20.sp * Responsive.scale(context),
                                      color: Theme.of(context).colorScheme.tertiary,
                                    )
                                ),
                                SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                CustomListItem(
                                    title: 'Help & support',
                                    color: Theme.of(context).colorScheme.primary,
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 20.sp * Responsive.scale(context),
                                      color: Theme.of(context).colorScheme.tertiary,
                                    )
                                ),
                                SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                CustomListItem(
                                    title: 'Terms & conditions',
                                    color: Theme.of(context).colorScheme.primary,
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 20.sp * Responsive.scale(context),
                                      color: Theme.of(context).colorScheme.tertiary,
                                    )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.0.h * Responsive.scale(context)),
                          // Logout
                          CustomButton(
                              text: "Log Out",
                              textColor: Theme.of(context).colorScheme.error,
                              width: double.infinity,
                              color: Colors.transparent,
                              border: Theme.of(context).colorScheme.error,
                              onTap: isLoading ? null : () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontSize: 20.sp * Responsive.scale(context),
                                      ),
                                    ),
                                    content: SizedBox(
                                      width: Responsive.isTablet(context) ? 500.w : 300.w,
                                      child: Text(
                                        'Are you sure you want to log out?',
                                        style: TextStyle(
                                          fontSize: 12.sp * Responsive.scale(context),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 12.sp * Responsive.scale(context),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          authCubit.logout();
                                        },
                                        child: Text(
                                          'Log out',
                                          style: TextStyle(
                                            fontSize: 12.sp * Responsive.scale(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
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
                          SizedBox(height: 10.0.h * Responsive.scale(context)),
                          // Delete Account
                          CustomButton(
                            text: isDeletingAccount
                                ? "Deletion Request Pending"
                                : "Delete Account",
                            textColor: Theme.of(context).colorScheme.secondary,
                            width: double.infinity,
                            color: Theme.of(context).colorScheme.error,
                            onTap: isDeletingAccount ? null : () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: 20.sp * Responsive.scale(context),
                                    ),
                                  ),
                                  content: SizedBox(
                                    width: Responsive.isTablet(context) ? 500.w : 300.w,
                                    child: Text(
                                      'Are you sure you want to request account deletion?\nProceeding will permanently delete all your data.',
                                      style: TextStyle(
                                        fontSize: 12.sp * Responsive.scale(context),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 12.sp * Responsive.scale(context),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);

                                        try {
                                          await authCubit.requestAccountDeletion();

                                          if (!context.mounted) return;

                                          setState(() {
                                            isDeletingAccount = true;
                                          });

                                          notify(context, 'Your deletion request has been sent.');

                                        } catch (e) {
                                          if (!context.mounted) return;

                                          notify(context, e.toString().replaceFirst('Exception: ', ''));
                                        }
                                      },
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 12.sp * Responsive.scale(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                );
              }
          )
      ),
    );
  }
}