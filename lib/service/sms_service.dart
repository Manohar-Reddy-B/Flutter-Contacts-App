import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsService {
  SmsQuery query = SmsQuery();

  Future<List<SmsMessage>> getAllSms() async {
    List<SmsMessage> messages = await query.getAllSms;
    return messages;
  }
}
