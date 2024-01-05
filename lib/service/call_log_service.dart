import 'package:call_log/call_log.dart';
import 'package:call_manager_app/Model/call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogService {
  static List<CallLogModel> _callLogs = [];
  static bool _isCallLogPermissionGranted = false;
  bool _isCallLogLoaded = false;
  var now = DateTime.now();

  static List<CallLogModel> get getCallLogs {
    return _callLogs;
  }

  static bool get isCallLogPermissionGranted {
    return _isCallLogPermissionGranted;
  }

  Future<bool> fetchCallLog() async {
    if (!_isCallLogPermissionGranted) {
      await _requestContactPermission();
    } else {
      await _getAllCallLog();
    }
    return _isCallLogLoaded;
  }

  Future<void> _getAllCallLog() async {
    int from = now.subtract(const Duration(days: 60)).millisecondsSinceEpoch;
    // int to = now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    if (_isCallLogPermissionGranted) {
      var callLogs = await CallLog.query(dateFrom: from);

      _callLogs = callLogs.toList().map((e) {
        Color callColor;
        IconData callIcon;

        String name = e.name ?? "Unknown";
        if (name == "") name = "Unknown";
        String phoneNumber = e.number ?? "Unknown";
        String phoneAccountId = e.phoneAccountId ?? "Unknown";
        String callType = e.callType.toString();
        switch (e.callType) {
          case CallType.incoming:
            callType = "Incoming";
            callColor = Colors.blue;
            callIcon = Icons.call_received;

          case CallType.outgoing:
            callType = "Outgoing";
            callColor = Colors.green;
            callIcon = Icons.call_made;
          case CallType.missed:
            callType = "Missed";
            callColor = Colors.red;
            callIcon = Icons.call_missed;
          case CallType.voiceMail:
            callType = "VoiceMail";
            callColor = Colors.blue;
            callIcon = Icons.voicemail;
          case CallType.rejected:
            callType = "Rejected";
            callColor = Colors.red;
            callIcon = Icons.call_received;
          case CallType.blocked:
            callType = "Blocked";
            callColor = Colors.black;
            callIcon = Icons.block;
          case CallType.wifiIncoming:
            callType = "WifiIncoming";
            callColor = Colors.blue;
            callIcon = Icons.wifi;
          case CallType.wifiOutgoing:
            callType = "WifiOutgoing";
            callColor = Colors.green;
            callIcon = Icons.wifi;
          default:
            callType = "Unknown";
            callColor = Colors.grey;
            callIcon = Icons.call;
        }
        int duration = e.duration ?? 0;
        String sim = e.simDisplayName ?? "Unknow";
        int timestamp = e.timestamp ?? 1;
        String formattedDate = DateFormat.yMMMEd()
            .format(DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000));

        return CallLogModel(
            name: name,
            phoneNumber: phoneNumber,
            phoneAccountId: phoneAccountId,
            callType: callType,
            duration: duration,
            sim: sim,
            timestamp: timestamp,
            formattedDate: formattedDate,
            callColor: callColor,
            callIcon: callIcon);
      }).toList();

      // print(contacts);
    }
    _isCallLogLoaded = true;
  }

  Future<void> _requestContactPermission() async {
    final status = await Permission.phone.request();
    _isCallLogPermissionGranted = status == PermissionStatus.granted;
    if (_isCallLogPermissionGranted) {
      await _getAllCallLog();
    }
  }
}
