import 'package:safeseiz/user/medical/medication/models/medication_model.dart';

abstract class MedicationStates {}

class MedicationInitialState extends MedicationStates {}
class MedicationUpdateState extends MedicationStates {}
class MedicationLoadingState extends MedicationStates {}
class MedicationSuccessState extends MedicationStates {}

class MedicationLoadedState extends MedicationStates {
  final List<MedicationModel> medications;
  MedicationLoadedState(this.medications);
}

class MedicationErrorState extends MedicationStates {
  final String error;
  MedicationErrorState({
    required this.error,
  });
}