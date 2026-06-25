import 'package:hive/hive.dart';
import 'package:safeseiz/user/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileLocalRepo {
  static const _profileKey = 'profile';

  Box<ProfileModel> get profileBox {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return Hive.box<ProfileModel>('profile_box_$userId');
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await profileBox.put(_profileKey, profile);
  }

  ProfileModel? getProfile() {
    return profileBox.get(_profileKey);
  }

  Future<void> clearProfile() async {
    await profileBox.delete(_profileKey);
  }
}