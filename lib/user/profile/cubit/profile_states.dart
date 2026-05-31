import 'package:safeseiz/user/profile/model/profile_model.dart';

abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}
class ProfileUpdateState extends ProfileStates {}
class ProfileLoadingState extends ProfileStates {}
class ProfileSuccessState extends ProfileStates {}

class ProfileLoadedState extends ProfileStates {
  final ProfileModel profile;

  ProfileLoadedState(this.profile);
}

class ProfileErrorState extends ProfileStates {
  final String error;

  ProfileErrorState({required this.error});
}