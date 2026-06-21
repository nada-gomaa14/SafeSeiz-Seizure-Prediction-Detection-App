import 'package:hive/hive.dart';
import '../models/medication_model.dart';

class MedicationLocalRepo {

  Future<Box<List>> get medicationBox async {
    if (!Hive.isBoxOpen('medication_box')) {
      return await Hive.openBox<List>('medication_box');
    }

    return Hive.box<List>('medication_box');
  }

  Future<void> saveMedications(String userId, List<MedicationModel> medications) async {
    final box = await medicationBox;
    await box.put('medication_$userId', medications);
  }

  Future<List<MedicationModel>?> getMedications(String userId) async {
    final box = await medicationBox;
    final data = box.get('medication_$userId');

    if (data == null) return null;

    return List<MedicationModel>.from(data);
  }

  Future<void> clearMedications(String userId) async {
    final box = await medicationBox;

    await box.delete('medication_$userId');
  }
}