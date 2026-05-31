
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';

abstract class EmergencyContactsStates {}

class EmergencyContactsInitialState extends EmergencyContactsStates {}
class EmergencyContactsLoadingState extends EmergencyContactsStates {}
class EmergencyContactsSuccessState extends EmergencyContactsStates {}

class EmergencyContactsLoadedState extends EmergencyContactsStates {
  final List<EmergencyContactsModel> contacts;
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
