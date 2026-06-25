import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/services/hive_manager.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_states.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';
import 'package:safeseiz/user/sensors/repository/sensors_local_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorsCubit extends Cubit<SensorsStates> {
  SensorsCubit(this.sensorsLocalRepo) : super(SensorsInitialState());

  final SensorsLocalRepo sensorsLocalRepo;
  final supabase = Supabase.instance.client;
  List<SensorReadingModel> readings = [];

  // Save a single incoming reading from the watch
  Future<void> saveReading(SensorReadingModel reading) async {
    try {
      await sensorsLocalRepo.saveReading(reading);
      await sensorsLocalRepo.purgeOldReadings();
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Load all readings
  Future<void> loadReadings() async {
    emit(SensorsLoadingState());
    try {
      readings = sensorsLocalRepo.getAllReadings();
      emit(SensorsLoadedState(readings));
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Label readings around a seizure time — seizure confirmed
  Future<void> labelSeizureReadings({
    required DateTime seizureTime,
    required String seizureId,
  }) async {
    try {
      final window = sensorsLocalRepo.getReadingsAround(seizureTime);
      debugPrint('Label seizure: found ${window.length} readings around $seizureTime');
      if (window.isEmpty) return;

      await sensorsLocalRepo.labelReadings(readings: window, label: 'seizure', seizureId: seizureId);
      debugPrint('Label seizure: labeled ${window.length} readings');
      syncToSupabase();
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Label readings around a false alarm time — user cancelled SOS
  Future<void> labelFalseAlarmReadings({
    required DateTime alarmTime,
    required String seizureId,
  }) async {
    try {
      final window = sensorsLocalRepo.getReadingsAround(alarmTime);
      if (window.isEmpty) return;

      await sensorsLocalRepo.labelReadings(readings: window, label: 'false_alarm', seizureId: seizureId);
      syncToSupabase();
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Sync labeled readings to Supabase
  Future<void> syncToSupabase() async {
    final userId = HiveManager.currentUserId;
    if (userId == null) return;

    final unsynced = sensorsLocalRepo.getUnsyncedLabeledReadings();
    if (unsynced.isEmpty) return;

    for (final reading in unsynced) {
      try {
        await supabase.from('sensor_readings').insert({
          'seizure_id': reading.seizureId,
          'user_id': userId,
          'timestamp': reading.timestamp,
          'ppg': reading.ppg,
          'hr': reading.hr,
          'rri': reading.rri,
          'accel_x': reading.accelX,
          'accel_y': reading.accelY,
          'accel_z': reading.accelZ,
          'gyro_x': reading.gyroX,
          'gyro_y': reading.gyroY,
          'gyro_z': reading.gyroZ,
          'label': reading.label,
          'created_at': DateTime.now().toIso8601String(),
        });
        await sensorsLocalRepo.markAsSynced(reading);
      } catch (_) {
        // Stays unsynced — will retry on next syncToSupabase() call
      }
    }
  }

  // Clear all readings
  Future<void> clearReadings() async {
    emit(SensorsLoadingState());
    try {
      await sensorsLocalRepo.clearAll();
      readings = [];
      emit(SensorsSuccessState());
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }
}