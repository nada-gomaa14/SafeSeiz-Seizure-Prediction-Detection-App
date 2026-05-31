import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:safeseiz/user/seizure/repository/seizure_local_repo.dart';

class SeizureCubit extends Cubit<SeizureStates> {
  SeizureCubit() : super(SeizureInitialState());
  final SeizureLocalRepo seizureLocalRepo = SeizureLocalRepo();
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  // Cached Seizure Logs
  List<SeizureModel> seizuresLogs = [];

  // Form Data
  DateTime? seizureDateTime;
  List<String> seizureTypes = [];
  int durationMinutes = 0;
  int durationSeconds = 0;
  String? notes;

  // Validation Errors
  String? seizureTypesError;

  // Update Date & Time
  void updateSeizureDateTime(DateTime value) {
    seizureDateTime = value;
    emit(SeizureUpdateState());
  }

  // Update Seizure Type
  void updateSeizureTypes(List<String> types) {
    seizureTypes = types;
    seizureTypesError = null;
    emit(SeizureUpdateState());
  }

  // Update Duration Minutes
  void updateDurationMinutes(int value) {
    durationMinutes = value;
    emit(SeizureUpdateState());
  }

  // Update Duration Seconds
  void updateDurationSeconds(int value) {
    durationSeconds = value;
    emit(SeizureUpdateState());
  }

  // Update Notes
  void updateNotes(String value) {
    notes = value;
    emit(SeizureUpdateState());
  }

  // Validate Seizure Type
  bool validateSeizureTypes() {
    seizureTypesError = null;

    if (seizureTypes.isEmpty) {
      seizureTypesError = 'Select at least one seizure type.';
      emit(SeizureUpdateState());
      return false;
    }

    emit(SeizureUpdateState());
    return true;
  }

  // Add Seizure
  Future<bool> addSeizure({required bool isAutoDetected}) async {
    emit(SeizureLoadingState());

    try {
      final seizure = SeizureModel(
        id: uuid.v4(),
        seizureDateTime: seizureDateTime ?? DateTime.now(),
        seizureTypes: List<String>.from(seizureTypes),
        durationMinutes: durationMinutes,
        durationSeconds: durationSeconds,
        notes: notes,
        isAutoDetected: isAutoDetected,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(SeizureErrorState(error: 'User not logged in.'));
        return false;
      }

      final seizures = seizureLocalRepo.getSeizures(user.id);
      seizures.add(seizure);

      await seizureLocalRepo.saveSeizures(user.id, seizures);
      await loadSeizures();

      clearForm();

      emit(SeizureSuccessState());
      return true;

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
      return false;
    }
  }

  // Delete Seizure
  Future<void> deleteSeizure({required String userId, required String seizureId}) async {
    emit(SeizureLoadingState());

    try {
      await seizureLocalRepo.deleteSeizure(userId: userId, seizureId: seizureId);
      await loadSeizures();

      emit(SeizureSuccessState());

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }

  // Update Seizure
  Future<void> updateSeizure({required String userId, required SeizureModel seizure}) async {
    emit(SeizureLoadingState());

    try {
      final updatedSeizure = seizure.copyWith(updatedAt: DateTime.now());

      final seizures = seizureLocalRepo.getSeizures(userId);
      final index = seizures.indexWhere((s) => s.id == updatedSeizure.id);

      if (index != -1) {
        seizures[index] = updatedSeizure;
        await seizureLocalRepo.saveSeizures(userId, seizures);
      }

      await loadSeizures();
      emit(SeizureSuccessState());

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }

  // Load Seizures
  Future<void> loadSeizures() async {
    emit(SeizureLoadingState());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(SeizureErrorState(error: 'User not logged in.'));
        return;
      }

      seizuresLogs = seizureLocalRepo.getSeizures(user.id);

      seizuresLogs.sort((a, b) => b.seizureDateTime.compareTo(a.seizureDateTime));

      emit(SeizureLoadedState(seizuresLogs));

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }

  // Clear Form
  void clearForm() {
    seizureDateTime = null;
    seizureTypes = [];
    durationMinutes = 0;
    durationSeconds = 0;
    notes = null;
    seizureTypesError = null;
  }

  // Clear Temporary In-Memory Variables
  void resetState() {
    seizuresLogs = [];
    clearForm();

    emit(SeizureInitialState());
  }

  // Clear Seizures
  Future<void> clearSeizures() async {
    emit(SeizureLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await seizureLocalRepo.clearSeizures(user.id);
      }

      seizuresLogs = [];
      clearForm();

      emit(SeizureSuccessState());

    } catch (e) {
      emit(SeizureErrorState(error: e.toString()));
    }
  }
}