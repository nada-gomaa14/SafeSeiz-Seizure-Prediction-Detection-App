import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/medical/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/DateWidget.dart';

class EditMedicalInfo extends StatefulWidget {
  final ValueNotifier<bool> hasUnsavedChanges;

  const EditMedicalInfo({super.key, required this.hasUnsavedChanges});

  @override
  State<EditMedicalInfo> createState() => _EditMedicalInfoState();
}

class _EditMedicalInfoState extends State<EditMedicalInfo> {
  late TextEditingController diagnosisDateController;
  DateTime? diagnosisDate;
  String? selectedFrequency;
  List<String> selectedSeizureTypes = [];

  @override
  void initState() {
    super.initState();
    final medicalCubit = context.read<MedicalCubit>();
    diagnosisDate = medicalCubit.diagnosisDate;
    selectedSeizureTypes = List.from(medicalCubit.seizureTypes);
    selectedFrequency = medicalCubit.seizureFrequency;
    diagnosisDateController = TextEditingController(
      text: diagnosisDate != null
        ? DateFormat('dd/MM/yyyy').format(diagnosisDate!)
        : '',
    );
  }

  void checkChanges() {
    final medicalCubit = context.read<MedicalCubit>();

   final seizureTypesChanged = !listEquals(selectedSeizureTypes, medicalCubit.seizureTypes);

    widget.hasUnsavedChanges.value = seizureTypesChanged ||
      selectedFrequency != medicalCubit.seizureFrequency ||
      diagnosisDate != medicalCubit.diagnosisDate;
  }

  @override
  Widget build(BuildContext context) {
    final medicalCubit = context.read<MedicalCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Diagnosis Date
          DateWidget(
            label: 'Diagnosis Date',
            initialDate: diagnosisDate,
            dateController: diagnosisDateController,
            onDateSelected: (date) {
              setState(() {
                diagnosisDate = date;
                diagnosisDateController.text = DateFormat('dd/MM/yyyy').format(date);
              });

              checkChanges();
            },
          ),
          SizedBox(height: 10.h),
          // Seizure Types
          GestureDetector(
            onTap: showSeizureTypePicker,
            child: InputDecorator(
              isEmpty: selectedSeizureTypes.isEmpty,
              decoration: InputDecoration(
                labelText: 'Seizure Types',
                labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              child: Text(
                selectedSeizureTypes.join(', '),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16.sp,
                  color: Theme.of(context) .colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Frequency
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            icon: Padding(
              padding: EdgeInsets.only(right: 10.0.r),
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.tertiary
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Seizure Frequency',
              labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
            items: MedicalModel.seizureFrequencyOptions.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFrequency = value;
              });

              checkChanges();
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
                    medicalCubit.updateDiagnosisDate(diagnosisDate);
                    medicalCubit.updateSeizureTypes(selectedSeizureTypes);
                    medicalCubit.updateSeizureFrequency(selectedFrequency);
                      
                    await medicalCubit.saveMedicalInfo();
                      
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

  Future<void> showSeizureTypePicker() async {
    final tempSelected = List<String>.from(selectedSeizureTypes);

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0.r)),
      ),

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(20.r),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Seizure Types
                    ...MedicalModel.seizureTypeOptions.map((type) {
                      final isSelected = tempSelected.contains(type);
                
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(
                          type,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.0.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          setModalState(() {
                            value == true
                              ? tempSelected.add(type)
                              : tempSelected.remove(type);
                          });
                        },
                      );
                    }),
                    SizedBox(height: 10.0.h),
                    // Done
                    CustomButton(
                      text: 'Done',
                      onTap: () {
                        setState(() {
                          selectedSeizureTypes = tempSelected;
                        });

                        checkChanges();
                
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10.0.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    diagnosisDateController.dispose();
    super.dispose();
  }
}