import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 5)
class ProfileModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? firstName;

  @HiveField(3)
  final String? lastName;

  @HiveField(4)
  final DateTime? dob;

  @HiveField(5)
  final String? gender;

  ProfileModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dob: json['date_of_birth'] != null
        ? DateTime.parse(json['date_of_birth'] as String)
        : null,
      gender: json['gender'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dob?.toIso8601String().split('T')[0],
      'gender': gender
    };
  }

  ProfileModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? gender,
  }) {
    return ProfileModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
    );
  }
}