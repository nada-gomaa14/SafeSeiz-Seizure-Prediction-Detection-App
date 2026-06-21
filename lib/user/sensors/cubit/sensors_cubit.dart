import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_states.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';
import 'package:safeseiz/user/sensors/repository/sensors_local_repo.dart';

class SensorsCubit extends Cubit<SensorsStates> {
  SensorsCubit() : super(SensorsInitialState());
  final SensorsLocalRepo sensorsLocalRepo = SensorsLocalRepo();
  List<SensorReadingModel> readings = [];

  // Save a single incoming reading from the watch
  Future<void> saveReading(SensorReadingModel reading) async {
    try {
      await sensorsLocalRepo.saveReading(reading);
      await sensorsLocalRepo.purgeOldReadings();
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Load all readings
  Future<void> loadReadings() async {
    emit(SensorsLoadingState());
    try {
      readings = sensorsLocalRepo.getAllReadings();
      emit(SensorsLoadedState(readings));
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Get readings around a seizure time — used for labelling and retraining
  List<SensorReadingModel> getReadingsAround(DateTime seizureTime) {
    return sensorsLocalRepo.getReadingsAround(seizureTime);
  }

  // Label readings around a seizure — called after seizure is confirmed
  Future<void> labelSeizureReadings(DateTime seizureTime) async {
    try {
      final window = sensorsLocalRepo.getReadingsAround(seizureTime);
      if (window.isEmpty) return;
      await sensorsLocalRepo.labelReadings(window, 'seizure');
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }

  // Clear all readings
  Future<void> clearReadings() async {
    emit(SensorsLoadingState());
    try {
      await sensorsLocalRepo.clearAll();
      readings = [];
      emit(SensorsSuccessState());
    } catch (e) {
      emit(SensorsErrorState(error: e.toString()));
    }
  }
}