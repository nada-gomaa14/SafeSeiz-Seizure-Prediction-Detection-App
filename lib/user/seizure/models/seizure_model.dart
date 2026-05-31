import 'package:hive/hive.dart';

part 'seizure_model.g.dart';

@HiveType(typeId: 2)
class SeizureModel {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime seizureDateTime;

  @HiveField(2)
  final List<String> seizureTypes;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  final List<String> triggers;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final bool isAutoDetected;

  @HiveField(8)
  final bool isSynced;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  SeizureModel({
    required this.id,
    required this.seizureDateTime,
    required this.seizureTypes,
    required this.durationMinutes,
    required this.durationSeconds,
    required this.triggers,
    this.notes,
    required this.isAutoDetected,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SeizureModel copyWith({
    String? id,
    DateTime? seizureDateTime,
    List<String>? seizureTypes,
    int? durationMinutes,
    int? durationSeconds,
    List<String>? triggers,
    String? notes,
    bool? isAutoDetected,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeizureModel(
      id: id ?? this.id,
      seizureDateTime: seizureDateTime ?? this.seizureDateTime,
      seizureTypes: seizureTypes ?? this.seizureTypes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}