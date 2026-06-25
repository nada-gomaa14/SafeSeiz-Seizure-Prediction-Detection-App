import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive_manager.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';

class SeizureLocalRepo {
  static const _seizuresKey = 'seizures';

  Box? get seizuresBox {
    final userId = HiveManager.currentUserId;

    if (userId == null) return null;

    final boxName = 'seizures_box_$userId';
    if (!Hive.isBoxOpen(boxName)){
      return null;
    }

    return Hive.box(boxName);
  }

  Future<void> saveSeizures(List<SeizureModel> seizures) async {
    final box = seizuresBox;
    if (box == null) return;

    debugPrint('SAVING SEIZURE TO HIVE');
    await box.put(_seizuresKey, seizures);
    debugPrint('SEIZURE SAVED TO HIVE');
  }

  List<SeizureModel> getSeizures() {
    final box = seizuresBox;

    if (box == null) {
      return [];
    }

    final data = box.get(_seizuresKey);
    debugPrint('READING SEIZURE: $data');
    
    return data == null
      ? []
      : data.cast<SeizureModel>();
  }

  List<SeizureModel> getUnsyncedSeizures() {
    final data = getSeizures().where((s) => !s.isSynced).toList();
    debugPrint('READING SEIZURE: $data');
    return data;
  }

  Future<void> markAsSynced(String seizureId) async {
    final seizures = getSeizures();

    final index = seizures.indexWhere((s) => s.id == seizureId);
    if (index != -1) {
      seizures[index] = seizures[index].copyWith(isSynced: true);

      await saveSeizures(seizures);
    }
  }

  Future<void> purgeOldSeizures() async {
    final seizures = getSeizures();

    final cutoff = DateTime.now().subtract(const Duration(days: 7));

    final filtered = seizures.where((s) => s.seizureDateTime.isAfter(cutoff)).toList();

    await saveSeizures(filtered);
  }

  Future<void> clearSeizures() async {
    final box = seizuresBox;
    if (box == null) return; 
    await box.delete(_seizuresKey);
  }
}