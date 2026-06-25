import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive_manager.dart';
import 'package:safeseiz/user/contact/models/emergency_contact_model.dart';

class EmergencyContactsLocalRepo {
  static const _contactsKey = 'contacts';

  Box<List>? get contactsBox {
    final userId = HiveManager.currentUserId;
    if (userId == null) return null;

    final boxName = 'emergency_contacts_box_$userId';
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('Contact box is not open: $boxName');
      return null;
    }

    return Hive.box<List>(boxName);
  }

  Future<void> saveEmergencyContacts(List<EmergencyContactModel> contacts) async {
    final box = contactsBox;
    if (box == null) return;
    
    debugPrint('SAVING CONTACTS TO HIVE');
    await box.put(_contactsKey, contacts);
    debugPrint('CONTACTS SAVED TO HIVE');
  }

  List<EmergencyContactModel>? getEmergencyContacts() {
    final box = contactsBox;
    if (box == null) return null;
    
    final data = box.get(_contactsKey);
    debugPrint('READING CONTACTS: ${data?.length}');
    return data?.cast<EmergencyContactModel>();
  }

  Future<void> clearEmergencyContacts() async {
    final box = contactsBox;
    if (box == null) return;
    
    await box.delete(_contactsKey);
  }
}