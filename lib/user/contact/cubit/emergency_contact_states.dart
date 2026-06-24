
import 'package:safeseiz/user/contact/models/emergency_contact_model.dart';

abstract class EmergencyContactsStates {}

class EmergencyContactsInitialState extends EmergencyContactsStates {}
class EmergencyContactsLoadingState extends EmergencyContactsStates {}
class EmergencyContactsSuccessState extends EmergencyContactsStates {}

class EmergencyContactsLoadedState extends EmergencyContactsStates {
  final List<EmergencyContactModel> contacts;
  final bool hasMinimumContacts;

  EmergencyContactsLoadedState({
    required this.contacts,
    required this.hasMinimumContacts,
  });
}

class EmergencyContactsErrorState extends EmergencyContactsStates {
  final String message;
  EmergencyContactsErrorState(this.message);
}
