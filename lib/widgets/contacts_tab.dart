import 'dart:typed_data';

import 'package:call_manager_app/service/contacts_data_service.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class Contacts extends StatefulWidget {
  Contacts({super.key});
  final List<Contact> contacts = ContactsDataService.getcontactdb;

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Contact> contactsFiltered = [];
  bool contactsLoaded = false;
  late bool isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.contacts.isNotEmpty) {
      contactsLoaded = true;
    }

    searchController.addListener(() {
      filterContacts();
    });
  }

  filterContacts() {
    List<Contact> contactsCopy = [];
    contactsCopy.addAll(widget.contacts);

    if (searchController.text.isNotEmpty) {
      contactsCopy.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String contactName = contact.displayName?.toLowerCase() ?? "";
        return contactName.contains(searchTerm);
      });

      setState(() {
        contactsFiltered = contactsCopy;
        contactsLoaded = true;
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        child: (!ContactsDataService.isContactsPermissionGranted)
            ? const Center(child: Text("Contacts Permission denied"))
            : Column(
                children: [
                  _search(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: contactsLoaded == true
                          ? ListView.builder(
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(), //ClampingScrollPhysics(),
                              itemCount: isSearching
                                  ? contactsFiltered.length
                                  : widget.contacts.length,
                              itemBuilder: (context, index) {
                                Contact contact = isSearching
                                    ? contactsFiltered[index]
                                    : widget.contacts[index];

                                return ListTile(
                                  title: Text(contact.displayName.toString()),
                                  subtitle: contact.phones!.isNotEmpty
                                      ? Text(contact.phones!
                                          .elementAt(0)
                                          .value
                                          .toString())
                                      : const Text(""),
                                  leading: (contact.avatar != null &&
                                          contact.avatar!.isNotEmpty)
                                      ? CircleAvatar(
                                          backgroundImage: MemoryImage(
                                              contact.avatar as Uint8List),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: Text(
                                            contact.initials().isNotEmpty
                                                ? contact.initials()
                                                : "👤",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                );
                              },
                            )
                          : Container(
                              // still loading contacts
                              padding: const EdgeInsets.only(top: 40),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
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
