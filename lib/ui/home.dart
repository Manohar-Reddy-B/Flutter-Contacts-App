import 'package:call_manager_app/service/contacts_data_service.dart';
import 'package:call_manager_app/widgets/camera_tab.dart';
import 'package:call_manager_app/widgets/contacts_tab.dart';
import 'package:call_manager_app/widgets/sms_tab.dart';
import 'package:call_manager_app/widgets/recents_tab.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String text;
  final int index;

  const Home({super.key, required this.text, required this.index});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ContactsDataService contactData = ContactsDataService();
  @override
  void initState() {
    super.initState();
    // print("################HOME###################");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        initialIndex: widget.index,
        child: Scaffold(
            appBar: appbar(),
            body: TabBarView(
              children: [
                const Camera(),
                Recents(),
                Contacts(),
                Sms(text: widget.text),
              ],
            )));
  }
}

AppBar appbar() {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Hero(
        tag: "logo",
        child: Image.asset(
          "assets/phone.png",
        ),
      ),
    ),
    leadingWidth: 40,
    title: const Text(
      'Calls Manager',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    titleSpacing: 5,
    elevation: 0.0,
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_none),
        iconSize: 20.0,
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.search),
        iconSize: 20.0,
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        iconSize: 20.0,
        // color: Colors.white,
        onPressed: () {},
      ),
    ],
    bottom: const TabBar(indicatorWeight: 3, tabs: [
      Tab(icon: Icon(Icons.camera_alt)),
      Tab(icon: Icon(Icons.call), text: "Recents"),
      Tab(icon: Icon(Icons.people), text: "Contacts"),
      Tab(icon: Icon(Icons.sms), text: "Messages"),
    ]),
  );
}
