import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/user/sos/cubit/sos_states.dart';
import 'package:safeseiz/user/sos/service/sos_service.dart';

class SOSCubit extends Cubit<SOSStates> {
  SOSCubit() : super(SOSLoadedState(
    secondsRemaining: 5,
    countdownStarted: false,
    alertSent: false,
    alertCancelled: false,
    isSending: false,
    locationText: 'Fetching location...',
    notifiedContacts: {},
    afterSeizureChecklist: {
      'Stay lying on your side' : false,
      'Note the duration': false,
      'Log this seizure when able': false,
    }
  ));

  // Countdown
  Timer? countdownTimer;
  int secondsRemaining = 10;
  bool countdownStarted = false;

  // SOS
  bool alertSent = false;
  bool alertCancelled = false;
  bool isSending = false;
  final SOSService sosService = SOSService();

  // Device Info
  Position? currentPosition;
  String locationText = 'Fetching location...';

  // Track Notified Contacts
  final Map<String, bool> notifiedContacts = {};

  // After Seizure Checklist
  final Map<String, bool> afterSeizureChecklist = {
    'Stay lying on your side': false,
    'Note the duration': false,
    'Log this seizure when able': false,
  };

  // Start Countdown
  Future<void> startCountdown({required List<EmergencyContactsModel> contacts, required String patientName}) async {
    if (isSending) return;

    final hasPermission = await sosService.requestSMSPermission();

    if (!hasPermission) {
      emit(SOSErrorState('SMS permission denied.'));
      return;
    }

    // Reset
    secondsRemaining = 5;
    countdownStarted = true;
    alertCancelled = false;
    alertSent = false;
    isSending = false;

    notifiedContacts.clear();

    for (final contact in contacts) {
      notifiedContacts[contact.phone] = false;
    }

    emitLoadedState();

    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        secondsRemaining--;
        emitLoadedState();

        if (secondsRemaining == 0) {
          timer.cancel();
          countdownTimer = null;

          await sendAlert(contacts: contacts, patientName: patientName);
        }
      },
    );
  }

  // Fetch Location
  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationText = 'Location disabled';

        if (isClosed) return;

        emitLoadedState();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        locationText = 'Location permission denied';
        emitLoadedState();
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        currentPosition = position;

        log('Latitude: ${position.latitude}');
        log('Longitude: ${position.longitude}');

        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationText = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        } else {
          locationText = 'Lat: ${position.latitude.toStringAsFixed(4)}\n''Lng: ${position.longitude.toStringAsFixed(4)}';
        }

        if (isClosed) return;

        emitLoadedState();
      } else {
        locationText = 'Location permission unavailable.';

        if (isClosed) return;

        emitLoadedState();
      }
    } catch (e) {
      locationText = 'Location unavailable';
      if (isClosed) return;
      emitLoadedState();
    }
  }

  // Send Alert
  Future<void> sendAlert({required List<EmergencyContactsModel> contacts, required String patientName}) async {
    if (alertCancelled || isSending) return;

    isSending = true;
    emitLoadedState();

    try {
      final granted = await sosService.requestSMSPermission();

      if (!granted) {
        emit(SOSErrorState('SMS permission denied.'));
        return;
      }

      await fetchLocation();
      if (isClosed) return;

      final message = buildSOSMessage(patientName: patientName);

      debugPrint('Alert: $message');

      final phones = contacts.map((c) => c.phone).toList();

      final success = await sosService.sendSOS(phones: phones, message: message);

       if (isClosed) return;

      // Mark all contacts with the same result
      for (final contact in contacts) {
        notifiedContacts[contact.phone] = success;
      }

      if (!alertCancelled) {
        alertSent = true;
      }
      isSending = false;
      if (isClosed) return;
      emitLoadedState();

    } catch (e) {
      isSending = false;
      if (isClosed) return;

      emit(SOSErrorState('Failed to send SOS alert.'));
      emitLoadedState();
    }
  }

  // Cancel Alert
  void cancelAlert() {
    countdownTimer?.cancel();
    countdownTimer = null;
    countdownStarted = false;
    alertCancelled = true;
    isSending = false;

    emitLoadedState();
  }

  // Checklist
  void toggleChecklist(String key) {
    afterSeizureChecklist[key] = !(afterSeizureChecklist[key] ?? false);
    emitLoadedState();
  }

  // Reset
  void resetSOS() {
    countdownTimer?.cancel();
    countdownTimer = null;
    secondsRemaining = 10;
    countdownStarted = false;

    alertSent = false;
    alertCancelled = false;
    isSending = false;

    currentPosition = null;
    locationText = 'Fetching location...';

    notifiedContacts.clear();
    afterSeizureChecklist.updateAll((key, value) => false);

    emitLoadedState();
  }

  // Build Message
  String buildSOSMessage({required String patientName}) {
    final time = DateFormat('h:mm a').format(DateTime.now());

    if (currentPosition == null) {
      return '$patientName needs immediate assistance at $time. Location unavailable.';
    }

    String location = '${currentPosition!.latitude},${currentPosition!.longitude}';
    return '$patientName needs immediate assistance at $time. Find the location here: goo.gl/maps?q=$location';
  }

  // Emit Loaded State Helper
  void emitLoadedState() {
    emit(SOSLoadedState(
      secondsRemaining: secondsRemaining,
      countdownStarted: countdownStarted,
      alertSent: alertSent,
      alertCancelled: alertCancelled,
      isSending: isSending,
      locationText: locationText,
      notifiedContacts: Map.from(notifiedContacts),
      afterSeizureChecklist:Map.from(afterSeizureChecklist),
    ));
  }

  @override
  Future<void> close() {
    countdownTimer?.cancel();
    return super.close();
  }
}
