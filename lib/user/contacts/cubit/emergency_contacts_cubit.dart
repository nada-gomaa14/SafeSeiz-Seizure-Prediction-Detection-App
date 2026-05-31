import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_states.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/user/contacts/repository/emergency_contacts_local_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';


class EmergencyContactsCubit extends Cubit<EmergencyContactsStates> {

  EmergencyContactsCubit(this.contactsLocalRepo) : super(EmergencyContactsInitialState());
  final EmergencyContactsLocalRepo contactsLocalRepo;
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  List<EmergencyContactsModel> contacts = [];
  bool get hasMinimumContacts => contacts.length >= 2;

  // Phone Number Validation
  bool isValidEgyptianPhone(String phone) {
    return RegExp(r'^01[0-9]{9}$').hasMatch(phone);
  }

  // Phone Number Format
  String formatEgyptianPhone(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (cleaned.startsWith('+2')) return cleaned;
    if (cleaned.startsWith('2')) return '+$cleaned';
    if (cleaned.startsWith('0')) return '+2${cleaned.substring(0)}';
    return '+2$cleaned';
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

    final duplicatePhone = contacts.any((contact) => contact.phone == phone);

    if (duplicatePhone) {
      emit(EmergencyContactsErrorState('Phone number already exists.'));
      return false;
    }

    contacts.add(
      EmergencyContactsModel(
        id: uuid.v4(),
        name: name,
        relationship: relationship,
        phone: formatEgyptianPhone(phone),
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

    final duplicatePhone = contacts.any(
      (contact) => contact.phone == phone && contact.id != id,
    );

    if (duplicatePhone) {
      emit(EmergencyContactsErrorState('Phone number already exists.'));
      return false;
    }

    final index = contacts.indexWhere((contact) => contact.id == id);

    if (index == -1) {
      emit(EmergencyContactsErrorState('Contact not found.'));
      return false;
    }

    contacts[index] = EmergencyContactsModel(
      id: id,
      name: name,
      relationship: relationship,
      phone: formatEgyptianPhone(phone),
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

      await contactsLocalRepo.saveEmergencyContacts(
        user.id,
        List.from(contacts),
      );

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

      final data = contactsLocalRepo.getEmergencyContacts(user.id);
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
        await contactsLocalRepo.clearEmergencyContacts(user.id);
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