import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/user/contact/models/emergency_contact_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyContactsLocalRepo {
  static const _contactsKey = 'contacts';

  Box<List> get contactsBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box<List>('emergency_contacts_box_$userId');
  }

  Future<void> saveEmergencyContacts(List<EmergencyContactModel> contacts) async {
    debugPrint('SAVING CONTACT TO HIVE');
    await contactsBox.put(_contactsKey, contacts);
    debugPrint('CONTACT SAVED TO HIVE');
  }

  List<EmergencyContactModel>? getEmergencyContacts() {
    final data = contactsBox.get(_contactsKey);
    debugPrint('READING CONTACTS: ${data?.length}');
    return data?.cast<EmergencyContactModel>();
  }

  Future<void> clearEmergencyContacts() async {
    await contactsBox.delete(_contactsKey);
  }
}