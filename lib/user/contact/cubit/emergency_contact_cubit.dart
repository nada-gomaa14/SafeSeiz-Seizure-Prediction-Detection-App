import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/user/contact/cubit/emergency_contact_states.dart';
import 'package:safeseiz/user/contact/models/emergency_contact_model.dart';
import 'package:safeseiz/user/contact/repository/emergency_contact_local_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';


class EmergencyContactsCubit extends Cubit<EmergencyContactsStates> {

  EmergencyContactsCubit(this.contactsLocalRepo) : super(EmergencyContactsInitialState());
  final EmergencyContactsLocalRepo contactsLocalRepo;
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  List<EmergencyContactModel> contacts = [];
  bool get hasMinimumContacts => contacts.length >= 2;

  // Phone Number Validation
  bool isValidEgyptianPhone(String phone) {
    return RegExp(r'^1[0125][0-9]{8}$').hasMatch(phone);
  }

  // Phone Number Format
  String formatEgyptianPhone(String phone) {
    return '+20$phone';
  }

  // Add Contact
  bool addContact({required String name, required String relationship, required String phone}) {
    name = name.trim();
    relationship = relationship.trim();
    phone = phone.trim();
    
    if (name.isEmpty || relationship.isEmpty || phone.isEmpty) {
      emit(EmergencyContactsErrorState('Please fill all fields.'));
      return false;
    }

    if (!isValidEgyptianPhone(phone)) {
      emit(EmergencyContactsErrorState('Please enter a valid phone number.'));
      return false;
    }

    final formattedPhone = formatEgyptianPhone(phone);
    final duplicatePhone = contacts.any((contact) => contact.phone == formattedPhone);

    if (duplicatePhone) {
      emit(EmergencyContactsErrorState('Phone number already exists.'));
      return false;
    }

    contacts.add(
      EmergencyContactModel(
        id: uuid.v4(),
        name: name,
        relationship: relationship,
        phone: formattedPhone,
      ),
    );

    emit(EmergencyContactsLoadedState(contacts: List.from(contacts), hasMinimumContacts: hasMinimumContacts));
    return true;
  }

  // Remove Contact
  void removeContact(String contactId) {
    contacts.removeWhere((contact) => contact.id == contactId);
    emit(EmergencyContactsLoadedState(contacts: List.from(contacts), hasMinimumContacts: hasMinimumContacts));
  }

  // Update Contact
  bool updateContact({required String id, required String name, required String relationship, required String phone}) {
    name = name.trim();
    relationship = relationship.trim();
    phone = phone.trim();

    if (name.isEmpty || relationship.isEmpty || phone.isEmpty) {
      emit(EmergencyContactsErrorState('Please fill all fields.'));
      return false;
    }

    if (!isValidEgyptianPhone(phone)) {
      emit(EmergencyContactsErrorState('Please enter a valid phone number.'));
      return false;
    }

    final formattedPhone = formatEgyptianPhone(phone);
    final duplicatePhone = contacts.any((contact) => contact.phone == formattedPhone && contact.id != id);

    if (duplicatePhone) {
      emit(EmergencyContactsErrorState('Phone number already exists.'));
      return false;
    }

    final index = contacts.indexWhere((contact) => contact.id == id);

    if (index == -1) {
      emit(EmergencyContactsErrorState('Contact not found.'));
      return false;
    }

    contacts[index] = EmergencyContactModel(
      id: id,
      name: name,
      relationship: relationship,
      phone: formattedPhone,
    );

    emit(EmergencyContactsLoadedState(contacts: List.from(contacts), hasMinimumContacts: hasMinimumContacts));
    return true;
  }

  // Save Emergency Contacts
  Future<bool> saveEmergencyContacts() async {
    emit(EmergencyContactsLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(EmergencyContactsErrorState('User not logged in.'));
        return false;
      }

      await contactsLocalRepo.saveEmergencyContacts(List.from(contacts));

      emit(EmergencyContactsSuccessState());
      return true;

    } catch (e, stackTrace) {
      debugPrint('Emergency contacts save error: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(EmergencyContactsErrorState('Failed to save emergency contacts.'));
      return false;
    }
  }

  // Fetch Emergency Contacts
  Future<void> fetchEmergencyContacts() async {
    emit(EmergencyContactsLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        emit(EmergencyContactsErrorState('User not logged in.'));
        return;
      }

      final data = contactsLocalRepo.getEmergencyContacts();

      debugPrint(
        'CONTACTS FETCH => '
        'user=${user.id}, '
        'count=${data?.length ?? 0}',
      );

      contacts = data ?? [];

      emit(EmergencyContactsLoadedState(contacts: List.from(contacts), hasMinimumContacts: hasMinimumContacts));

    } catch (e) {
      emit(EmergencyContactsErrorState('Failed to load emergency contacts.'));
    }
  }

  // Clear Emergency Contacts
  Future<void> clearEmergencyContacts() async {
    emit(EmergencyContactsLoadingState());

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await contactsLocalRepo.clearEmergencyContacts();
      }

      contacts.clear();

      emit(EmergencyContactsInitialState());

    } catch (e) {
      emit(EmergencyContactsErrorState('Failed to clear emergency contacts.'));
    }
  }

  // Clear Temporary In-Memory Variables
  void resetState() {
    contacts = [];
    emit(EmergencyContactsInitialState());
  }

  // Dislay Error
  void showError(String message) {
    emit(EmergencyContactsErrorState(message));
  }
}