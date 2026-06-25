import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorsLocalRepo {
  Box<SensorReadingModel>? get sensorsBox {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final boxName = 'sensors_box_${user.id}';
    if (!Hive.isBoxOpen(boxName)) {
      return null;
    }
    return Hive.box<SensorReadingModel>(boxName);
  }

  // Save a single reading
  Future<void> saveReading(SensorReadingModel reading) async {
    final box = sensorsBox;
    if (box == null) return; 

    debugPrint('SAVING SENSOR TO HIVE');
    await box.add(reading);
    debugPrint('SENSOR SAVED TO HIVE');
  }

  // Get all readings
  List<SensorReadingModel> getAllReadings() {
    final box = sensorsBox;
    if (box == null) return []; 

    final data = box.values.toList();
    debugPrint('READING SENSOR: $data');
    return data;
  }

  // Get readings around a seizure time (2 min before, 30 sec after)
  List<SensorReadingModel> getReadingsAround(DateTime seizureTime) {
    final box = sensorsBox;
    if (box == null) return []; 
    
    final from = seizureTime.subtract(const Duration(minutes: 2));
    final to   = seizureTime.add(const Duration(seconds: 30));

    return box.values.where((r) {
      try {
        final dt = DateTime.parse(r.timestamp);
        return dt.isAfter(from) && dt.isBefore(to);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Label readings and link them to a seizure
  Future<void> labelReadings({required List<SensorReadingModel> readings, required String label, required String seizureId}) async {
    for (final r in readings) {
      r.label = label;
      r.seizureId = seizureId;
      await r.save();
    }
  }

  // Get all unsynced labeled readings (non-normal)
  List<SensorReadingModel> getUnsyncedLabeledReadings() {
    final box = sensorsBox;
    if (box == null) return []; 

    return box.values.where((r) => r.label != 'normal' && !r.isSynced).toList();
  }

  // Mark a reading as synced
  Future<void> markAsSynced(SensorReadingModel reading) async {
    reading.isSynced = true;
    await reading.save();
  }

  // Purge readings older than 48 hours that are still labeled normal
  Future<void> purgeOldReadings() async {
    final box = sensorsBox;
    if (box == null) return; 

    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final toDelete = <dynamic>[];

    for (final key in box.keys) {
      final reading = box.get(key);
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
      await box.delete(key);
    }
  }

  // Clear all readings
  Future<void> clearAll() async {
    final box = sensorsBox;
    if (box == null) return; 
    
    await box.clear();
  }
}