import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSService {
  final Telephony telephony = Telephony.instance;

  Future<bool> sendSOS({required String phone, required String message}) async {
    try {
      if (Platform.isAndroid) {
        await telephony.sendSms(to: phone, message: message);
        return true;
      
      } else if (Platform.isIOS) {
        final encodedMessage = Uri.encodeComponent(message);
        final Uri smsUri = Uri(scheme: 'sms', path: phone, query: 'body=$encodedMessage');
        
        if (await canLaunchUrl(smsUri)){
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestSMSPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final permission = await telephony.requestPhoneAndSmsPermissions;

    return permission ?? false;
  }
}