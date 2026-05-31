import 'package:safeseiz/user/medical/models/medical_model.dart';

abstract class MedicalStates {}

class MedicalInitialState extends MedicalStates {}
class MedicalUpdateState extends MedicalStates {}
class MedicalLoadingState extends MedicalStates {}
class MedicalSuccessState extends MedicalStates {}

class MedicalLoadedState extends MedicalStates {
  final MedicalModel medical;
  MedicalLoadedState(this.medical);
}

class MedicalErrorState extends MedicalStates {
  final String error;
  MedicalErrorState({required this.error});
}