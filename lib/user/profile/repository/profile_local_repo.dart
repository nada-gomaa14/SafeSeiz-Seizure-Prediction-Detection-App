import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:safeseiz/services/hive_manager.dart';
import 'package:safeseiz/user/profile/models/profile_model.dart';

class ProfileLocalRepo {
  static const _profileKey = 'profile';

  Box<ProfileModel>? get profileBox {
    final userId = HiveManager.currentUserId;
    if (userId == null) return null;

    final boxName = 'profile_box_$userId';
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('Profile box is not open: $boxName');
      return null;
    }

    return Hive.box<ProfileModel>(boxName);
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final box = profileBox;
    if (box == null) return;

    debugPrint('SAVING PROFILE TO HIVE');
    await box.put(_profileKey, profile);
    debugPrint('PROFILE SAVED TO HIVE');
  }

  ProfileModel? getProfile() {
    final box = profileBox;
    if (box == null) return null;

    return box.get(_profileKey);
  }

  Future<void> clearProfile() async {
    final box = profileBox;
    if (box == null) return;

    await box.delete(_profileKey);
  }
}