import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:call_manager_app/service/call_log_service.dart';
import 'package:call_manager_app/service/contacts_data_service.dart';

import 'package:call_manager_app/ui/home.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late bool contactDataStatus = false,
      callLogDataStatus = false,
      animationEndStatus = false;
  ContactsDataService contactData = ContactsDataService();
  CallLogService callLog = CallLogService();
  late Image image;

  @override
  initState() {
    super.initState();

    image = Image.asset(
      "assets/phone.png",
      width: 200,
      height: 200,
    );

    fetchdata();
  }

  Future<void> fetchdata() async {
    // print("###################FETCH DATA#####################");
    await _fetchdata().whenComplete(() => _navigatetohome());
  }

  // Future<void> fetchdata() async {
  //   await contactData
  //       .fetchContactsDb()
  //       .whenComplete(() => {dataStatus = true, _navigatetohome()});
  // }

  Future<void> _fetchdata() async {
    // print("###########FETCH Contacts####################");
    await contactData.fetchContactsDb().whenComplete(
          () => callLogDataStatus = true,
        );
    // print("###########FETCH CallLOg####################");
    await callLog.fetchCallLog().whenComplete(
          () => contactDataStatus = true,
        );
// print("#######################CALL LOG FETCHED ####################"),
    // print(
    //     "#####################${CallLogData.getCallLogs.length}###########################")

    // await contactData.fetchContactsDb().then((value) async {
    //   await callLog.fetchCallLog().whenComplete(() {
    //     dataStatus = true;
    //   });
    // }).whenComplete(() => _navigatetohome());
  }

  void _navigatetohome() {
    if (!context.mounted) return;
    // print("$datastatus,$animationstatus");
    if (contactDataStatus & callLogDataStatus & animationEndStatus) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 2),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Home(text: "open camera to scan text", index: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(image.image, context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "logo", child: image),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                child: animationEndStatus
                    ? const CircularProgressIndicator()
                    : AnimatedTextKit(
                        animatedTexts: [
                            ScaleAnimatedText(
                              "Call Manager",
                              textStyle: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            ),
                          ],
                        totalRepeatCount: 1,
                        onFinished: () => {
                              setState(
                                () {
                                  // print(
                                  //     "###################animation Completed##############");
                                  animationEndStatus = true;
                                  _navigatetohome();
                                },
                              )
                            }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
