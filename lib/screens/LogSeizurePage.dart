import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/DateWidget.dart';
import 'package:safeseiz/widgets/NumberFieldWidget.dart';
import 'package:safeseiz/widgets/ReturnButton.dart';
import 'package:safeseiz/widgets/SeizureTypeWidget.dart';
import 'package:safeseiz/widgets/TimeWidget.dart';

class LogSeizurePage extends StatefulWidget {
  const LogSeizurePage({super.key});

  @override
  State<LogSeizurePage> createState() => _LogSeizurePageState();
}

class _LogSeizurePageState extends State<LogSeizurePage> {
  late TextEditingController dateController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();

    final seizureCubit = context.read<SeizureCubit>();
    final medicalCubit = context.read<MedicalCubit>();

    if (seizureCubit.seizureTypes.isEmpty) {
      seizureCubit.updateSeizureTypes(List<String>.from(medicalCubit.seizureTypes));
    }

    dateController = TextEditingController(
      text: seizureCubit.seizureDateTime == null
        ? DateFormat('MMM d, yyyy').format(DateTime.now())
        : DateFormat('MMM d, yyyy').format(seizureCubit.seizureDateTime!),
    );
    timeController = TextEditingController(
      text: seizureCubit.seizureDateTime == null
        ? DateFormat('hh:mm a').format(DateTime.now())
        : DateFormat('hh:mm a').format(seizureCubit.seizureDateTime!),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final seizureCubit = context.read<SeizureCubit>();
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 60.h * Responsive.scale(context),
        title: Text(
          'Log Seizure',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp * Responsive.scale(context),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w * Responsive.scale(context)),
          child: ReturnButton(),
        ),
        leadingWidth: 60.w * Responsive.scale(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h * Responsive.scale(context)), 
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w * Responsive.scale(context), vertical: 5.h * Responsive.scale(context)),
            child: Divider(
              color: Theme.of(context).colorScheme.tertiary,
              thickness: 1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SeizureCubit, SeizureStates>(
          listener: (context, state) {
            if (state is SeizureSuccessState) {
              notify(context, 'Seizure logged successfully');
              Navigator.pop(context);
            }

            if (state is SeizureErrorState) {
              log(state.error);
              notify(context, state.error);
            }
          },
          builder: (context, state) {
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
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15.r * Responsive.scale(context)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 40.0.sp * Responsive.scale(context),
                          ),
                          SizedBox(width: 10.0.w * Responsive.scale(context)),
                          Expanded(
                            child: Text(
                              'You can only log seizures that happened within the last 48 hours.',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16.sp * Responsive.scale(context),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),   
                    SizedBox(height: 20.h * Responsive.scale(context)),                   // Date & Time
                    Text(
                      'DATE & TIME',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    Row(
                      children: [
                        Expanded(
                          child: DateWidget(
                            label: 'Date',
                            dateController: dateController,
                            initialDate: seizureCubit.seizureDateTime,
                            firstDate: DateTime.now().subtract(const Duration(hours: 48)),
                            onDateSelected: (selectedDate) {
                              final current = seizureCubit.seizureDateTime ?? DateTime.now();

                              seizureCubit.updateSeizureDateTime(
                                DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  current.hour,
                                  current.minute,
                                ),
                              );

                              dateController.text = DateFormat('MMM d, yyyy').format(selectedDate);
                            },
                          ),
                        ),  
                        SizedBox(width: 10.w * Responsive.scale(context)),
                        Expanded(
                          child: TimeWidget(
                            label: 'Time',
                            timeController: timeController,
                            initialTime: seizureCubit.seizureDateTime == null
                              ? null
                              : TimeOfDay.fromDateTime(seizureCubit.seizureDateTime!),
                            onTimeSelected: (selectedTime) {
                              final current = seizureCubit.seizureDateTime ?? DateTime.now();

                              seizureCubit.updateSeizureDateTime(
                                DateTime(
                                  current.year,
                                  current.month,
                                  current.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                ),
                              );

                              timeController.text = selectedTime.format(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    Text(
                      'SEIZURE TYPE',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    SeizureTypeWidget(
                      initialSelected: seizureCubit.seizureTypes,
                      onChanged: seizureCubit.updateSeizureTypes
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    // Duration
                    Text(
                      'DURATION',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    Row(
                      children: [
                        Expanded(
                          child: NumberFieldWidget(
                            label: 'Minutes',
                            suffixText: 'min',
                            onChanged: (value) {
                              seizureCubit.updateDurationMinutes(
                                int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 15.w * Responsive.scale(context),
                        ),
                        Expanded(
                          child: NumberFieldWidget(
                            label: 'Seconds',
                            suffixText: 'sec',
                            onChanged: (value) {
                              seizureCubit.updateDurationSeconds(
                                int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    // Notes
                    Text(
                      'NOTES (optional)',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp * Responsive.scale(context),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ), 
                    SizedBox(height: 10.h * Responsive.scale(context)),
                    TextField(
                      maxLines: 4,
                      onChanged: seizureCubit.updateNotes,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16.sp * Responsive.scale(context)
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add any additional details...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        contentPadding: EdgeInsets.all(18.w * Responsive.scale(context)),
                        errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.error,
                        ),
                        errorMaxLines: 2,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error)
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                          borderSide: BorderSide(
                            width: 2.r * Responsive.scale(context),
                            color: Theme.of(context).colorScheme.error
                          ),  
                        ),
                      ),
                    ),
                    if (seizureCubit.seizureTypesError != null || seizureCubit.seizureDurationError != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.h * Responsive.scale(context),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (seizureCubit.seizureTypesError != null)
                              Text(
                                seizureCubit.seizureTypesError!,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12.sp * Responsive.scale(context),
                                ),
                              ),

                            if (seizureCubit.seizureDurationError != null)
                              Text(
                                seizureCubit.seizureDurationError!,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12.sp * Responsive.scale(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20.h * Responsive.scale(context)),
                    CustomButton(
                      text: 'Save Seizure',
                      width: double.infinity,
                      onTap: () async {
                        final valid = seizureCubit.validateSeizure();
                        if (!valid) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            title: Text(
                              'Save Seizure',
                              style: TextStyle(
                                fontSize: 20.sp * Responsive.scale(context),
                              ),
                            ),
                            content: SizedBox(
                              width: Responsive.isTablet(context) ? 500.w : 300.w,
                              child: Text(
                                'Are you sure you want to log this seizure?\nMake sure you entered the correct infromation because it cannot be edited once saved.',
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
                                  try {
                                    Navigator.pop(context);
                                    await seizureCubit.addSeizure(isAutoDetected: false);

                                   } catch (e) {                             
                                    if (!context.mounted) return;
                                    notify(context, e.toString().replaceFirst('Exception: ', ''));
                                  }
                                },
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 12.sp * Responsive.scale(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );  
                      },
                      child: state is SeizureLoadingState 
                        ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                          )
                        )
                        : null
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildDurationField({required String title, required Function(String) onChanged}) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary
        ),
        hintText: '0',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp * Responsive.scale(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        contentPadding: EdgeInsets.all(10.r),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp * Responsive.scale(context),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}