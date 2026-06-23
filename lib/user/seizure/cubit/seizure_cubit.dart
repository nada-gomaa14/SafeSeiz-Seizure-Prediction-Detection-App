import 'package:flutter_bloc/flutter_bloc.dart';
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

    final period = reportType == 'week'
      ? now.subtract(const Duration(days: 7))
      : now.subtract(const Duration(days: 30));

    final filteredSeizures = seizuresLogs.where((s) => s.seizureDateTime.isAfter(period)).toList();
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
      chartLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
      chartValues = List.filled(7, 0);

      for (final seizure in filteredSeizures) {
        chartValues[seizure.seizureDateTime.weekday - 1]++;
      }
    } else {
      chartLabels = ['W1', 'W2', 'W3', 'W4', 'W5'];
      chartValues = List.filled(5, 0);

      for (final seizure in filteredSeizures) {
        final daysAgo = now.difference(seizure.seizureDateTime).inDays;
        final index = (daysAgo ~/ 7).clamp(0, 4);
        chartValues[index]++;
        chartValues[daysAgo ~/ 7]++;
      }

      chartValues = chartValues.reversed.toList();
    }

    return SummaryModel(
      totalSeizures: totalSeizures,
      averageDuration: averageDuration,
      lastSeizure: lastSeizure,
      lastSeizureMetric: lastSeizureMetric,
      hasSeizures: hasSeizures,
      chartLabels: chartLabels,
      chartValues: chartValues,
      chartMetric: reportType == 'week'
        ? 'Past 7 days'
        : 'Past 30 days',
    );
  }
}