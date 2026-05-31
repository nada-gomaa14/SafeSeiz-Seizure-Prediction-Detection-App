import 'package:safeseiz/user/seizure/models/seizure_model.dart';

abstract class SeizureStates {}

class SeizureInitialState extends SeizureStates {}
class SeizureUpdateState extends SeizureStates {}
class SeizureLoadingState extends SeizureStates {}
class SeizureSuccessState extends SeizureStates {}

class SeizureLoadedState extends SeizureStates {
  final List<SeizureModel> seizures;
  SeizureLoadedState(this.seizures);
}

class SeizureErrorState extends SeizureStates {
  final String error;
  SeizureErrorState({required this.error});
}