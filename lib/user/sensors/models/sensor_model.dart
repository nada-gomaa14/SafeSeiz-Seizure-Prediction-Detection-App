import 'package:hive/hive.dart';

part 'sensor_model.g.dart';

@HiveType(typeId: 4)
class SensorReadingModel extends HiveObject {

  @HiveField(0)
  final String timestamp;

  @HiveField(1)
  final double hr;

  @HiveField(2)
  final double spo2;

  @HiveField(3)
  final double rri;

  @HiveField(4)
  final double accelX;

  @HiveField(5)
  final double accelY;

  @HiveField(6)
  final double accelZ;

  @HiveField(7)
  final double gyroX;

  @HiveField(8)
  final double gyroY;

  @HiveField(9)
  final double gyroZ;

  @HiveField(10)
  String label; // normal / pre_seizure / seizure

  SensorReadingModel({
    required this.timestamp,
    required this.hr,
    required this.spo2,
    required this.rri,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    this.label = 'normal',
  });
}