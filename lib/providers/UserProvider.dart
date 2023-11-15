import 'package:flutter/material.dart';
import '../models/UserModel.dart';

class UserProvider with ChangeNotifier {
  UserModel _user = UserModel(token: '', username: '',email: '',active: 0,id: '');

  UserModel get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = UserModel();
    notifyListeners();
  }

}
