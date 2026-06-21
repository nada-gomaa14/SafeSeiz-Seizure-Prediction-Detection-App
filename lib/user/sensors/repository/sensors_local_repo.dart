import 'package:hive/hive.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';

class SensorsLocalRepo {
  final Box<SensorReadingModel> sensorsBox = Hive.box<SensorReadingModel>('sensors_box');

  Future<void> saveReading(SensorReadingModel reading) async {
    await sensorsBox.add(reading);
  }

  List<SensorReadingModel> getAllReadings() {
    return sensorsBox.values.toList();
  }

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

  Future<void> labelReadings(List<SensorReadingModel> readings, String label) async {
    for (final r in readings) {
      r.label = label;
      await r.save();
    }
  }

  Future<void> purgeOldReadings() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final toDelete = <dynamic>[];

    for (final key in sensorsBox.keys) {
      final reading = sensorsBox.get(key);
      if (reading == null) continue;
      try {
        final dt = DateTime.parse(reading.timestamp);
        if (dt.isBefore(cutoff)) toDelete.add(key);
      } catch (_) {
        toDelete.add(key);
      }
    }

    for (final key in toDelete) {
      await sensorsBox.delete(key);
    }
  }

  Future<void> clearAll() async {
    await sensorsBox.clear();
  }
}