import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/model/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier{
  User? _user;
  final AuthMethods _authMethods = AuthMethods();
  User? get getUser => _user;

  Future<void> refreshUser() async{
    User user = await _authMethods.getUserDetails();
    // print("user details : ${user.username}");
    _user = user;
    notifyListeners();
  }

}