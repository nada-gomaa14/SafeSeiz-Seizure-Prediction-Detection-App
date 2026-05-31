import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSService {
  static const _channel = MethodChannel('com.example.safeseiz/sms');

  /// Send SOS to multiple contacts at once
  Future<bool> sendSOS({
    required List<String> phones,
    required String message,
  }) async {
    if (phones.isEmpty) {
      debugPrint('No recipients provided');
      return false;
    }

    try {
      if (Platform.isAndroid) {
        debugPrint('Sending SMS to ${phones.length} contacts: $phones');

        final result = await _channel.invokeMethod<bool>('sendSMS', {
          'phones': phones,
          'message': message,
        });

        debugPrint('sendSMS completed: $result');
        return result ?? false;

      } else if (Platform.isIOS) {
        // iOS can't send silently — opens Messages app
        // Send to first contact only (iOS limitation)
        final encodedMessage = Uri.encodeComponent(message);
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phones.first,
          query: 'body=$encodedMessage',
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
      return false;

    } on PlatformException catch (e) {
      debugPrint('SMS PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('SMS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> requestSMSPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.sms.request();
    debugPrint('SMS Permission: $status');
    return status.isGranted;
  }
}