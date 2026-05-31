abstract class SOSStates {}

class SOSLoadedState extends SOSStates {
  final int secondsRemaining;
  final bool countdownStarted;
  final bool alertSent;
  final bool alertCancelled;
  final bool isSending;
  final String locationText;
  final Map<String, bool> notifiedContacts;
  final Map<String, bool> afterSeizureChecklist;

  SOSLoadedState({
    required this.secondsRemaining,
    required this.countdownStarted,
    required this.alertSent,
    required this.alertCancelled,
    required this.isSending,
    required this.locationText,
    required this.notifiedContacts,
    required this.afterSeizureChecklist,
  });
}

class SOSErrorState extends SOSStates {
  final String error;
  SOSErrorState(this.error);
}