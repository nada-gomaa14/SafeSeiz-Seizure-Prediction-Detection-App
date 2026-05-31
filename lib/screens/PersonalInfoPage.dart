import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/screens/MedicalInfoPage.dart';
import 'package:safeseiz/screens/RegistrationPage.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/DateWidget.dart';
import 'package:safeseiz/widgets/GenderWidget.dart';
import 'package:safeseiz/widgets/NameWidget.dart';
import 'package:safeseiz/widgets/StepIndicator.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: BlocConsumer<ProfileCubit, ProfileStates>(
              listener:(context, state) {
                if (state is ProfileSuccessState) {
                  FocusScope.of(context).unfocus();
                  log('Profile success');
                  notify(context, 'Profile saved successfully');
      
                  if (!context.mounted) return;
      
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder : (context) => const MedicalInfoPage()
                    )
                  );
                }

                if (state is ProfileLoadedState && !isInitialized) {
                  firstNameController.text = state.profile.firstName ?? '';
                  lastNameController.text = state.profile.lastName ?? '';
                  dobController.text = state.profile.dob != null
                    ? DateFormat('dd/MM/yyyy').format(state.profile.dob!)
                    : '';

                  isInitialized = true;            
                }
      
                if (state is ProfileErrorState) {
                  log(state.error);
                  notify(context, state.error);
                }
              },
              builder: (context, state) {
                final profileCubit = context.read<ProfileCubit>();
                final isLoading = state is ProfileLoadingState;
      
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0.w,
                    vertical: 10.0.h
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Indicator
                        Center(
                          child: StepIndicator(activeStep: 2)
                        ),
                        SizedBox(height: 50.h),
                        // Title
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        ),
                        SizedBox(height: 5.h),
                        // Subtitle
                        Text(
                          'Step 2 of 3 - Tell us about yourself',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 18.sp,
                            color: Colors.grey
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: NameWidget(
                                      label: 'First Name',
                                      hint: 'First',
                                      nameController: firstNameController,
                                      onChanged: (value) {
                                        profileCubit.updateFirstName(value);
                                      },
                                    )
                                  ),
                                  SizedBox(width: 15.w),
                                  Expanded(
                                    child: NameWidget(
                                      label: 'Last Name',
                                      hint: 'Last',
                                      nameController: lastNameController,
                                      onChanged: (value) {
                                        profileCubit.updateLastName(value);
                                      },
                                    )
                                  ),
                                ]
                              ),
                              SizedBox(height: 20.h),
                              DateWidget(
                                label: 'Date of Birth', 
                                dateController: dobController,
                                onDateSelected: (date) {
                                  profileCubit.updateDob(date);
                                  dobController.text = DateFormat('dd/MM/yyyy').format(date);
                                },
                              ),
                              SizedBox(height: 20.h),
                              GenderWidget(
                                initialValue: profileCubit.gender,
                                errorText: profileCubit.genderError,
                                onChanged: (value){
                                  profileCubit.updateGender(value);
                                }
                              ),
                            ]
                          )
                        ),
                        SizedBox(height: 30.h),
                        CustomButton(
                          text: "Continue",
                          width: double.infinity,
                          onTap: isLoading ? null : () {
                            final isFormValid = formKey.currentState!.validate();
                            final isGenderValid = profileCubit.validateGender();
      
                            if (isFormValid && isGenderValid) {
                              profileCubit.saveProfile();
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
      
                        SizedBox(height: 10.h),
                    
                          /// SKIP (optional)
                        CustomButton(
                          text: "BACK",
                          width: double.infinity,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegistrationPage(),
                              ),
                            );
                          },
                        ),    
      
                        SizedBox(height: 10.h),
                    
                          /// SKIP (optional)
                        CustomButton(
                          text: "SKIP",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MedicalInfoPage(),
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
          )
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final cubit = context.read<ProfileCubit>();
    final user = cubit.supabase.auth.currentUser;

    if (user != null) {
      cubit.fetchProfile(user.id);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}