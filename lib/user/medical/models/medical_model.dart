import 'package:hive/hive.dart';

part 'medical_model.g.dart';

@HiveType(typeId: 0)
class MedicalModel extends HiveObject {

  @HiveField(0)
  final bool notDiagnosed;

  @HiveField(1)
  final DateTime? diagnosisDate;

  @HiveField(2)
  final List<String> seizureTypes;

  @HiveField(3)
  final String? seizureFrequency;

  @HiveField(4)
  final double? height;

  @HiveField(5)
  final double? weight;

  @HiveField(6)
  final String? bloodType;

  MedicalModel({
    required this.notDiagnosed,
    this.diagnosisDate,
    required this.seizureTypes,
    this.seizureFrequency,
    this.height,
    this.weight,
    this.bloodType
  });

  MedicalModel copyWith({
    DateTime? diagnosisDate,
    bool? notDiagnosed,
    List<String>? seizureTypes,
    String? seizureFrequency,
    double? height,
    double? weight,
    String? bloodType,
  }) {
    return MedicalModel(
      notDiagnosed: notDiagnosed ?? this.notDiagnosed,
      diagnosisDate: diagnosisDate ?? this.diagnosisDate,
      seizureTypes: seizureTypes ?? this.seizureTypes,
      seizureFrequency: seizureFrequency ?? this.seizureFrequency,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
    );
  }

  static const List<String> seizureTypeOptions = [
    'Focal',
    'Tonic-clonic',
    'Absence',
    'Myoclonic',
    'Atonic',
    'Unknown'
  ];

  static const List<String> seizureFrequencyOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Rarely',
    'Not sure'
  ];

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  double? get bmi {
    if (height == null || weight == null) return null;

    final heightInMeters = height! / 100;

    return weight! /
        (heightInMeters * heightInMeters);
  }
}