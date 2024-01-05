import 'package:flutter/material.dart';

class CallLogModel {
  final String name;
  final String phoneNumber;
  final String phoneAccountId;
  final String callType;
  final int duration;
  final String sim;
  final int timestamp;
  final String formattedDate;
  final Color callColor;
  final IconData callIcon;

  CallLogModel(
      {required this.name,
      required this.phoneNumber,
      required this.phoneAccountId,
      required this.callType,
      required this.duration,
      required this.sim,
      required this.timestamp,
      required this.formattedDate,
      required this.callColor,
      required this.callIcon});
}
