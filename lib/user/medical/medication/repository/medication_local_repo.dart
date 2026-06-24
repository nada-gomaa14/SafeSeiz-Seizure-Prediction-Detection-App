import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication_model.dart';

class MedicationLocalRepo {
  static const _medicationsKey = 'medications';

  Box get medicationBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box('medication_box_$userId');
  }

  Future<void> saveMedications(List<MedicationModel> medications) async {
    debugPrint('SAVING MEDICATION TO HIVE');
    await medicationBox.put(_medicationsKey, medications);
    debugPrint('MEDICATION SAVED TO HIVE');
  }

  List<MedicationModel>? getMedications() {
    final data = medicationBox.get(_medicationsKey);
    debugPrint('READING MEDICATION: $data');
    return data?.cast<MedicationModel>();
  }

  Future<void> clearMedications() async {
    await medicationBox.delete(_medicationsKey);
  }
}