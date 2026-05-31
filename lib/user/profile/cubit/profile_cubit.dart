import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/core/app_exceptions.dart';
import 'package:safeseiz/user/profile/model/profile_model.dart';
import 'package:safeseiz/user/profile/cubit/profile_states.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());

  final supabase = Supabase.instance.client;

  String? firstName;
  String? lastName;
  DateTime? dob;
  String? gender;
  String? genderError;

  ProfileModel? profile;

  // Name Validation
  bool validateName(String value, String fieldName) {
    final regex = RegExp(r'^[a-zA-Z]+$');

    if (value.trim().isEmpty) {
      emit(ProfileErrorState(error: '$fieldName is required.'));
      return false;
    }

    if (!regex.hasMatch(value.trim())) {
      emit(ProfileErrorState(error: '$fieldName must contain letters only.'));
      return false;
    }

    emit(ProfileUpdateState());
    return true;
  }

  // Update User Personal Information
  void updateFirstName(String value) {
    firstName = value.trim();
    emit(ProfileUpdateState());
  }

  void updateLastName(String value) {
    lastName = value.trim();

    emit(ProfileUpdateState());
  }

  void updateDob(DateTime value) {
    dob = value;
    emit(ProfileUpdateState());
  }

  void updateGender(String value) {
    gender = value;
    genderError = null;
    emit(ProfileUpdateState());
  }

  // Validation
  bool validateGender() {
    genderError = null;

    if (gender == null || gender!.isEmpty) {
      genderError = "This field is required.";
      emit(ProfileUpdateState());
      return false;
    }

    emit(ProfileUpdateState());
    return true;
  }

  // Create Profile
  Future<void> createProfile({
    required String userID,
    required String email,
  }) async {
    try {
       await supabase.from('profiles').insert({
        'id': userID,
        'email': email,
       });

    } catch (e) {
      throw AppException(mapErrorToMessage(e));
    }
  }

  // Save Profile
  Future<void> saveProfile() async {
    emit(ProfileLoadingState());

    final user = supabase.auth.currentUser;

    if (user == null) {
      emit(ProfileErrorState(error: "User not logged in."));
      return;
    }

    // Ensure Profile Exists
    if (profile == null) {
      await fetchProfile(user.id);

      if (profile == null) {
        emit(ProfileErrorState(error: 'Profile not loaded.'));
        return;
      }
    }

    try {
      final updatedProfile = profile!.copyWith(
        firstName: firstName ?? profile!.firstName,
        lastName: lastName ?? profile!.lastName,
        dob: dob ?? profile!.dob,
        gender: gender ?? profile!.gender,
      );

      await supabase.from('profiles').update(updatedProfile.toJson()).eq('id', user.id);
      profile = updatedProfile;   // Update Local Profile

      firstName = updatedProfile.firstName;
      lastName = updatedProfile.lastName;
      dob = updatedProfile.dob;
      gender = updatedProfile.gender;

      emit(ProfileSuccessState());
    } catch (e) {
      emit(ProfileErrorState(error: mapErrorToMessage(e)));
    }
  }

  // Fetch Profile
  Future<void> fetchProfile(String userID) async {
    emit(ProfileLoadingState());

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userID)
          .maybeSingle();

      if (data == null) {
        emit(ProfileErrorState(error: 'Profile not found.'));
        return;
      }    

      profile = ProfileModel.fromJson(data);

      firstName = profile!.firstName;
      lastName = profile!.lastName;
      dob = profile!.dob;
      gender = profile!.gender;

      emit(ProfileLoadedState(profile!));    
    } catch (e) {
      emit(ProfileErrorState(error: mapErrorToMessage(e)));
    }
  }

  String mapErrorToMessage(Object e) {
    if (e is PostgrestException) {
      final message = e.message.toLowerCase();

      if (message.contains('duplicate')) {
        return 'This data already exists.';
      }

      if (message.contains('violates foreign key')) {
        return 'Something went wrong. Please try again.';
      }

      if (message.contains('not found')) {
        return 'Profile not found.';
      }

      return 'Database error. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  // Clear Temporary In-Memory Variables
  void resetState() {
    profile = null;
    firstName = null;
    lastName = null;
    dob = null;
    gender = null;
    genderError = null;

    emit(ProfileInitialState());
  }
}