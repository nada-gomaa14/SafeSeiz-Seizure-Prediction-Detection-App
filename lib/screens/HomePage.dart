import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/screens/LogSeizurePage.dart';
import 'package:safeseiz/screens/ProfilePage.dart';
import 'package:safeseiz/screens/SOSPage.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:safeseiz/user/sos/cubit/sos_cubit.dart';
import 'package:safeseiz/widgets/CalendarWidget.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';

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

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0.w,
                vertical: 10.0.h
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
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.tertiary
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage()
                              ),
                            );
                          },
                          child: Container(
                            height: 50.r,
                            width: 50.r,
                            padding: EdgeInsets.all(10.r),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              name.split(' ')[0].substring(0, 1).toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 20.sp,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            )          
                          )  
                        )
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Hello, $name',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                      thickness: 1,
                    ),
                    SizedBox(height: 5.h),
                    CalendarWidget(), 
                    SizedBox(height: 20.h),
                    Text(
                      'QUICK ACTIONS',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomButton(
                            height: 75.h,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LogSeizurePage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Log\nSeizure',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.secondary
                                    )
                                  )
                                ],
                              ),
                            )
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CustomButton(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                            border: Theme.of(context).colorScheme.primary,
                            height: 75.h,
                            onTap: () {
                              notify(context, 'Symptoms logged!');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Log\nSymptoms',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary
                                    )
                                  )
                                ],
                              )
                            )  
                          ),
                        ),    
                      ],
                    ),
                    SizedBox(height: 10.h),
                    CustomButton(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                      border: Theme.of(context).colorScheme.error,
                      height: 90.h,
                      width: double.infinity,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              lazy: false,
                              create: (_) => SOSCubit()..fetchLocation(),
                              child: const SOSPage(),
                            ),
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
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error
                                  )
                                ),
                                Text(
                                  'Alert your emergency contacts',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).colorScheme.error
                                  )  
                                )
                              ],
                            ),
                            const Spacer(),
                            Container(
                              height: 60.r,
                              width: 60.r,
                              padding: EdgeInsets.all(10.r),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Text(
                                'SOS',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                )
                              )  
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "TODAY'S STATUS",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      child: Column(
                        children: [
                          CustomListItem(
                            leading: Icon(
                              Icons.medication,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Medications',
                            color: Theme.of(context).colorScheme.primary,
                            trailing:Text(
                              '3 / 5 taken',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailingBackground: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                          SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                          CustomListItem(
                            leading: Icon(
                              Icons.access_time,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Last seizure',
                            color: Theme.of(context).colorScheme.primary,
                            trailing: Text(
                              '3 days ago',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),  
                          ),
                          SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                          CustomListItem(
                            leading: Icon(
                              Icons.monitor_heart,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'Seizure-free streak',
                            color: Theme.of(context).colorScheme.primary,
                            trailing:Text(
                              '3 days',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailingBackground: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 80.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 10.r,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.r),
                                bottomLeft: Radius.circular(15.r),
                              )
                            )
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10.0.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Tip',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    'Stay hydrated and get plenty of rest.',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 12.sp,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        ],
                      )
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