import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_states.dart';
import 'package:safeseiz/user/medical/medication/models/medication_model.dart';
import 'package:safeseiz/user/medical/medication/repository/medication_local_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationCubit extends Cubit<MedicationStates> {
  MedicationCubit(this.medicationLocalRepo) : super(MedicationInitialState());

  final MedicationLocalRepo medicationLocalRepo;
  final supabase = Supabase.instance.client;

  List<MedicationModel> medications = [];

  // Date Helper
  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Add Medication
  Future<bool> addMedication(MedicationModel medication) async {
    final name = medication.name.trim();
    final dosage = medication.dosage.trim();
    final frequency = medication.frequency;
    final times = medication.times;

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicationErrorState(error: 'User not logged in.'));
        return false;
      }

      if (name.isEmpty || dosage.isEmpty || frequency <= 0 || times.length != frequency) {
        emit(MedicationErrorState(error: 'Please fill all fields.'));
        return false;
      }

      emit(MedicationLoadingState());

      medications.add(medication);
      debugPrint('SAVING medications for user: ${user.id}');

      await medicationLocalRepo.saveMedications(medications);

      emit(MedicationLoadedState(medications));
      return true;
    } catch (e, stackTrace) {
      debugPrint('Medication save error: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(MedicationErrorState(error: 'Failed to add medication.'));
      return false;
    }
  }

  // Update Medication
  Future<bool> updateMedication(String id, MedicationModel updatedMedication) async {
    emit(MedicationLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicationErrorState(error: 'User not logged in.'));
        return false;
      }

      final index = medications.indexWhere((med) => med.id == id);

      if (index == -1) {
        emit(MedicationErrorState(error: 'Medication not found.'));
        return false;
      }

      medications[index] = updatedMedication;

      await medicationLocalRepo.saveMedications(medications);

      emit(MedicationLoadedState(medications));
      return true;
    } catch (e) {
      emit(MedicationErrorState(error: 'Failed to update medication.'));
      return false;
    }
  }

  // Delete Medication
  Future<bool> deleteMedication(String id) async {
    emit(MedicationLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicationErrorState(error: 'User not logged in.'));
        return false;
      }

      final index = medications.indexWhere((med) => med.id == id);

      if (index == -1) return false;

      medications.removeAt(index);

      await medicationLocalRepo.saveMedications(medications);

      emit(MedicationLoadedState(medications));
      return true;
    } catch (e) {
      emit(MedicationErrorState(error: 'Failed to delete medication.'));
      return false;
    }
  }

  // Toggle Taken Status
  Future<void> toggleTaken(String id, int freqIndex) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicationErrorState(error: 'User not logged in.'));
        return;
      }

      final index = medications.indexWhere((med) => med.id == id);

      if (index == -1) return;

      final current = medications[index];
      final allStatuses = <String, Map<int, bool>>{};

      current.takenStatus.forEach((date, status) {
        allStatuses[date] = Map<int, bool>.from(status);
      });

      final todayStatus = Map<int, bool>.from(allStatuses[today] ?? {});

      todayStatus[freqIndex] = !(todayStatus[freqIndex] ?? false);

      allStatuses[today] = todayStatus;

      medications[index] = current.copyWith(takenStatus: allStatuses);

      await medicationLocalRepo.saveMedications(medications);

      emit(MedicationLoadedState(medications));
    } catch (e) {
      emit(MedicationErrorState(
        error: 'Failed to update medication status.',
      ));
    }
  }

  // Fetch Medications
  Future<void> fetchMedications() async {
    emit(MedicationLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(MedicationErrorState(error: 'User not logged in.'));
        return;
      }

      debugPrint('FETCHING medications for user: ${user.id}');

      final data = medicationLocalRepo.getMedications();

      if (data == null) {
        medications = [];
        emit(MedicationInitialState());
        return;
      }

      medications = data;

      emit(MedicationLoadedState(medications));
    } catch (e) {
      emit(MedicationErrorState(error: 'Failed to load medications.'));
    }
  }

  // Clear Medications
  Future<void> clearMedications() async {
    emit(MedicationLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await medicationLocalRepo.clearMedications();
      }

      medications = [];

      emit(MedicationInitialState());
    } catch (e) {
      emit(MedicationErrorState(error: 'Failed to clear medications.'));
    }
  }

  // Reset Cubit State
  void resetState() {
    medications = [];
    emit(MedicationInitialState());
  }
}