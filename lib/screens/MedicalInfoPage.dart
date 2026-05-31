import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/navigation/navigation_layout.dart';
import 'package:safeseiz/screens/PersonalInfoPage.dart';
import 'package:safeseiz/user/medical/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/cubit/medical_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/DateWidget.dart';
import 'package:safeseiz/widgets/SeizureFrequencyWidget.dart';
import 'package:safeseiz/widgets/SeizureTypeWidget.dart';
import 'package:safeseiz/widgets/StepIndicator.dart';

class MedicalInfoPage extends StatefulWidget {
  const MedicalInfoPage({super.key});

  @override
  State<MedicalInfoPage> createState() => _MedicalInfoPageState();
}

class _MedicalInfoPageState extends State<MedicalInfoPage> {
  final TextEditingController diagnosisDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: BlocConsumer<MedicalCubit, MedicalStates>(
              listener: (context, state) {
                if (state is MedicalSuccessState) {
                  FocusScope.of(context).unfocus();
                  log('Medical info success');
                  notify(context, 'Medical information saved successfully');

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder : (context) => const NavigationLayout()
                    ),
                    (route) => false
                  );
                }
                
                if (state is MedicalErrorState) {
                  log(state.error);
                  notify(context, state.error);
                }
              },
              builder: (context, state) {
                final medicalCubit = context.read<MedicalCubit>();
                final isLoading = state is MedicalLoadingState;

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
                          child: StepIndicator(activeStep: 3)
                        ),
                        SizedBox(height: 50.h),
                        // Title
                        Text(
                          'Medical Information',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        ),
                        SizedBox(height: 5.h),
                        // Subtitle
                        Text(
                          'Step 3 of 3 - Almost done',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 18.sp,
                            color: Colors.grey
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: DateWidget(
                                label: 'Diagnosis',
                                dateController: diagnosisDateController,
                                enabled: !medicalCubit.notDiagnosed,
                                onDateSelected: (date) {
                                  diagnosisDateController.text = '${date.day}/${date.month}/${date.year}';
                                  medicalCubit.updateDiagnosisDate(date);
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 1.r
                                  ),
                                  value: medicalCubit.notDiagnosed, 
                                  onChanged: (value) {
                                    if (value == null) return;
                                
                                    medicalCubit.updateNotDiagnosed(value);
                                
                                    if (value) {
                                      diagnosisDateController.clear();
                                    }
                                  }
                                ),
                                Flexible(
                                  child: Text(
                                    'Not diagnosed',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 16.sp,
                                      color: Colors.grey
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        SeizureTypeWidget(
                          onChanged: (types) => medicalCubit.updateSeizureTypes(types),
                        ),
                        SizedBox(height: 20.h),
                        SeizureFrequencyWidget(
                          onChanged: (frequency) => medicalCubit.updateSeizureFrequency(frequency),
                        ),
                        SizedBox(height: 30.h),
                        CustomButton(
                          text: "Complete Setup",
                          width: double.infinity,
                          onTap: isLoading ? null : () async {
                            await medicalCubit.saveMedicalInfo();
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
                        Center(
                          child: Text(
                            'You can update this anytime from your profile',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 12.sp,
                              color: Colors.grey
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        /// SKIP (optional)
                        CustomButton(
                          text: "BACK",
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
              }
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    diagnosisDateController.dispose();
    super.dispose();
  }
}