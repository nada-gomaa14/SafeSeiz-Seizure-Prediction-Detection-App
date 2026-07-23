import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive/hive_manager.dart';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';

class MedicalLocalRepo {
  static const _medicalKey = 'medical_info';

  Box<MedicalModel>? get medicalBox {
    final userId = HiveManager.currentUserId;
    if (userId == null) return null;

    final boxName = 'medical_info_box_$userId';
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('Medical box is not open: $boxName');
      return null;
    }
    
    return Hive.box<MedicalModel>(boxName);
  }

  Future<void> saveMedicalInfo(MedicalModel medicalInfo) async {
    final box = medicalBox;
    if (box == null) return;

    debugPrint('SAVING MEDICAL TO HIVE');
    await box.put(_medicalKey, medicalInfo);
    debugPrint('MEDICAL SAVED TO HIVE');
  }

  MedicalModel? getMedicalInfo() {
    final box = medicalBox;
    if (box == null) return null;

    final data = box.get(_medicalKey);
    debugPrint('READING MEDICAL: $data');
    return data;
  }

  Future<void> clearMedicalInfo() async {
    final box = medicalBox;
    if (box == null) return;
    await box.delete(_medicalKey);
  }
}