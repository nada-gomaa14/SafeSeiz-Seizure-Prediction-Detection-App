import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/ReturnButton.dart';
import 'package:safeseiz/widgets/SeizureTypeWidget.dart';

class LogSeizurePage extends StatelessWidget {
  const LogSeizurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final seizureCubit = context.read<SeizureCubit>();
    
    final List<String> triggers = [
      'Sleep deprivation',
      'Stress',
      'Missed med',
      'Unknown',
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Log Seizure',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: ReturnButton(),
        ),
        leadingWidth: 60.w,
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
            if (state is SeizureLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              );
            }

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
                    // Date & Time
                    Text(
                      'DATE & TIME',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: buildDateCard(
                            context: context,
                            title: 'Date',
                            value: seizureCubit.seizureDateTime == null
                              ? DateFormat('MMM d, yyyy').format(DateTime.now())
                              : DateFormat('MMM d, yyyy').format(seizureCubit.seizureDateTime!),
                            onTap: () async {

                              final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDate: seizureCubit.seizureDateTime ?? DateTime.now(),
                              );

                              if (pickedDate != null) {
                                final current = seizureCubit.seizureDateTime ?? DateTime.now();
                                seizureCubit.updateSeizureDateTime(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, current.hour, current.minute));
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: buildDateCard(
                            context: context,
                            title: 'Time',
                            value: seizureCubit.seizureDateTime == null
                              ? DateFormat('hh:mm a').format(DateTime.now())
                              : DateFormat( 'hh:mm a').format(seizureCubit.seizureDateTime!),
                            onTap: () async {
                              final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                              if (pickedTime != null) {
                                final current = seizureCubit.seizureDateTime ?? DateTime.now();
                                seizureCubit.updateSeizureDateTime(DateTime(current.year, current.month, current.day, pickedTime.hour, pickedTime.minute));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'SEIZURE TYPE',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    ), 
                    SizedBox(height: 10.h),
                    SeizureTypeWidget(onChanged: seizureCubit.updateSeizureTypes),
                    if (seizureCubit.seizureTypesError != null) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          seizureCubit.seizureTypesError!,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    // Duration
                    Text(
                      'DURATION',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: buildDurationField(
                            title: 'Minutes',
                            onChanged: (value) {
                              seizureCubit.updateDurationMinutes(
                                int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: buildDurationField(
                            title: 'Seconds',
                            onChanged: (value) {
                              seizureCubit.updateDurationSeconds(
                                int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Notes
                    Text(
                      'NOTES (optional)',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ), 
                    SizedBox(height: 10.h),
                    TextField(
                      maxLines: 4,
                      onChanged: seizureCubit.updateNotes,
                      decoration: InputDecoration(
                        hintText: 'Add any additional details...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(18.w),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22.r),
                          borderSide: const BorderSide(
                            color: Color(0xff2D2DB5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      text: 'Save Seizure',
                      width: double.infinity,
                      onTap: () async {
                        final valid = seizureCubit.validateSeizureTypes();

                        if (!valid) return;

                        await seizureCubit.addSeizure(isAutoDetected: false);
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

  Widget buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 22.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff2D2DB5)
              : const Color(0xffF5F5FD),
          borderRadius:
              BorderRadius.circular(30.r),
          border: Border.all(
            color: const Color(0xffE3E3F7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? Colors.white : const Color(0xff2D2DB5),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildDateCard({
    required BuildContext context,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(22.r),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              value,
              style: TextStyle(
                color: const Color(0xff2D2DB5),
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildDurationField({
    required String title,
    required Function(String) onChanged,
  }) {

    return TextField(
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '0',
        labelText: title,
        contentPadding: EdgeInsets.all(18.w),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(22.r),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(22.r),
          borderSide: const BorderSide(
            color: Color(0xff2D2DB5),
          ),
        ),
      ),
      style: TextStyle(
        color: const Color(0xff2D2DB5),
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}