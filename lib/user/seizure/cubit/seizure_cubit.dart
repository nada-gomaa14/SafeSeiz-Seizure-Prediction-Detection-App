import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/seizure/models/summary_model.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:safeseiz/user/seizure/repository/seizure_local_repo.dart';

class SeizureCubit extends Cubit<SeizureStates> {
  final SensorsCubit sensorsCubit;
  final SeizureLocalRepo seizureLocalRepo = SeizureLocalRepo();
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  SeizureCubit(this.sensorsCubit) : super(SeizureInitialState());
  
  // Cached Seizure Logs
  List<SeizureModel> seizuresLogs = [];

  // Form Data
  DateTime? seizureDateTime;
  List<String> seizureTypes = [];
  int durationMinutes = 0;
  int durationSeconds = 0;
  String? notes;

  // Validation Errors
  String? seizureTypesError;

  // Summary Report
  String reportType = 'week';

  // Update Date & Time
  void updateSeizureDateTime(DateTime value) {
    seizureDateTime = value;
    emit(SeizureUpdateState());
  }

  // Update Seizure Type
  void updateSeizureTypes(List<String> types) {
    seizureTypes = types;
    seizureTypesError = null;
    emit(SeizureUpdateState());
  }

  // Update Duration Minutes
  void updateDurationMinutes(int value) {
    durationMinutes = value;
    emit(SeizureUpdateState());
  }

  // Update Duration Seconds
  void updateDurationSeconds(int value) {
    durationSeconds = value;
    emit(SeizureUpdateState());
  }

  // Update Notes
  void updateNotes(String value) {
    notes = value;
    emit(SeizureUpdateState());
  }

  // Update Report Type
  void updateReportType(String value) {
    reportType = value;
    emit(SeizureUpdateState());
  }

  // Validate Seizure Type
  bool validateSeizureTypes() {
    seizureTypesError = null;

    if (seizureTypes.isEmpty) {
      seizureTypesError = 'Select at least one seizure type.';
      emit(SeizureUpdateState());
      return false;
    }

    emit(SeizureUpdateState());
    return true;
  }

