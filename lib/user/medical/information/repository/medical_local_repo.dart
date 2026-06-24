import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalLocalRepo {
  static const _medicalKey = 'medical_info';

  Box<MedicalModel> get medicalBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box<MedicalModel>('medical_info_box_$userId');
  }

  Future<void> saveMedicalInfo(MedicalModel medicalInfo) async {
    debugPrint('SAVING MEDICAL TO HIVE');
    await medicalBox.put(_medicalKey, medicalInfo);
    debugPrint('MEDICAL SAVED TO HIVE');
  }

  MedicalModel? getMedicalInfo() {
    final data = medicalBox.get(_medicalKey);
    debugPrint('READING MEDICAL: $data');
    return data;
  }

  Future<void> clearMedicalInfo() async {
    await medicalBox.delete(_medicalKey);
  }
}