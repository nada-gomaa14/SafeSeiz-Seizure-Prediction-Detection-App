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

  Future<void> deleteSeizure({required String userId, required String seizureId}) async {
    final seizures = getSeizures(userId);

    seizures.removeWhere((seizure) => seizure.id == seizureId);

    await saveSeizures(userId, seizures);
  }

  Future<void> clearSeizures(String userId) async {
    await seizuresBox.delete(userId);
  }
}