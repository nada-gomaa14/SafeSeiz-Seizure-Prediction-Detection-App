import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/services/settings_preferences.dart';
import 'package:safeseiz/functions/showPopup.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_states.dart';
import 'package:safeseiz/user/medical/medication/models/medication_model.dart';
import 'package:safeseiz/widgets/AddMedication.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/CustomListItem.dart';
import 'package:safeseiz/widgets/EditMedication.dart';
import 'package:safeseiz/services/notification_service.dart';

class MedicationDose {
  final MedicationModel medication;
  final int doseIndex;
  final TimeOfDay time;

  MedicationDose({required this.medication, required this.doseIndex, required this.time});
}

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  // Declared at class level so they persist across rebuilds
  Timer? _alertTimer;
  final Set<String> _firedAlerts = {};

  // Starts the timer when the page is created
  @override
  void initState() {
    super.initState();
    _alertTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkMedicationAlerts();
    });
  }

  // Cancels the timer when the page is destroyed
  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  // Checks if any dose is due right now
  Future<void> _checkMedicationAlerts() async {
    debugPrint('Timer fired');  // ← ADD

    final enabled = await SettingsPreferences.getMedReminders();

    if (!enabled || !mounted) return;

    final cubit = context.read<MedicationCubit>();
    final medications = cubit.medications;

    final now = TimeOfDay.now();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (final med in medications) {
      for (int i = 0; i < med.times.length; i++) {
        final doseTime = parseTime(med.times[i]);
        final taken = med.takenStatus[today]?[i] ?? false;
        final key = '${med.id}_${i}_${today}_${now.hour}:${now.minute}';

        if (doseTime.hour == now.hour &&
            doseTime.minute == now.minute &&
            !taken &&
            !_firedAlerts.contains(key)) {
          _firedAlerts.add(key);
          _showMedicationAlert(med, i);
        }
      }
    }
  }

  void _showMedicationAlert(MedicationModel med, int doseIndex) {
    NotificationService().showMedicationNotification(  // ← ADD
      name: med.name,
      dosage: med.dosage,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.medication, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 5.w * Responsive.scale(context)),
            Text(
              'Medication Reminder',
              style: TextStyle(
                fontSize: 20.sp * Responsive.scale(context),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: Responsive.isTablet(context) ? 500.w : 300.w,
          child: Text(
            'Time to take ${med.name} — ${med.dosage}',
            style: TextStyle(
              fontSize: 12.sp * Responsive.scale(context),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MedicationCubit>().toggleTaken(med.id, doseIndex);
            },
            child: Text(
              'Mark As Taken',
              style: TextStyle(
                fontSize: 12.sp * Responsive.scale(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Dismiss',
              style: TextStyle(
                fontSize: 12.sp * Responsive.scale(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 60.h * Responsive.scale(context),
        title: Text(
          'Medication',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp * Responsive.scale(context),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
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
        child: BlocConsumer<MedicationCubit, MedicationStates>(
            listener: (context, state) {
              if (state is MedicationErrorState) {
                log(state.error);
                notify(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is MedicationLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                );
              }

              if (state is MedicationInitialState) {
                return _buildEmptyState(context);
              }

              final medicationCubit = context.read<MedicationCubit>();
              final medications = medicationCubit.medications;

              if (medications.isEmpty) {
                return _buildEmptyState(context);
              }

              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

              int takenCount = 0;
              int totalCount = 0;

              for (final medication in medications) {
                totalCount += medication.times.length;
                final todayStatus = medication.takenStatus[today] ?? {};
                takenCount += todayStatus.values.where((taken) => taken).length;
              }

              final progress = totalCount == 0
                  ? 0.0
                  : takenCount / totalCount;

              final morning = <MedicationDose>[];
              final afternoon = <MedicationDose>[];
              final evening = <MedicationDose>[];

              for (final medication in medications) {
                for (int i = 0; i < medication.times.length; i++) {
                  final time = parseTime(medication.times[i]);

                  final dose = MedicationDose(
                    medication: medication,
                    doseIndex: i,
                    time: time,
                  );

                  final hour = time.hour;

                  if (hour >= 5 && hour < 12) {
                    morning.add(dose);
                  } else if (hour >= 12 && hour < 18) {
                    afternoon.add(dose);
                  } else {
                    evening.add(dose);
                  }
                }
              }

              int minutes(TimeOfDay time) {
                int total = time.hour * 60 + time.minute;

                if (time.hour < 5) {
                  total += 24 * 60;
                }
                return total;
              }

              morning.sort((a, b) => minutes(a.time).compareTo(minutes(b.time)));
              afternoon.sort((a, b) => minutes(a.time).compareTo(minutes(b.time)));
              evening.sort((a, b) => minutes(a.time).compareTo(minutes(b.time)));

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
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.sp * Responsive.scale(context),
                            color: Theme.of(context).colorScheme.tertiary
                        ),
                      ),
                      SizedBox(height: 10.h * Responsive.scale(context)),
                      // Progress Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r * Responsive.scale(context)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$takenCount of $totalCount taken today',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 16.sp *  Responsive.scale(context),
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 20.sp *  Responsive.scale(context),
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h * Responsive.scale(context)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.r * Responsive.scale(context)),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h * Responsive.scale(context)),
                      // Morning
                      if (morning.isNotEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'MORNING',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16.sp * Responsive.scale(context),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                )
                            ),
                            SizedBox(height: 10.h * Responsive.scale(context)),
                            _medCard(context, medicationCubit, morning, today),
                            SizedBox(height: 20.h * Responsive.scale(context)),
                          ],
                        ),
                      // Afternoon
                      if (afternoon.isNotEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'AFTERNOON',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16.sp * Responsive.scale(context),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                )
                            ),
                            SizedBox(height: 10.h * Responsive.scale(context)),
                            _medCard(context, medicationCubit, afternoon, today),
                            SizedBox(height: 20.h * Responsive.scale(context)),
                          ],
                        ),
                      // Evening
                      if (evening.isNotEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'EVENING',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16.sp * Responsive.scale(context),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                )
                            ),
                            SizedBox(height: 10.h * Responsive.scale(context)),
                            _medCard(context, medicationCubit, evening, today),
                            SizedBox(height: 20.h * Responsive.scale(context)),
                          ],
                        ),
                      CustomButton(
                        width: double.infinity,
                        text: '+ Add Medication',
                        onTap: () {
                          final hasUnsavedChanges = ValueNotifier(false);

                          showPopup(
                            context: context,
                            title: 'Add Medication',
                            hasUnsavedChanges: hasUnsavedChanges,
                            child: AddMedication(hasUnsavedChanges: hasUnsavedChanges),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 30.0.w * Responsive.scale(context),
            vertical: 10.0.h * Responsive.scale(context)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_liquid,
              size: 80.sp * Responsive.scale(context),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 10.h * Responsive.scale(context)),
            Text(
                'No medications yet',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 30.sp * Responsive.scale(context),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )
            ),
            SizedBox(height: 40.h * Responsive.scale(context)),
            CustomButton(
              width: double.infinity,
              text: '+ Add Medication',
              onTap: () {
                final hasUnsavedChanges = ValueNotifier(false);

                showPopup(
                  context: context,
                  title: 'Add Medication',
                  hasUnsavedChanges: hasUnsavedChanges,
                  child: AddMedication(hasUnsavedChanges: hasUnsavedChanges),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Widget _medCard(BuildContext context, MedicationCubit medicationCubit, List<MedicationDose> doses, String today) {
    return Column(
        children: List.generate(doses.length, (index) {
          final dose = doses[index];
          final med = dose.medication;
          final taken = med.takenStatus[today]?[dose.doseIndex] ?? false;

          return Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          medicationCubit.toggleTaken(med.id, dose.doseIndex);
                        },
                        child: CustomListItem(
                          leading: Container(
                            height: 28.r * Responsive.scale(context),
                            width: 28.r * Responsive.scale(context),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: taken
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                              border: Border.all(
                                color: taken
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            child: taken
                                ? Icon(
                              Icons.check,
                              size: 18.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.secondary,
                            )
                                : null,
                          ),
                          title: med.name,
                          color: taken
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.primary,
                          subtitle: med.dosage,
                          trailing: taken
                              ? Text(
                            'Taken',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12.sp * Responsive.scale(context),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : Text(
                            dose.time.format(context),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 12.sp * Responsive.scale(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailingBackground: taken
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)
                              : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0.h * Responsive.scale(context),
                          vertical: 10.0.h * Responsive.scale(context)
                      ),
                      child: VerticalDivider(color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5)),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20.r * Responsive.scale(context)),
                      onTap: () {
                        final hasUnsavedChanges = ValueNotifier(false);

                        showPopup(
                          context: context,
                          title: 'Edit Medication (All Doses)',
                          hasUnsavedChanges: hasUnsavedChanges,
                          child: EditMedication(
                            medication: med,
                            hasUnsavedChanges: hasUnsavedChanges,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10.0.r * Responsive.scale(context)),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20.sp * Responsive.scale(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < doses.length - 1)
                SizedBox(height: 0.h * Responsive.scale(context), child: Divider(color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5))),
            ],
          );
        })
    );
  }
}