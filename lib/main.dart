import 'package:flutter/material.dart';
import 'package:my_pr/views/draft_page.dart';
import 'views/login_page.dart';
import 'views/manual_receipt_form.dart';
import 'views/register_page.dart';
import 'views/home_page.dart';
import 'providers/UserProvider.dart'; // make sure this is the correct import path for your UserProvider
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(), // initialize UserProvider here
      child: MaterialApp(
        title: 'Login App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const Signup(),
          '/home': (context) => const HomePage(),
          '/manual-receipt-form' : (context) => const ManualReceiptForm(),
          '/draft-page' : (context) => const DraftPage()
        },
      ),
    );
  }
}
