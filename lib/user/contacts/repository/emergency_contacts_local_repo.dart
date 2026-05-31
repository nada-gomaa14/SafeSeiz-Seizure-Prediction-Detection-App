import 'package:hive/hive.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';

class EmergencyContactsLocalRepo {

  final Box contactsBox = Hive.box('emergency_contacts_box');

  Future<void> saveEmergencyContacts(String userId, List<EmergencyContactsModel> contacts) async {
    await contactsBox.put(userId, contacts);
  }

  List<EmergencyContactsModel>? getEmergencyContacts(String userId) {
    final data = contactsBox.get(userId);
    if (data == null) return null;
    return data.cast<EmergencyContactsModel>();
  }

  Future<void> clearEmergencyContacts(String userId) async {
    await contactsBox.delete(userId);
  }
}