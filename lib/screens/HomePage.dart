import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/screens/LogSeizurePage.dart';
import 'package:safeseiz/screens/ProfilePage.dart';
import 'package:safeseiz/screens/SOSPage.dart';
import 'package:safeseiz/screens/WatchPage.dart';
import 'package:safeseiz/user/contact/cubit/emergency_contact_cubit.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/user/sos/cubit/sos_cubit.dart';
import 'package:safeseiz/widgets/CalendarWidget.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';

import '../user/seizure/cubit/seizure_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final date = DateFormat('EEEE, d MMM').format(DateTime.now());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileStates>(
          listener: (context, state) {
            if (state is ProfileErrorState) {
              log(state.error);
              notify(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              );
            }

            final profileCubit = context.read<ProfileCubit>();
            final name = profileCubit.profile?.firstName ?? 'User';

            final medicationCubit = context.watch<MedicationCubit>();
            final medications = medicationCubit.medications;
            final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

            int takenCount = 0;
            int totalCount = 0;

            for (final medication in medications) {
              totalCount += medication.times.length;
              final todayStatus = medication.takenStatus[today] ?? {};
              takenCount += todayStatus.values.where((taken) => taken).length;
            }

            final seizureCubit = context.read<SeizureCubit>();
            final stats = seizureCubit.getSummaryStats();

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
                    Row(
                      children: [
                        Text(
                          date,                  
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.sp * Responsive.scale(context),
                            color: Theme.of(context).colorScheme.tertiary
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WatchPage(patientName: name)
                              ),
                            );
                          },
                          child: Container(
                            height: 50.r * Responsive.scale(context),
                            width: 50.r * Responsive.scale(context),
                            padding: EdgeInsets.all(10.r * Responsive.scale(context)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Icon(
                              Icons.watch,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20.sp * Responsive.scale(context),
                            ),  
                          ),          
                        ),
                        SizedBox(width: 10.w * Responsive.scale(context)),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage()
                              ),
                            );
                          },
                          child: Container(
                            height: 50.r * Responsive.scale(context),
                            width: 50.r * Responsive.scale(context),
                            padding: EdgeInsets.all(10.r * Responsive.scale(context)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              name.split(' ')[0].substring(0, 1).toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 20.sp * Responsive.scale(context),
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            )          
                          )  
                        )
                      ],
                    ),
                    SizedBox(height: 5.h * Responsive.scale(context)),
                    Text(
                      'Hello, $name',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 25.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 5.h * Responsive.scale(context)),
                    Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                      thickness: 1,
                    ),
                    SizedBox(height: 5.h * Responsive.scale(context)),
                    BlocBuilder<SeizureCubit, SeizureStates>(
                      builder: (context, state) {
                        final seizureCubit = context.read<SeizureCubit>();
                        return CalendarWidget(seizures: seizureCubit.seizuresLogs);
                      }
                    ), 
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    Text(
                      'QUICK ACTIONS',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    CustomButton(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LogSeizurePage(),
                          ),
                        );
                      },
                      text: '+ Log Seizure',
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    CustomButton(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                      border: Theme.of(context).colorScheme.error,
                      height: 100.h * Responsive.scale(context),
                      width: double.infinity,
                      onTap: () async {
                        final seizureCubit = context.read<SeizureCubit>();
                        final medicalCubit = context.read<MedicalCubit>();
                        final sosCubit = context.read<SOSCubit>();
                        final contactsCubit = context.read<EmergencyContactsCubit>();
                        final profileCubit = context.read<ProfileCubit>();

                        final contacts = contactsCubit.contacts;
                        final firstName = profileCubit.profile?.firstName ?? '';
                        final lastName = profileCubit.profile?.lastName ?? '';
                        final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '$firstName $lastName'.trim();

                        sosCubit.startCountdown(
                          contacts: contacts, 
                          patientName: patientName,
                          onAlertConfirmed: () async {
                            final defaultTypes = medicalCubit.medical?.seizureTypes ?? ['Unknown'];
                            seizureCubit.seizureTypes = defaultTypes.isNotEmpty ? defaultTypes : ['Unknown'];
                            return await seizureCubit.addSeizure(isAutoDetected: false);
                          },
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SOSPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency SOS',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 16.sp * Responsive.scale(context),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error
                                  )
                                ),
                                Text(
                                  'Alert your emergency contacts',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 14.sp * Responsive.scale(context),
                                    color: Theme.of(context).colorScheme.error
                                  )  
                                )
                              ],
                            ),
                            const Spacer(),
                            Container(
                              height: 70.r * Responsive.scale(context),
                              width: 70.r * Responsive.scale(context),
                              padding: EdgeInsets.all(10.r * Responsive.scale(context)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Text(
                                'SOS',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16.sp * Responsive.scale(context),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                )
                              )  
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    Text(
                      "TODAY'S STATUS",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      child: Column(
                        children: [
                          CustomListItem(
                            leading: Icon(
                              Icons.medication,
                              size: 20.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Medications',
                            color: Theme.of(context).colorScheme.primary,
                            trailing:Text(
                              '$takenCount / $totalCount taken',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailingBackground: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                          SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                          CustomListItem(
                            leading: Icon(
                              Icons.access_time,
                              size: 20.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Last seizure',
                            color: Theme.of(context).colorScheme.primary,
                            trailing: Text(
                              '${stats.lastSeizure} ${stats.lastSeizureMetric}',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 12.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),  
                          ),
                          SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                          CustomListItem(
                            leading: Icon(
                              Icons.monitor_heart,
                              size: 20.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Seizure-free streak',
                            color: Theme.of(context).colorScheme.primary,
                            trailing:Text(
                              stats.seizureFreeStreak == '--'
                                ? '--'
                                : '${stats.seizureFreeStreak} days',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailingBackground: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    IntrinsicHeight(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 10.r * Responsive.scale(context),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.r * Responsive.scale(context)),
                                  bottomLeft: Radius.circular(15.r * Responsive.scale(context)),
                                )
                              )
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.0.r * Responsive.scale(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Tip',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp * Responsive.scale(context),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    ),
                                    SizedBox(height: 5.h * Responsive.scale(context)),
                                    Text(
                                      'Stay hydrated and get plenty of rest.',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 12.sp * Responsive.scale(context),
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    )
                                  ]
                                )
                              )
                            )
                          ],
                        )
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}