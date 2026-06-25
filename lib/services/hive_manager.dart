import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive_encryption_service.dart';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';
import 'package:safeseiz/user/profile/models/profile_model.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';

class HiveManager {
  static String? currentUserId;

  static Future<void> openUserBoxes(String userId) async {
    currentUserId = userId;

    try {
      debugPrint('Opening profile box...');
      final profileBox = 'profile_box_$userId';

      if (!Hive.isBoxOpen(profileBox)) {
        final profileKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'profile_box');
        await Hive.openBox<ProfileModel>(profileBox, encryptionCipher: HiveAesCipher(profileKey));
      }

      debugPrint('Profile box opened');

    } catch (e, stack) {
      debugPrint('Profile box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }

    try {
      debugPrint('Opening medical box...');

      final medicalBox = 'medical_info_box_$userId';
      if (!Hive.isBoxOpen(medicalBox)) {
        final medicalKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'medical_info_box');
        await Hive.openBox<MedicalModel>(medicalBox, encryptionCipher: HiveAesCipher(medicalKey));
      }

      debugPrint('Medical box opened');
    } catch (e, stack) {
      debugPrint('Medical box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    
    
    try {
      debugPrint('Opening contacts box...');

      final contactsBox = 'emergency_contacts_box_$userId';
      if (!Hive.isBoxOpen(contactsBox)) {
        final contactsKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'emergency_contacts_box');
        await Hive.openBox<List>(contactsBox, encryptionCipher: HiveAesCipher(contactsKey));
      }

      debugPrint('Contacts box opened');
    } catch (e, stack) {
      debugPrint('Contacts box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    
    try {
      debugPrint('Opening medication box...');

      final medicationBox = 'medication_box_$userId';
      if (!Hive.isBoxOpen(medicationBox)) {
        final medicationKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'medication_box');
        await Hive.openBox(medicationBox, encryptionCipher: HiveAesCipher(medicationKey));
      }

      debugPrint('Medication box opened');
    } catch (e, stack) {
      debugPrint('Medication box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    
    try {
      debugPrint('Opening seizures box...');

      final seizuresBox = 'seizures_box_$userId';
      if (!Hive.isBoxOpen(seizuresBox)) {
        final seizuresKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'seizures_box');
        await Hive.openBox(seizuresBox, encryptionCipher: HiveAesCipher(seizuresKey));
      }

      debugPrint('Seizures box opened');
    } catch (e, stack) {
      debugPrint('Seizures box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    
    try {
      debugPrint('Opening sensors box...');
      
      final sensorsBox = 'sensors_box_$userId';
      if (!Hive.isBoxOpen(sensorsBox)) {
        final sensorsKey = await HiveEncryptionService.getKey(userId: userId, boxName: 'sensors_box');
        await Hive.openBox<SensorReadingModel>(sensorsBox, encryptionCipher: HiveAesCipher(sensorsKey));  
      }

      debugPrint('Sensors box opened');
    } catch (e, stack) {
      debugPrint('Sensors box failed: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  static Future<void> closeUserBoxes(String userId) async {
    final medicalBox = 'medical_info_box_$userId';
    if (Hive.isBoxOpen(medicalBox)) {
      await Hive.box<MedicalModel>(medicalBox).close();
    }

    final contactsBox = 'emergency_contacts_box_$userId';
    if (Hive.isBoxOpen(contactsBox)) {
      await Hive.box<List>(contactsBox).close();
    }

    final medicationBox = 'medication_box_$userId';
    if (Hive.isBoxOpen(medicationBox)) {
      await Hive.box(medicationBox).close();
    }

    final seizuresBox = 'seizures_box_$userId';
    if (Hive.isBoxOpen(seizuresBox)) {
      await Hive.box(seizuresBox).close();
    }

    final sensorsBox = 'sensors_box_$userId';
    if (Hive.isBoxOpen(sensorsBox)) {
      await Hive.box<SensorReadingModel>(sensorsBox).close();
    }

    final profileBox = 'profile_box_$userId';

    if (Hive.isBoxOpen(profileBox)) {
      await Hive.box<ProfileModel>(profileBox).close();
    }

    currentUserId = null;
  }
}