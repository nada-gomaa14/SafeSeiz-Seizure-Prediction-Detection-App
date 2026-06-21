import 'package:hive/hive.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';

class SeizureLocalRepo {
  final Box seizuresBox = Hive.box('seizures_box');

  Future<void> saveSeizures(String userId, List<SeizureModel> seizures) async {
    await seizuresBox.put(userId, seizures);
  }

  List<SeizureModel> getSeizures(String userId) {
    final data = seizuresBox.get(userId);
    if (data == null) return [];
    return List<SeizureModel>.from(data);
  }

  List<SeizureModel> getUnsyncedSeizures(String userId) {
    return getSeizures(userId).where((s) => !s.isSynced).toList();
  }

  Future<void> markAsSynced(String userId, String seizureId) async {
    final seizures = getSeizures(userId);
    final index = seizures.indexWhere((s) => s.id == seizureId);
    if (index != -1) {
      seizures[index] = seizures[index].copyWith(isSynced: true);
      await saveSeizures(userId, seizures);
    }
  }

  Future<void> clearSeizures(String userId) async {
    await seizuresBox.delete(userId);
  }
}