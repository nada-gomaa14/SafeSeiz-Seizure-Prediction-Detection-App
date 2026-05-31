import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/showPopup.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/screens/SettingsPage.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/medical/cubit/medical_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:safeseiz/widgets/AddEmergencyContact.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';
import 'package:safeseiz/widgets/EditEmergencyContact.dart';
import 'package:safeseiz/widgets/EditHealthInfo.dart';
import 'package:safeseiz/widgets/EditMedicalInfo.dart';
import 'package:safeseiz/widgets/EditProfile.dart';
import 'package:safeseiz/widgets/ReturnButton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isLocked = context.select<EmergencyContactsCubit, bool>(
      (cubit) => !cubit.hasMinimumContacts,
    );

    return PopScope(
      canPop: !isLocked,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          centerTitle: true,
          leading: isLocked
            ? null
            : Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: ReturnButton(),
            ),
          leadingWidth: 60.w,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0.r),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage()
                    )
                  );
                },
                child: Container(
                  height: 40.0.r,
                  width: 40.0.r,
                  padding: EdgeInsets.all(10.r),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.settings,
                    size: 20.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),          
                ),  
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.h), 
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              child: Divider(
                color: Theme.of(context).colorScheme.tertiary,
                thickness: 1,
              ),
            ),
          ),
        ),
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
      
              final profile = context.read<ProfileCubit>().profile;
              
              if (profile == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final name = '${profile.firstName} ${profile.lastName}'.trim();
              final initial = name.isNotEmpty
                ? name[0].toUpperCase()
                : '?';
              final email = profile.email;
              final dob = '${profile.dob!.day}/${profile.dob!.month}/${profile.dob!.year}';
              final gender = profile.gender.toString();
      
              final medicalCubit = context.watch<MedicalCubit>();
              final seizureTypes = medicalCubit.seizureTypes;
              final notDiagnosed = medicalCubit.notDiagnosed;
              final diagnosisDate = medicalCubit.diagnosisDate;
              final seizureFrequency = medicalCubit.seizureFrequency ?? 'Not specified';
              final weight = medicalCubit.weight;
              final height = medicalCubit.height;
              final bloodType = medicalCubit.bloodType;
      
              final emergencyCubit = context.watch<EmergencyContactsCubit>();
              final contacts = emergencyCubit.contacts;
      
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
                      if (isLocked)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20.0.h),
                          padding: EdgeInsets.all(15.r),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15.0.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 40.0.sp,
                              ),
                              SizedBox(width: 10.0.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'For your own safety, you must add at least 2 emergency contacts to use the app.',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    SizedBox(height: 5.0.h),
                                    Text(
                                      '${contacts.length} / 2 contacts added',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),  
                            ],
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        height: 120.0.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15.0.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 60.r,
                                width: 60.r,
                                padding: EdgeInsets.all(10.r),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                                ),
                                child: Text(
                                  initial,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 25.sp,
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )          
                              ),
                              const Spacer(),
                              Padding(
                                padding: EdgeInsets.all(10.0.r),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75),
                                      ),
                                    ),
                                    Text(
                                      'born $dob',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75),
                                      ),
                                    ),
                                    Text(
                                      gender,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75),
                                      ),
                                    )
                                  ],
                                )
                              ),
                              const Spacer(),
                              InkWell(
                                borderRadius: BorderRadius.circular(20.r),
                                onTap: isLocked
                                  ? null
                                  : () {
                                    final hasUnsavedChanges = ValueNotifier(false);

                                    showPopup(
                                      context: context, 
                                      title: 'Edit Profile', 
                                      hasUnsavedChanges: hasUnsavedChanges,
                                      child: EditProfile(hasUnsavedChanges: hasUnsavedChanges),
                                    );
                                  },  
                                child: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75),
                                  size: 25.sp,
                                ),
                                 //ADD EDIT POPUP
                              )    
                            ]
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0.h), 
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'HEALTH INFORMATION',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: isLocked
                                ? null
                                : () {
                                  final hasUnsavedChanges = ValueNotifier(false);

                                  showPopup(
                                    context: context, 
                                    title: 'Edit Health Information', 
                                    hasUnsavedChanges: hasUnsavedChanges,
                                    child: EditHealthInfo(hasUnsavedChanges: hasUnsavedChanges),
                                  );
                                },  
                              child: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0.h),
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 70.0.h,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Weight',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),  
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          weight != null
                                            ? weight.toInt().toString()
                                            : '--',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),  
                                        ),
                                        SizedBox(width: 5.0.w),
                                        Text(
                                          'kg',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            fontSize: 14.sp,
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                                          ),  
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0.w),
                            Expanded(
                              child: Container(
                                height: 70.0.h,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Height',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),  
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          height != null
                                            ? height.toInt().toString()
                                            : '--',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),  
                                        ),
                                        SizedBox(width: 5.0.w),
                                        Text(
                                          'cm',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            fontSize: 14.sp,
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                                          ),  
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0.w),
                            Expanded(
                              child: Container(
                                height: 70.0.h,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Blood',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),  
                                    ),
                                    Text(
                                      bloodType ?? '--',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),  
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                      SizedBox(height: 20.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'EMERGENCY CONTACTS',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            )
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20.r),
                            onTap: () {
                              final hasUnsavedChanges = ValueNotifier(false);

                              showPopup(
                                context: context, 
                                title: 'Add Emergency Contact',
                                hasUnsavedChanges: hasUnsavedChanges,
                                child: AddEmergencyContact(hasUnsavedChanges: hasUnsavedChanges),
                              );
                            }, 
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0.h),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                        ),
                        child: contacts.isEmpty
                          ? Padding(
                            padding: EdgeInsets.all(16.0.r),
                            child: Center(
                              child: Text(
                                'No emergency contacts added yet!',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            )
                          )  
                          : Column(
                            children: List.generate(contacts.length, (index) {
                              final contact = contacts[index];
                              final initial = contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : '?';
                            
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final hasUnsavedChanges = ValueNotifier(false);

                                      showPopup(
                                        context: context,
                                        title: 'Edit Emergency Contact',
                                        hasUnsavedChanges: hasUnsavedChanges,
                                        child: EditEmergencyContact(contact: contact, hasUnsavedChanges: hasUnsavedChanges),
                                      );
                                    },
                                    child: CustomListItem(
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
                                      trailing: Icon(
                                        Icons.keyboard_arrow_right,
                                        size: 20.sp,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      )
                                    ),
                                  ),
                                  if (index < contacts.length - 1)
                                    SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                                ],
                              );
                            })
                          ),
                      ),  
                      SizedBox(height: 20.0.h),
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'MEDICAL INFORMATION',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              )
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: isLocked
                                ? null
                                : () {
                                  final hasUnsavedChanges = ValueNotifier(false);

                                  showPopup(
                                    context: context, 
                                    title: 'Edit Medical Information', 
                                    hasUnsavedChanges: hasUnsavedChanges,
                                    child: EditMedicalInfo(hasUnsavedChanges: hasUnsavedChanges),
                                  );
                                },  //ADD HEALTH METRICS POPUP
                              child: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0.h), 
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                          ),
                          child: Column(
                            children: [
                              CustomListItem(
                                title: 'Diagnosed',
                                color: Theme.of(context).colorScheme.tertiary,
                                trailing: Text(
                                  diagnosisDate != null
                                    ? '${diagnosisDate.day}/${diagnosisDate.month}/${diagnosisDate.year}'
                                    : notDiagnosed
                                      ? 'Not diagnosed'
                                      : 'Not specified',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),    
                                ),
                              ),
                              SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                              CustomListItem(
                                title: 'Seizure type',
                                color: Theme.of(context).colorScheme.tertiary,
                                trailingWidgets: seizureTypes.isNotEmpty
                                  ? seizureTypes.map((type) {
                                    return Text(
                                      type,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList()
                                  : [
                                    Text(
                                      'Not specified',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  trailingBackground: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                              ),
                              SizedBox(height: 0.h, child: Divider(color: Theme.of(context).colorScheme.tertiary)),
                              CustomListItem(
                                title: 'Frequency',
                                color: Theme.of(context).colorScheme.tertiary,
                                trailing: Text(
                                  seizureFrequency,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0.h),
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: CustomButton(
                          text: 'Export Report',
                          onTap: isLocked
                            ? null
                            : () {}, 
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}