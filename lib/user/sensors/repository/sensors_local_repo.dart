import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorsLocalRepo {
  Box<SensorReadingModel> get sensorsBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box<SensorReadingModel>('sensors_box_$userId');
  }

  // Save a single reading
  Future<void> saveReading(SensorReadingModel reading) async {
    debugPrint('SAVING SENSOR TO HIVE');
    await sensorsBox.add(reading);
    debugPrint('SENSOR SAVED TO HIVE');
  }

  // Get all readings
  List<SensorReadingModel> getAllReadings() {
    final data = sensorsBox.values.toList();
    debugPrint('READING SENSOR: $data');
    return data;
  }

  // Get readings around a seizure time (2 min before, 30 sec after)
  List<SensorReadingModel> getReadingsAround(DateTime seizureTime) {
    final from = seizureTime.subtract(const Duration(minutes: 2));
    final to   = seizureTime.add(const Duration(seconds: 30));

    return sensorsBox.values.where((r) {
      try {
        final dt = DateTime.parse(r.timestamp);
        return dt.isAfter(from) && dt.isBefore(to);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Label readings and link them to a seizure
  Future<void> labelReadings({
    required List<SensorReadingModel> readings,
    required String label,
    required String seizureId,
  }) async {
    for (final r in readings) {
      r.label = label;
      r.seizureId = seizureId;
      await r.save();
    }
  }

  // Get all unsynced labeled readings (non-normal)
  List<SensorReadingModel> getUnsyncedLabeledReadings() {
    return sensorsBox.values.where((r) => r.label != 'normal' && !r.isSynced).toList();
  }

  // Mark a reading as synced
  Future<void> markAsSynced(SensorReadingModel reading) async {
    reading.isSynced = true;
    await reading.save();
  }

  // Purge readings older than 48 hours that are still labeled normal
  Future<void> purgeOldReadings() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final toDelete = <dynamic>[];

    for (final key in sensorsBox.keys) {
      final reading = sensorsBox.get(key);
      if (reading == null) continue;
      try {
        final dt = DateTime.parse(reading.timestamp);
        if (dt.isBefore(cutoff) && reading.label == 'normal') {
          toDelete.add(key);
        }
      } catch (_) {
        toDelete.add(key);
      }
    }

    for (final key in toDelete) {
      await sensorsBox.delete(key);
    }
  }

  // Clear all readings
  Future<void> clearAll() async {
    await sensorsBox.clear();
  }
}