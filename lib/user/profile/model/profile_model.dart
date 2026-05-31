class ProfileModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
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