import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/DateWidget.dart';

class EditProfile extends StatefulWidget {
  final ValueNotifier<bool> hasUnsavedChanges;
  
  const EditProfile({super.key, required this.hasUnsavedChanges});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController dobController;
  DateTime? selectedDob;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<ProfileCubit>();
    firstNameController = TextEditingController(text: profileCubit.firstName ?? '');
    lastNameController = TextEditingController(text: profileCubit.lastName ?? '');
    dobController = TextEditingController(
      text: profileCubit.dob != null
        ? DateFormat('dd/MM/yyyy').format(profileCubit.dob!)
        : '',
    );
    selectedDob = profileCubit.dob;
    selectedGender = profileCubit.gender;

    firstNameController.addListener(checkChanges);
    lastNameController.addListener(checkChanges);
  }

  void checkChanges() {
    final profileCubit = context.read<ProfileCubit>();

    widget.hasUnsavedChanges.value = firstNameController.text.trim() != (profileCubit.firstName ?? '') ||
      lastNameController.text.trim() != (profileCubit.lastName ?? '') ||
      selectedDob != profileCubit.dob ||
      selectedGender != profileCubit.gender;
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Name
          TextField(
            controller: firstNameController,
            keyboardType: TextInputType.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'First Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Last Name
          TextField(
            controller: lastNameController,
            keyboardType: TextInputType.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Last Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // DOB
          DateWidget(
            label: 'Date of Birth',
            initialDate: selectedDob,
            dateController: dobController,
            onDateSelected: (date) {
              setState(() {
                selectedDob = date;
                dobController.text = DateFormat('dd/MM/yyyy').format(date);
              });

              checkChanges();
            },
          ),
          SizedBox(height: 10.h),
          // Gender Dropdown
          BlocBuilder<ProfileCubit, ProfileStates>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    icon: Padding(
                      padding: EdgeInsets.only(right: 10.0.r),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    items: ['male', 'female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });

                      checkChanges();
                    },
                  ),

                  if (profileCubit.genderError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 5.w),
                      child: Text(
                        profileCubit.genderError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Error Message
          BlocBuilder<ProfileCubit, ProfileStates>(
            builder: (context, state) {
              if (state is ProfileErrorState) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      state.error,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: 20.h),
          // Save
          ValueListenableBuilder<bool>(
            valueListenable: widget.hasUnsavedChanges,
            builder: (context, hasChanges, _) {
              return CustomButton(
                text: 'Save',
                onTap:!hasChanges
                  ? null
                  : () async {
                    final firstName = firstNameController.text.trim();
                    final lastName = lastNameController.text.trim();
                
                    if(!profileCubit.validateName(firstName, 'First name')) {
                      return;
                    }
                
                    if(!profileCubit.validateName(lastName, 'Last name')) {
                      return;
                    }
                
                    profileCubit.updateFirstName(firstName);
                    profileCubit.updateLastName(lastName);
                    
                    if (selectedDob != null) {
                      profileCubit.updateDob(selectedDob!);
                    }
                
                    if (selectedGender != null) {
                      profileCubit.updateGender(selectedGender!);
                    }
                
                    if (!profileCubit.validateGender()) {
                      return;
                    }
                
                    await profileCubit.saveProfile();
                
                    if (context.mounted && profileCubit.state is ProfileSuccessState) {
                      widget.hasUnsavedChanges.value = false;
                      Navigator.pop(context);
                    }
                  },
              );
            }
          ),          
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.removeListener(checkChanges);
    lastNameController.removeListener(checkChanges);
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}