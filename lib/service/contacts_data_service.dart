import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsDataService {
  static final List<Contact> _contacts = [];
  static bool _isContactsPermissionGranted = false;
  bool _isContactsDbLoaded = false;

  static List<Contact> get getcontactdb {
    return _contacts;
  }

  static bool get isContactsPermissionGranted {
    return _isContactsPermissionGranted;
  }

  void _addContactsDb(List<Contact> contactsdb) {
    _contacts.addAll(contactsdb);
  }

  Future<bool> fetchContactsDb() async {
    if (!_isContactsPermissionGranted) {
      await _requestContactPermission();
    } else {
      await _getAllContacts();
    }
    return _isContactsDbLoaded;
  }

  Future<void> _getAllContacts() async {
    if (_isContactsPermissionGranted) {
      var contacts = await ContactsService.getContacts(
          photoHighResolution: false,
          withThumbnails: true,
          orderByGivenName: true);
      _addContactsDb(contacts);
      _isContactsDbLoaded = true;
      // print(contacts);
    }
  }

  Future<void> _requestContactPermission() async {
    final status = await Permission.contacts.request();
    _isContactsPermissionGranted = status == PermissionStatus.granted;
    if (_isContactsPermissionGranted) {
      await _getAllContacts();
    }
  }
}
