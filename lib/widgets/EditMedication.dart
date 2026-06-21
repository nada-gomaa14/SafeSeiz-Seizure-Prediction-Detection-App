import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_states.dart';
import 'package:safeseiz/user/medical/medication/models/medication_model.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/TimeWidget.dart';

class EditMedication extends StatefulWidget {
  final MedicationModel medication;
  final ValueNotifier<bool> hasUnsavedChanges;

  const EditMedication({
    super.key,
    required this.medication,
    required this.hasUnsavedChanges,
  });

  @override
  State<EditMedication> createState() => _EditMedicationState();
}

class _EditMedicationState extends State<EditMedication> {
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late TextEditingController frequencyController;
  List<TimeOfDay> selectedTimes = [];
  List<TextEditingController> timeControllers = [];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.medication.name);
    dosageController = TextEditingController(text: widget.medication.dosage);
    frequencyController = TextEditingController(text: widget.medication.frequency.toString());

    selectedTimes = widget.medication.times.map((time) {
      final parts = time.split(':');

      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    timeControllers = selectedTimes.map((_) => TextEditingController()).toList();

    nameController.addListener(checkChanges);
    dosageController.addListener(checkChanges);
    frequencyController.addListener(checkChanges);

    checkChanges();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      for (int i = 0; i < selectedTimes.length; i++) {
        timeControllers[i].text = selectedTimes[i].format(context);
      }

      _initialized = true;
    }
  }

  void checkChanges() {
    final originalTimes = widget.medication.times;

    final currentTimes = selectedTimes.map(
      (time) => '${time.hour.toString().padLeft(2, '0')}:''${time.minute.toString().padLeft(2, '0')}',
    ).toList();

    widget.hasUnsavedChanges.value = nameController.text.trim() != widget.medication.name ||
      dosageController.text.trim() != widget.medication.dosage ||
      frequencyController.text.trim() != widget.medication.frequency.toString() ||
      currentTimes.toString() != originalTimes.toString();
  }

  @override
  Widget build(BuildContext context) {
    final medicationCubit = context.read<MedicationCubit>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9\- ]'),
              ),
            ],
            onChanged: (value) {
              final capitalized = value.split(' ').map((word) {
                if (word.isEmpty) return '';
                  return word[0].toUpperCase() + word.substring(1).toLowerCase();
              }).join(' ');

              if (capitalized != value) {
                nameController.value = TextEditingValue(
                  text: capitalized,
                  selection: TextSelection.collapsed(
                    offset: capitalized.length,
                  ),
                );
              }
            },
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Medication Name',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Dosage
          TextField(
            controller: dosageController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Dosage',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Frequency
          TextField(
            controller: frequencyController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              final frequency = int.tryParse(value) ?? 0;

              setState(() {
                if (frequency > selectedTimes.length) {
                  final count = frequency - selectedTimes.length;
                  final now = TimeOfDay.now();

                  selectedTimes.addAll(List.generate(count, (_) => now));

                  timeControllers.addAll(
                    List.generate(
                      count,
                      (_) => TextEditingController(text: now.format(context)),
                    ),
                  );
                } else {
                  for (int i = frequency; i < timeControllers.length; i++) {
                    timeControllers[i].dispose();
                  }

                  selectedTimes = selectedTimes.take(frequency).toList();
                  timeControllers = timeControllers.take(frequency).toList();
                }

                checkChanges();
              });
            },
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: InputDecoration(
              labelText: 'Times Per Day',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp * Responsive.scale(context),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                )
              ),
            ),
          ),
          // Time Pickers
          if (selectedTimes.isNotEmpty) ...[
            SizedBox(height: 10.h * Responsive.scale(context)),
            Column(
              children: List.generate(
                selectedTimes.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.h * Responsive.scale(context),
                  ),
                  child: TimeWidget(
                    timeController: timeControllers[index],
                    label: 'Time ${index + 1}',
                    initialTime: selectedTimes[index],
                    onTimeSelected: (time) {
                      setState(() {
                        selectedTimes[index] = time;
                        timeControllers[index].text = time.format(context);
                      });

                      checkChanges();
                    },
                  ),
                ),
              ),
            ),
          ],  
          // Error
          BlocSelector<MedicationCubit, MedicationStates, String?>(
            selector: (state) {
              if (state is MedicationErrorState) {
                return state.error;
              }

              return null;
            },
            builder: (context, errorMessage) {
              if (errorMessage != null) { 
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h * Responsive.scale(context)),
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0.sp * Responsive.scale(context),
                        color: Theme.of(context).colorScheme.error
                      )
                    ),
                  ),
                );
              }
      
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: 20.h * Responsive.scale(context)),
          // Update
          ValueListenableBuilder<bool>(
            valueListenable: widget.hasUnsavedChanges,
            builder: (context, hasChanges, _) {
              return CustomButton(
                text: 'Update',
                onTap: !hasChanges
                  ? null
                  : () async {
                    final frequency = int.tryParse(frequencyController.text) ?? 0;
                    final updatedTakenStatus = <String, Map<int, bool>>{};

                    widget.medication.takenStatus.forEach((date, status) {
                      final filteredStatus = <int, bool>{};

                      for (int i = 0; i < frequency; i++) {
                        filteredStatus[i] = status[i] ?? false;
                      }

                      updatedTakenStatus[date] = filteredStatus;
                    });

                    final updatedMedication = MedicationModel(
                      id: widget.medication.id,
                      name: nameController.text.trim(),
                      dosage: dosageController.text.trim(),
                      frequency: frequency,
                      times: selectedTimes.map(
                        (time) =>'${time.hour.toString().padLeft(2, '0')}:''${time.minute.toString().padLeft(2, '0')}',
                      ).toList(),
                      takenStatus: updatedTakenStatus,
                    );

                    final success = await medicationCubit.updateMedication(widget.medication.id, updatedMedication);

                    if (!success) return;

                    if (context.mounted) {
                      widget.hasUnsavedChanges.value = false;
                      Navigator.pop(context);
                    }
                  },
              );
            },
          ),
          SizedBox(height: 10.h * Responsive.scale(context)),
          // Delete
          CustomButton(
            text: 'Delete Medication',
            color: Theme.of(context).colorScheme.error,
            onTap: () async {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (_) => AlertDialog(
                  title: Text(
                    'Delete Medication',
                    style: TextStyle(
                      fontSize: 20.sp * Responsive.scale(context),
                    )
                  ),
                  content: SizedBox(
                    width: Responsive.isTablet(context) ? 500.w : 300.w,
                    child: Text(
                      'Are you sure you want to delete this medication?',
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
                          final success = await medicationCubit.deleteMedication(widget.medication.id);
      
                          if (!success) return;
      
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Delete',
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
          SizedBox(height: 10.h * Responsive.scale(context))
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.removeListener(checkChanges);
    dosageController.removeListener(checkChanges);
    frequencyController.removeListener(checkChanges);

    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    for (final controller in timeControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}