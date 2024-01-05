import 'package:call_manager_app/service/call_log_service.dart';
import 'package:call_manager_app/Model/call_log_model.dart';
import 'package:flutter/material.dart';

class Recents extends StatefulWidget {
  Recents({super.key});
  final List<CallLogModel> callLogs = CallLogService.getCallLogs;

  @override
  State<Recents> createState() => _RecentsState();
}

class _RecentsState extends State<Recents> with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  List<CallLogModel> callLogsFiltered = [];
  late bool isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      filterCallLog();
    });

    setState(() {
      callLogsFiltered = widget.callLogs;
    });
  }

  void filterCallLog() {
    List<CallLogModel> callLogCopy = [];
    callLogCopy.addAll(widget.callLogs);

    if (searchController.text.isNotEmpty) {
      callLogCopy.retainWhere((callLog) {
        String searchTerm = searchController.text.toLowerCase();
        String callLogName = callLog.name.toLowerCase();
        return callLogName.contains(searchTerm);
      });

      setState(() {
        callLogsFiltered = callLogCopy;
      });
    } else {
      setState(() {
        callLogsFiltered = widget.callLogs;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.callLogs.isNotEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          height: 10.0,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF9EB),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            children: [
              _search(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: isSearching
                          ? callLogsFiltered.length
                          : widget.callLogs.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        CallLogModel callLog = isSearching
                            ? callLogsFiltered[index]
                            : widget.callLogs[index];
                        return ListTile(
                          minVerticalPadding: 14.0,
                          leading: CircleAvatar(
                            backgroundColor: callLog.callColor,
                            child: Text(callLog.name.substring(0, 1)),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                callLog.formattedDate,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              Icon(
                                callLog.callIcon,
                                color: callLog.callColor,
                              )
                            ],
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(callLog.name),
                              Text(
                                callLog.callType,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          onTap: () {
                            showModalBottomSheet(
                                enableDrag: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                        bottom: Radius.zero),
                                    child: SingleChildScrollView(
                                      child: Container(
                                          padding: const EdgeInsets.all(12),
                                          color: Theme.of(context).canvasColor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(callLog.name),
                                                    Text(
                                                      callLog.phoneNumber
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 13),
                                                    )
                                                  ],
                                                ),
                                                trailing: Icon(callLog.callIcon,
                                                    color: callLog.callColor),
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      callLog.callColor,
                                                  child: Text(
                                                    callLog.name[0],
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: const Text("Date"),
                                                trailing:
                                                    Text(callLog.formattedDate),
                                              ),
                                              ListTile(
                                                title: const Text("Duration"),
                                                trailing:
                                                    Text("${callLog.duration}"
                                                        "s"),
                                              ),
                                              ListTile(
                                                title: const Text("Call Type"),
                                                trailing:
                                                    Text(callLog.callType),
                                              ),
                                              ListTile(
                                                title: const Text(
                                                    "SIM Display Name"),
                                                trailing: Text(callLog.sim),
                                              ),
                                              ListTile(
                                                title: const Text(
                                                    "Phone Account ID "),
                                                trailing: Text(
                                                    callLog.phoneAccountId),
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text("CLOSE"),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          )),
                                    ),
                                  );
                                });
                          },
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return (!CallLogService.isCallLogPermissionGranted)
        ? const Center(child: Text("Call Log Permission denied"))
        : Container(
            padding: const EdgeInsets.all(10.0),
            color: const Color(0xFFFEF9EB),
            child: const Center(child: Text("Nothing to display")),
          );
  }

  Container _search() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0)
      ], color: Colors.transparent),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(
          () {
            isSearching = searchController.text.isNotEmpty;
          },
        ),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: "Search Contacts",
            hintStyle: const TextStyle(
              color: Color(0xffDDDADA),
              fontSize: 14,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.search),
            ),
            suffixIcon: const SizedBox(
              width: 100,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VerticalDivider(
                      color: Colors.black,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12, right: 12, bottom: 12),
                      child: Icon(Icons.emoji_people),
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
