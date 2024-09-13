import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  final String _fullname;
  final String _email;

  ProfileViewModel(this._fullname, this._email);

  String get fullname => _fullname;
  String get email => _email;

}
