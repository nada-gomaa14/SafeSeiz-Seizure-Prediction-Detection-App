import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/sos/cubit/sos_cubit.dart';
import 'package:safeseiz/user/sos/cubit/sos_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  late final List<EmergencyContactsModel> contacts;
  late final String patientName;
  late final SOSCubit sosCubit;

  @override
  void initState() {
    super.initState();
    sosCubit = context.read<SOSCubit>();
    contacts = context.read<EmergencyContactsCubit>().contacts;
    patientName = context.read<ProfileCubit>().profile?.firstName ?? 'User';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sosCubit.startCountdown(contacts: contacts, patientName: patientName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SOSCubit, SOSStates>(
          listener: (context, state) {
            if (state is SOSErrorState) {
              log(state.error);
              notify(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is! SOSLoadedState) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              );
            }
            final loadedState = state;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: 10.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SOS Status Card                 
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: loadedState.alertCancelled
                          ? const Color(0xFF22A45D).withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                        border: Border.all(
                          color: loadedState.alertCancelled
                            ? const Color(0xFF22A45D)
                            : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 70.r,
                            width: 70.r,
                            padding: EdgeInsets.all(10.r),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: loadedState.alertCancelled
                                ? const Color(0xFF22A45D)
                                : Theme.of(context).colorScheme.error,
                            ),      
                            child: loadedState.alertCancelled
                              ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 40.sp,
                              )
                              : Text(
                                'SOS',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                )
                              )  
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            loadedState.alertCancelled
                              ? 'All Clear'
                              : loadedState.alertSent
                              ? 'Emergency Alert Sent'
                              : loadedState.isSending
                              ? 'Sending Emergency Alert'
                              : 'Emergency SOS',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: loadedState.alertCancelled
                                ? const Color(0xFF22A45D)
                                : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            loadedState.alertCancelled
                              ? 'Your emergency contacts were informed that you are safe.'
                              : loadedState.alertSent
                              ? 'Your emergency contacts received your location.'
                              : loadedState.isSending
                              ? 'Please wait while alerts are being sent.'
                              : 'Send an emergency alert with your live location.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.tertiary,
                              height: 1.5,
                            ),
                          ),
                          // Countdown
                          if (loadedState.countdownStarted &&
                            !loadedState.alertSent &&
                            !loadedState.isSending &&
                            !loadedState.alertCancelled)
                            Column(
                              children: [
                                SizedBox(height: 20.h),
                                Text(
                                  'Alert sends in',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  '00:${loadedState.secondsRemaining.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 20.h),
                          // Cancel Button
                          if (loadedState.countdownStarted &&
                            !loadedState.alertSent &&
                            !loadedState.isSending &&
                            !loadedState.alertCancelled)
                            CustomButton(
                              text: 'Cancel Alert',
                              textColor: Theme.of(context).colorScheme.error,
                              width: double.infinity,
                              color: Theme.of(context).colorScheme.secondary,
                              border: Theme.of(context).colorScheme.error,
                              onTap: () {
                                sosCubit.cancelAlert();
                              },
                            ),
                          // Sending Status
                          if (loadedState.isSending)
                            Column(
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                ),
                                SizedBox(height: 15.h),
                                Text(
                                  'Sending alerts...',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          // Return Home Button
                          if (loadedState.alertSent || loadedState.alertCancelled)
                            CustomButton(
                              text: 'Return Home',
                              width: double.infinity,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Contacts
                    Text(
                      'CONTACTS NOTIFIED',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      child: Column(
                        children: List.generate(contacts.length, (index) {
                          final contact = contacts[index];
                          final notified = loadedState.notifiedContacts[contact.phone] ?? false;
                          final initial = contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?';

                          return Column(
                            children: [
                              CustomListItem(
                                leading: Container(
                                  height: 40.r,
                                  width: 40.r,
                                  padding: EdgeInsets.all(8.r),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Text(
                                    initial,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 16.sp,
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )          
                                ),
                                title: contact.name,
                                color: Theme.of(context).colorScheme.primary,
                                subtitle: '${contact.relationship} - ${contact.phone}',
                                trailing: Text(
                                  notified
                                    ? 'Sent'
                                    : 'Pending',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: notified
                                      ? const Color(0xFF22A45D)
                                      : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                trailingBackground: notified
                                  ? const Color(0xFF22A45D).withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                              ),
                              if (index < contacts.length - 1)
                                SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Location
                    Text(
                      'LOCATION SHARED',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              loadedState.locationText,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Checklist
                    Text(
                      'AFTER THE SEIZURE',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: List.generate(loadedState.afterSeizureChecklist.entries.length, (index) {
                        final entry = loadedState.afterSeizureChecklist.entries.elementAt(index);
                      
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                sosCubit.toggleChecklist(entry.key);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 28.r,
                                    width: 28.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: entry.value
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                      border: Border.all(
                                        color: entry.value
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                    child: entry.value
                                      ? Icon(
                                        Icons.check,
                                        size: 18.sp,
                                        color: Theme.of(context).colorScheme.secondary,
                                      )
                                      : null,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style:
                                      Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < loadedState.afterSeizureChecklist.entries.length - 1)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5.h, 
                                  horizontal: 10.h,
                                ), 
                                child: Divider(
                                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5)
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

    @override
    void dispose() {
      sosCubit.resetSOS();
      super.dispose();
    }
}
