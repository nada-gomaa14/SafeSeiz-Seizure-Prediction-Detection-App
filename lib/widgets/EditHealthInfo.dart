import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/user/medical/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/cubit/medical_states.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';

class EditHealthInfo extends StatefulWidget {
  final ValueNotifier<bool> hasUnsavedChanges;
  
  const EditHealthInfo({super.key, required this.hasUnsavedChanges});

  @override
  State<EditHealthInfo> createState() => _EditHealthMetricsFormState();
}

class _EditHealthMetricsFormState extends State<EditHealthInfo> {
  late TextEditingController heightController;
  late TextEditingController weightController;
  String? selectedBloodType;

  @override
  void initState() {
    super.initState();
    final medicalCubit = context.read<MedicalCubit>();
    heightController = TextEditingController(text: medicalCubit.height?.toString() ?? '');
    weightController = TextEditingController(text: medicalCubit.weight?.toString() ?? '');
    selectedBloodType = medicalCubit.bloodType;

    heightController.addListener(checkChanges);
    weightController.addListener(checkChanges);
  }

  void checkChanges() {
    final medicalCubit = context.read<MedicalCubit>();

    widget.hasUnsavedChanges.value = weightController.text.trim() != (medicalCubit.weight?.toString() ?? '') ||
      heightController.text.trim() != (medicalCubit.height?.toString() ?? '') ||
      selectedBloodType != medicalCubit.bloodType;
  }

  @override
  Widget build(BuildContext context) {
    final medicalCubit = context.read<MedicalCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            // Weight
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Weight',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              suffixText: 'kg',
              suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
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
          // Height
          TextField(
            controller: heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Height',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              suffixText: 'cm',
              suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
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
          // Blood Type
          DropdownButtonFormField<String>(
            value: selectedBloodType,
            icon: Padding(
              padding: EdgeInsets.only(right: 10.0.r),
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.tertiary
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Blood Type',
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
            items: MedicalModel.bloodTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBloodType = value;
              });

              checkChanges();
            },
          ),
          // Error Message
          BlocSelector<MedicalCubit, MedicalStates, String?>(
            selector: (state) {
              if (state is MedicalErrorState) {
                return state.error;
              }
      
              return null;
            },
            builder: (context, errorMessage) {
              if (errorMessage != null) { 
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0.sp,
                        color: Theme.of(context).colorScheme.error
                      )
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
                onTap: !hasChanges
                  ? null
                  : () async {
                    final weight = double.tryParse(weightController.text);
                    final height = double.tryParse(heightController.text);

                    if (!medicalCubit.isValidWeight(weight)) return;
                    if (!medicalCubit.isValidHeight(height)) return;
                    
                    medicalCubit.updateWeight(weight);
                    medicalCubit.updateHeight(height);
                    medicalCubit.updateBloodType(selectedBloodType);
                      
                    final saved = await medicalCubit.saveMedicalInfo();

                    if (!saved) return;
                      
                    if (context.mounted) {
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
    heightController.removeListener(checkChanges);
    weightController.removeListener(checkChanges);
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}