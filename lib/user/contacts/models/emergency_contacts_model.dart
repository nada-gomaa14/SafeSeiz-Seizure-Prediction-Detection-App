import 'package:hive/hive.dart';

part 'emergency_contacts_model.g.dart';

@HiveType(typeId: 1)
class EmergencyContactsModel {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String relationship;

  @HiveField(3)
  final String phone;

  EmergencyContactsModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
  });

  static const List<String> relationships = [
    'Parent',
    'Sibling',
    'Spouse',
    'Friend',
    'Child',
    'Guardian',
    'Relative',
    'Doctor',
    'Caregiver',
    'Other',
  ];
}