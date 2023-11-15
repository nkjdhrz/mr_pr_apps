import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> logoutAndRedirectToLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token'); // Clear stored token
  navigatorKey.currentState!.pushReplacementNamed('/login');
}
