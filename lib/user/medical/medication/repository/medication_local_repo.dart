import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive_manager.dart';
import '../models/medication_model.dart';

class MedicationLocalRepo {
  static const _medicationsKey = 'medications';

  Box? get medicationBox {
    final userId = HiveManager.currentUserId;
    if (userId == null) return null;

    final boxName = 'medication_box_$userId';
    if (!Hive.isBoxOpen(boxName)) {
      return null;
    }

    return Hive.box(boxName);
  }

  Future<void> saveMedications(List<MedicationModel> medications) async {
    final box = medicationBox;
    if (box == null) return;

    debugPrint('SAVING MEDICATION TO HIVE');
    await box.put(_medicationsKey, medications);
    debugPrint('MEDICATION SAVED TO HIVE');
  }

  List<MedicationModel> getMedications() {
    final box = medicationBox;
    if (box == null) return [];

    final data = box.get(_medicationsKey);
    debugPrint('READING MEDICATION: $data');
    return data == null
      ? []
      : data.cast<MedicationModel>();
  }

  Future<void> clearMedications() async {
    final box = medicationBox;
    if (box == null) return;
    await box.delete(_medicationsKey);
  }
}