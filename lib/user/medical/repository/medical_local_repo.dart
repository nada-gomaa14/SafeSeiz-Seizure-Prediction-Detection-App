import 'package:hive/hive.dart';
import 'package:safeseiz/user/medical/models/medical_model.dart';

class MedicalLocalRepo {

  Future<Box<MedicalModel>> get medicalBox async {
    if (!Hive.isBoxOpen('medical_info_box')) {
      return await Hive.openBox<MedicalModel>('medical_info_box');
    }
    return Hive.box<MedicalModel>('medical_info_box');
  }

  Future<void> saveMedicalInfo(String userId, MedicalModel medicalInfo) async {
    final box = await medicalBox;
    await box.put('medical_$userId', medicalInfo);
  }

  Future<MedicalModel?> getMedicalInfo(String userId) async {
    final box = await medicalBox;
    return box.get('medical_$userId');
  }

  Future<void> clearMedicalInfo(String userId) async {
    final box = await medicalBox;
    await box.delete('medical_$userId');
  }

  Future<void> clearLocalData() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  }
}