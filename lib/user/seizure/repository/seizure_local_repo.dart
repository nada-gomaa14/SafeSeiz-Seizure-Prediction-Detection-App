import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SeizureLocalRepo {
  static const _seizuresKey = 'seizures';

  Box get seizuresBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box('seizures_box_$userId');
  }

  Future<void> saveSeizures(List<SeizureModel> seizures) async {
    debugPrint('SAVING SEIZURE TO HIVE');
    await seizuresBox.put(_seizuresKey, seizures);
    debugPrint('SEIZURE SAVED TO HIVE');
  }

  List<SeizureModel> getSeizures() {
    final data = seizuresBox.get(_seizuresKey);
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
    await seizuresBox.delete(_seizuresKey);
  }
}