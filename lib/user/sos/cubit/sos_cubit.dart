import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:safeseiz/user/sos/cubit/sos_states.dart';
import 'package:safeseiz/user/sos/service/sos_service.dart';

class SOSCubit extends Cubit<SOSStates> {
  final SensorsCubit sensorsCubit;

  SOSCubit(this.sensorsCubit) : super(SOSLoadedState(
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
  int secondsRemaining = 5;
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

  // Track the seizure ID and time that triggered the current SOS
  String? currentSeizureId;
  DateTime? currentSeizureTime;

  // Start Countdown
  Future<void> startCountdown({required List<EmergencyContactsModel> contacts, required String patientName, String? seizureId, DateTime? seizureTime}) async {
    if (isSending) return;

    final hasPermission = await sosService.requestSMSPermission();

    if (!hasPermission) {
      emit(SOSErrorState('SMS permission denied.'));
      return;
    }

    // Store seizure context for false alarm labeling
    currentSeizureId = seizureId;
    currentSeizureTime = seizureTime ?? DateTime.now();

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

  // Cancel Alert — label as false alarm if AI triggered
  void cancelAlert() {
    countdownTimer?.cancel();
    countdownTimer = null;
    countdownStarted = false;
    alertCancelled = true;
    isSending = false;

    // Label sensor readings as false alarm if this was AI detected
    if (currentSeizureId != null) {
      sensorsCubit.labelFalseAlarmReadings(
        alarmTime: currentSeizureTime ?? DateTime.now(),
        seizureId: currentSeizureId!,
      );
      currentSeizureId = null;
      currentSeizureTime = null;
    }

    emitLoadedState();
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
  Future<void> sendAlert({required List<EmergencyContactsModel> contacts, required String patientName, bool isSeizure = true}) async {    
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

      final message = buildSOSMessage(patientName: patientName, isSeizure: isSeizure);
      debugPrint('Alert: $message');

      final phones = contacts.map((c) => c.phone).toList();

      // Re-check cancellation right before sending
      if (alertCancelled) {
        isSending = false;
        if (isClosed) return;
        emitLoadedState();
        return;
      }

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

    currentSeizureId = null;
    currentSeizureTime = null;

    emitLoadedState();
  }

  // Build Message
  String buildSOSMessage({required String patientName, bool isSeizure = true}) {
    final time = DateFormat('h:mm a').format(DateTime.now());

    final String alertLabel = isSeizure
      ? 'is having a seizure and needs immediate assistance'
      : 'is showing pre-seizure warning signs and may need attention soon';

    if (currentPosition == null) {
      return '$patientName $alertLabel at $time. Location unavailable.';
    }

    String location = '${currentPosition!.latitude},${currentPosition!.longitude}';
    return '$patientName $alertLabel at $time. Find the location here: goo.gl/maps?q=$location';
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
