import 'package:call_manager_app/service/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Sms extends StatefulWidget {
  final String text;

  const Sms({super.key, required this.text});

  @override
  State<Sms> createState() => _SmsState();
}

class _SmsState extends State<Sms> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SmsService().getAllSms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text("You dont have any text message"),
          );
        }
        return Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              SmsMessage smsMessage = snapshot.data![index];

              return ListTile(
                onTap: () {
                  //TODO openDetails Screen
                },
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person),
                ),
                title: Text("${smsMessage.address}"),
                subtitle: Text(
                  "${smsMessage.body}",
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: smsMessage.isRead == true
                    ? const Icon(
                        Icons.done_all,
                        color: Colors.blue,
                      )
                    : const Icon(Icons.done),
              );
            },
          ),
        );
      },
    );
  }
}
