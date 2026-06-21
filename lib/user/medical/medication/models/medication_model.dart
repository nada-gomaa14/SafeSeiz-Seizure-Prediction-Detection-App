import 'package:hive/hive.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 3)
class MedicationModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final Map<String, Map<int, bool>> takenStatus;

  @HiveField(4)
  final int frequency;

  @HiveField(5)
  final List<String> times;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.takenStatus,
    required this.frequency,
    required this.times
  });

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    Map<String, Map<int, bool>>? takenStatus,
    int? frequency,
    List<String>? times
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      takenStatus: takenStatus ?? this.takenStatus,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times
    );
  }
}