  // Add Seizure
  Future<bool> addSeizure({required bool isAutoDetected}) async {
    emit(SeizureLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(SeizureErrorState(error: 'User not logged in.'));
        return false;
      }

      final seizure = SeizureModel(
        id: uuid.v4(),
        seizureDateTime: seizureDateTime ?? DateTime.now(),
        seizureTypes: List<String>.from(seizureTypes),
        durationMinutes: durationMinutes,
        durationSeconds: durationSeconds,
        notes: notes,
        isAutoDetected: isAutoDetected,
        createdAt: DateTime.now(),
      );

      final seizures = seizureLocalRepo.getSeizures(user.id);
      seizures.add(seizure);
      await seizureLocalRepo.saveSeizures(user.id, seizures);

      clearForm();
      await loadSeizures();
      syncToSupabase();

      emit(SeizureSuccessState());
      return true;
    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
      return false;
    }
  }

  // Sync To Supabase
  Future<void> syncToSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final unsynced = seizureLocalRepo.getUnsyncedSeizures(user.id);
    if (unsynced.isEmpty) return;

    for (final seizure in unsynced) {
      try {
        await supabase.from('seizures').upsert({
          'id': seizure.id,
          'user_id': user.id,
          'seizure_date_time': seizure.seizureDateTime.toIso8601String(),
          'seizure_types': seizure.seizureTypes,
          'duration_minutes': seizure.durationMinutes,
          'duration_seconds': seizure.durationSeconds,
          'notes': seizure.notes,
          'is_auto_detected': seizure.isAutoDetected,
          'created_at': seizure.createdAt.toIso8601String(),
        });

        await seizureLocalRepo.markAsSynced(user.id, seizure.id);
      } catch (e) {
        // Stays unsynced — will retry on next syncToSupabase() call
      }
    }
  }

  // Load Seizures
  Future<void> loadSeizures() async {
    emit(SeizureLoadingState());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(SeizureErrorState(error: 'User not logged in.'));
        return;
      }

      seizuresLogs = seizureLocalRepo.getSeizures(user.id);
      seizuresLogs.sort((a, b) => b.seizureDateTime.compareTo(a.seizureDateTime));

      emit(SeizureLoadedState(seizuresLogs));

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }

  // Clear Form
  void clearForm() {
    seizureDateTime = null;
    seizureTypes = [];
    durationMinutes = 0;
    durationSeconds = 0;
    notes = null;
    seizureTypesError = null;
  }

  // Clear Temporary In-Memory Variables
  void resetState() {
    seizuresLogs = [];
    clearForm();
    reportType = 'week';

    emit(SeizureInitialState());
  }

  // Clear Seizures
  Future<void> clearSeizures() async {
    emit(SeizureLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await seizureLocalRepo.clearSeizures(user.id);
      }

      seizuresLogs = [];
      clearForm();

      emit(SeizureSuccessState());

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }

  // Summary Stats
  SummaryModel getSummaryStats() {   
    final now = DateTime.now();    
    final filteredSeizures = getFilteredSeizures();
    final hasSeizures = filteredSeizures.isNotEmpty;

    final totalSeizures = hasSeizures
      ? filteredSeizures.length.toString()
      : '--';

    final avgDuration = filteredSeizures.isEmpty
      ? 0
      : filteredSeizures.map((s) => s.durationMinutes * 60 + s.durationSeconds).reduce((a, b) => a + b) ~/ filteredSeizures.length;

    final avgMinutes = avgDuration ~/ 60;
    final avgSeconds = avgDuration % 60;

    final averageDuration = hasSeizures
      ? '${avgMinutes}m ${avgSeconds.toString().padLeft(2, '0')}s'
      : '--';
    
    final latestSeizure = seizuresLogs.isEmpty
      ? null
      : seizuresLogs.reduce(
        (a, b) => a.seizureDateTime.isAfter(b.seizureDateTime)
          ? a
          : b,
      );

    final difference = latestSeizure == null
      ? null
      : now.difference(latestSeizure.seizureDateTime);

    final seizureFreeStreak = difference == null
      ? '--'
      : difference.inDays.toString();

    final lastSeizure = difference == null
      ? '--'
      : difference.inDays > 0
        ? '${difference.inDays}'
        : '${difference.inHours}';

    final lastSeizureMetric = difference == null
      ? ''
      : difference.inDays > 0
        ? 'days ago'
        : 'hours ago';

    List<String> chartLabels;
    List<int> chartValues;

    if (reportType == 'week') {
      const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      chartLabels = [];
      chartValues = [];

      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        chartLabels.add(weekdays[day.weekday % 7]);

        final count = filteredSeizures.where((s) {
          return s.seizureDateTime.year == day.year && s.seizureDateTime.month == day.month && s.seizureDateTime.day == day.day;
        }).length;

        chartValues.add(count);
      }
    } else if (reportType == 'month') {
      chartLabels = ['4w ago', '3w ago', '2w ago', 'This week'];
      chartValues = List.filled(4, 0);

      for (final seizure in filteredSeizures) {
        final daysAgo = now.difference(seizure.seizureDateTime).inDays;
        final index = 3 - (daysAgo ~/ 7);

        if (index >= 0 && index < 4) {
          chartValues[index]++;
        }
      }
    } else {
      chartLabels = [];
      chartValues = List.filled(6, 0);

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month -i);
        chartLabels.add(DateFormat('MMM').format(month));
      }

      for (final seizure in filteredSeizures) {
        final diff = (now.year - seizure.seizureDateTime.year) * 12 + now.month - seizure.seizureDateTime.month;

        if (diff >= 0 && diff < 6) {
          chartValues[5 - diff]++;
        }
      }
    }

    return SummaryModel(
      totalSeizures: totalSeizures,
      averageDuration: averageDuration,
      lastSeizure: lastSeizure,
      lastSeizureMetric: lastSeizureMetric,
      seizureFreeStreak: seizureFreeStreak,
      hasSeizures: hasSeizures,
      chartLabels: chartLabels,
      chartValues: chartValues,
      chartMetric: reportType == 'week'
        ? 'Past 7 days'
        : reportType == 'month'
          ? 'Past 4 weeks'
          : 'Past 6 months',
    );
  }

  // Seizure Filter
  List<SeizureModel> getFilteredSeizures() {
    final now = DateTime.now();
    late final DateTime period;

    if (reportType == 'week') {
      period = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    } else if (reportType == 'month') {
      period = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    } else {
      period = DateTime(now.year, now.month - 5, now.day);
    }

    return seizuresLogs.where((s) => !s.seizureDateTime.isBefore(period)).toList();
  }
}