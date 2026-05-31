import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/user/medical/cubit/medical_states.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';
import 'package:safeseiz/user/medical/repository/medical_local_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalCubit extends Cubit<MedicalStates> {
  MedicalCubit(this.medicalLocalRepo) : super(MedicalInitialState());
  final MedicalLocalRepo medicalLocalRepo;
  final supabase = Supabase.instance.client;

  // Medical Information
  bool notDiagnosed = false;
  DateTime? diagnosisDate;
  List<String> seizureTypes = [];
  String? seizureFrequency;

  // Health Information
  double? height;
  double? weight;
  String? bloodType;

  MedicalModel? medical;

  // BMI Getter
  double? get bmi => medical?.bmi;

  // Update Diagnosis Status
  void updateNotDiagnosed(bool value) {
    notDiagnosed = value;

    if (notDiagnosed) {
      diagnosisDate = null;
    }

    emit(MedicalUpdateState());
  }

  // Update Diagnosis Date
  void updateDiagnosisDate(DateTime? value) {
    diagnosisDate = value;
    notDiagnosed = false;
    emit(MedicalUpdateState());
  }

  // Update Seizure Types
  void updateSeizureTypes(List<String> value) {
    seizureTypes = value;
    emit(MedicalUpdateState());
  }

  // Update Seizure Frequency
  void updateSeizureFrequency(String? value) {
    seizureFrequency = value;
    emit(MedicalUpdateState());
  }

  // Update Height
  void updateHeight(double? value) {
    height = value;
    emit(MedicalUpdateState());
  }

  // Update Weight
  void updateWeight(double? value) {
    weight = value;
    emit(MedicalUpdateState());
  }

  // Update Blood Type
  void updateBloodType(String? value) {
    bloodType = value;
    emit(MedicalUpdateState());
  }

  // Validate Height
  bool isValidHeight(double? height) {
    if (height != null && height <= 0) {
      emit(MedicalErrorState(error: 'Height must be greater than 0.'));
      return false;
    }
    return true;
  }

  // Validate Weight
  bool isValidWeight(double? weight) {
    if (weight != null && weight <= 0) {
      emit(MedicalErrorState(error: 'Weight must be greater than 0.'));
      return false;
    }
    return true;
  }

  // Save Medical Information
  Future<bool> saveMedicalInfo() async {
    emit(MedicalLoadingState());

    try {
      final medicalModel = MedicalModel(
        notDiagnosed: notDiagnosed,
        diagnosisDate: diagnosisDate,
        seizureTypes: seizureTypes,
        seizureFrequency: seizureFrequency,
        height: height,
        weight: weight,
        bloodType: bloodType
      );

      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicalErrorState(error: 'User not logged in.'));
        return false;
      }

      debugPrint('SAVING medical for user: ${user.id}');

      await medicalLocalRepo.saveMedicalInfo(user.id, medicalModel);

      final test = await medicalLocalRepo.getMedicalInfo(user.id);
      debugPrint('AFTER SAVE: $test');

      medical = medicalModel;

      emit(MedicalSuccessState());
      return true;

    } catch (e, stackTrace) {
      debugPrint('Medical save error: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(MedicalErrorState(error: 'Failed to save medical information.'));
      return false;
    }
  }

  // Fetch Medical Information
  Future<void> fetchMedicalInfo() async {
    emit(MedicalLoadingState());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(MedicalErrorState(error: 'User not logged in.'));
        return;
      }

      debugPrint('FETCHING medical for user: ${user.id}');

      final data = await medicalLocalRepo.getMedicalInfo(user.id);
      debugPrint('FETCHED DATA: $data');

      if (data == null) {
        medical = null;
        clearForm();
        
        emit(MedicalInitialState());
        return;
      }

      medical = data;
      notDiagnosed = data.notDiagnosed;
      diagnosisDate = data.diagnosisDate;
      seizureTypes = data.seizureTypes;
      seizureFrequency = data.seizureFrequency;
      height = data.height;
      weight = data.weight;
      bloodType = data.bloodType;

      emit(MedicalLoadedState(data));

    } catch (e) {

      emit(
        MedicalErrorState(
          error: 'Failed to load medical information.',
        ),
      );
    }
  }

  // Clear Form
  void clearForm() {
    notDiagnosed = false;
    diagnosisDate = null;
    seizureTypes = [];
    seizureFrequency = null;
    height = null;
    weight = null;
    bloodType = null;
  }

  // Clear Medical Information
  Future<void> clearMedicalInfo() async {
    emit(MedicalLoadingState());

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await medicalLocalRepo.clearMedicalInfo(user.id);
      }

      medical = null;
      clearForm();

      emit(MedicalInitialState());

    } catch (e) {

      emit(
        MedicalErrorState(
          error: 'Failed to clear medical information.',
        ),
      );
    }
  }

  // Clear Temporary In-Memory Variables
  void resetState() {
    medical = null;
    clearForm();

    emit(MedicalInitialState());
  }
}