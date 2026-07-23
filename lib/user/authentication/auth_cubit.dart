import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safeseiz/core/app_exceptions.dart';
import 'package:safeseiz/services/hive/hive_manager.dart';
import 'package:safeseiz/services/watch_service.dart';
import 'package:safeseiz/user/contact/cubit/emergency_contact_cubit.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeseiz/user/authentication/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final ProfileCubit profileCubit;
  final MedicalCubit medicalCubit;
  final EmergencyContactsCubit contactsCubit;
  final MedicationCubit medicationCubit;
  final SeizureCubit seizureCubit;
  final SensorsCubit sensorsCubit;

  String? _currentUserId;
  
  final supabase = Supabase.instance.client;
  final WatchService watchService;

  StreamSubscription<AuthState>? authSubscription;

  AuthCubit(this.profileCubit, this.medicalCubit, this.contactsCubit, this.medicationCubit, this.seizureCubit, this.sensorsCubit, this.watchService) : super(AuthInitialState()){
    if (supabase.auth.currentSession != null) {
      validateSession();
    } else {
      emit(AuthUnauthenticatedState());
    }

    authSubscription = supabase.auth.onAuthStateChange.listen((data) async{
      debugPrint(
        'AUTH EVENT => ${data.event}, '
        'session=${data.session != null}',
      );

      if (data.event == AuthChangeEvent.tokenRefreshed) return;

      if (data.event == AuthChangeEvent.initialSession) {
        return;
      }

      final session = data.session;

      if (session == null) {
        if (_currentUserId != null) {
          await HiveManager.closeUserBoxes(_currentUserId!);
          _currentUserId = null;
        }
        emit(AuthUnauthenticatedState());
        return;
      }

      try {
        emit(AuthLoadingState());

        await _loadUserData(session.user.id);

        if (state is! AuthAuthenticatedState) {
          emit(AuthAuthenticatedState());
        }
      } catch (e) {
        debugPrint('Auth state change error: $e');
        emit(AuthUnauthenticatedState());  
      }
    });
  }

  bool isObscure = true;

  // Load Data Helper
  Future<void> _loadUserData(String userId) async {
    _currentUserId = userId;

    await HiveManager.openUserBoxes(userId);

    try {
      await profileCubit.fetchProfile(userId);
    } catch (e) {
      debugPrint('Profile load failed: $e');
    }

    try {
      await medicalCubit.fetchMedicalInfo();
    } catch (e) {
      debugPrint('Medical load failed: $e');
    }

    try {
      await contactsCubit.fetchEmergencyContacts();
    } catch (e) {
      debugPrint('Contacts load failed: $e');
    }
    
    try {
      await medicationCubit.fetchMedications();
    } catch (e) {
      debugPrint('Medication load failed: $e');
    }

    try {
      await seizureCubit.loadSeizures();
    } catch (e) {
      debugPrint('Seizure load failed: $e');
    }

    try {
      await watchService.startListening();
    } catch (e) {
      debugPrint('Watch service failed: $e');
    }
    
  }

  // Profile Creation Delay
  Future<bool> waitForProfile(String userId) async {
    for (int i = 0; i < 10; i++) {
      final profile = await supabase.from('profiles').select('id').eq('id', userId).maybeSingle();

      if (profile != null) {
        debugPrint('Profile found after ${i + 1} attempts');
        return true;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return false;
  }

  // Password 
  void changePasswordVisibility() {
    isObscure = !isObscure;
    emit(PasswordVisibilityState());
  }

  void resetPasswordVisibility() {
    isObscure = true;
    emit(PasswordVisibilityState());
  }

  void showPasswordStrength(String value) {
    final result = passwordStrength(value);

    emit(PasswordStrengthState(
      password: value,
      strength: result.$1,
      strengthLabel: result.$2,
    ));
  }

  (int, String) passwordStrength(String value) {
    if (value.isEmpty) {
      return (0, '');
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);

    int score = 0;

    if (value.length >= 8) score++;
    if (hasUpper && hasLower) score++;
    if (hasDigit) score++;
    if (hasSymbol) score++;

    if (score <= 1) return (1, 'Fair');
    if (score == 2) return (2, 'Good');
    if (score == 3) return (3, 'Strong');
    return (4, 'Very strong');
  }

  // User Registration
  Future<void> register({required String email, required String password, required String username}) async {
    emit(RegisterLoadingState());

    profileCubit.resetState();
    medicalCubit.resetState();
    contactsCubit.resetState();
    medicationCubit.resetState();
    seizureCubit.resetState();

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw AppException('Registration failed');
      }

      if (response.session == null) {
        emit(RegisterErrorState(error: 'Account already exists.'));
        return;
      }

      await retryCreateProfile(
        userID: user.id,
        email: user.email ?? email,
      );

      if (!await waitForProfile(user.id)) {
        emit(RegisterErrorState(error: 'Profile creation failed.'));
        return;
      }  

      await _loadUserData(user.id);

      emit(RegisterSuccessState());
      emit(AuthAuthenticatedState());

    } on AuthException catch (e) {
      if (e.statusCode == '422' && e.message.toLowerCase().contains('already')){
        emit(RegisterErrorState(error: 'Account already exists.'));
      } else {
        emit(RegisterErrorState(error: e.message));
      }
    } on AppException catch (e) {
      emit(RegisterErrorState(error: e.message));
    } catch (e) {
      emit(RegisterErrorState(error: 'Registration failed. Please try again.'));
    }
  }

  // Retry Profile Creation
  Future<void> retryCreateProfile({required String userID, required String email}) async {
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        await profileCubit.createProfile(
          userID: userID,
          email: email,
        );
        return; 
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow; 
        }

        await Future.delayed(const Duration(seconds: 1)); 
      }
    }
  }

  // User Login
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());

    try {
      final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw AppException('Login failed.');
    }

    } on AuthException catch (e) {
      final message = e.message.toLowerCase();

      if (message.contains('invalid login credentials')){
        emit(LoginErrorState(error: 'Incorrect email or password.'));
      } else {
        emit(LoginErrorState(error: e.message));
      }
    } catch (e) {
      emit(LoginErrorState(error: 'Login failed. Please try again.'));
    }
  }

  // User Logout
  Future<void> logout() async {
    emit(LogoutLoadingState());

    try {
      profileCubit.resetState();
      medicalCubit.resetState();
      contactsCubit.resetState();
      medicationCubit.resetState();
      seizureCubit.resetState();

      await supabase.auth.signOut();

    } catch (e) {
      emit(LogoutErrorState(error: 'Log out failed. Please try again.'));
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  @override
  Future<void> close() {
    authSubscription?.cancel();
    return super.close();
  }

  // Validate Session
  Future<void> validateSession() async {
    emit(AuthLoadingState());

    final currentUser = supabase.auth.currentUser;
    debugPrint('Current user: ${currentUser?.id}');

    // No session
    if (currentUser == null) {
      emit(AuthUnauthenticatedState());
      return;
    }

    try {
      // User valid
      await _loadUserData(currentUser.id);

      emit(AuthAuthenticatedState());

    } catch (e) {
      debugPrint('Session validation error: $e');
      emit(AuthUnauthenticatedState());
    }
  }

  // Handle Deleted Account
  Future<void> handleDeletedAccount() async {
    profileCubit.resetState();
    await medicalCubit.clearMedicalInfo();
    await contactsCubit.clearEmergencyContacts();
    await medicationCubit.clearMedications();
    await seizureCubit.clearSeizures();
    await sensorsCubit.clearReadings();

    final user = supabase.auth.currentUser;
    if (user != null) {
      await HiveManager.closeUserBoxes(user.id);
    }
    
    await supabase.auth.signOut();

    emit(AuthUnauthenticatedState());
  }

  // Request Account Deletion
  Future<void> requestAccountDeletion() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw AppException('No authenticated user.');
      }

      await supabase.from('account_deletion_requests').insert({
        'user_id': user.id,
        'email': user.email,
      });

    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate')) {
        throw AppException('You already have a pending deletion request.');
      }

      throw AppException(e.message);

    } catch (e) {
      throw AppException('Failed to submit deletion request.');
    }
  }

  // Check Account Deletion Request
  Future<bool> hasPendingDeletionRequest() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return false;

      final response = await supabase
        .from('account_deletion_requests')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

      return response != null;

    } catch (e) {
      return false;
    }
  }
}