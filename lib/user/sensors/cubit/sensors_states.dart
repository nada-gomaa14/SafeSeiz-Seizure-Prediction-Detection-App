import 'package:safeseiz/user/sensors/models/sensors_model.dart';

abstract class SensorsStates {}

class SensorsInitialState extends SensorsStates {}
class SensorsLoadingState extends SensorsStates {}
class SensorsSuccessState extends SensorsStates {}

class SensorsLoadedState extends SensorsStates {
  final List<SensorReadingModel> readings;
  SensorsLoadedState(this.readings);
}

class SensorsErrorState extends SensorsStates {
  final String error;
  SensorsErrorState({required this.error});
}