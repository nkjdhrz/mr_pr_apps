import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_pr/views/register_page.dart';
import 'package:my_pr/utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserModel.dart';
import '../providers/UserProvider.dart';


import 'home_page.dart';

// Define constants for repeated values
const kPrimaryColor = Color(0xff5b67ca);
const kSecondaryColor = Color(0xff2c406e);
const kBackgroundColor = Color(0xffc8e1fd);
const kFontFamily = 'Hind Siliguri';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final storage = FlutterSecureStorage();

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 393;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: Builder(
        builder: (context) => SizedBox(
          width: double.infinity,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kBackgroundColor,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(fem, ffem),
                  _buildLoginForm(context, fem, ffem),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double fem, double ffem) {
    return Container(
      padding: EdgeInsets.fromLTRB(99 * fem, 93 * fem, 87 * fem, 0 * fem),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 53 * fem),
            width: 207 * fem,
            height: 172 * fem,
            child: Image.asset(
              'assets/page-1/images/rectangle-647.png',
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 0 * fem),
            child: Text(
              'MyReceipt',
              style: SafeGoogleFont(
                kFontFamily,
                fontSize: 32 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.615 * ffem / fem,
                color: Color(0xff281111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context,double fem, double ffem) {
    return Container(
      padding: EdgeInsets.fromLTRB(44 * fem, 58.85 * fem, 45 * fem, 124 * fem),
      width: double.infinity,
      height: 522 * fem,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(56 * fem),
      ),
      child: SingleChildScrollView(  // Wrap your Column in a SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInputField(fem, ffem, 'Email ID or Username', 'iconly-curved-message.png'),
            SizedBox(height: 33.75 * fem),
            _buildInputField(fem, ffem, 'Password', 'iconly-curved-lock-Mr9.png', isPassword: true),
            SizedBox(height: 15 * fem),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password ?',
                style: SafeGoogleFont(
                  kFontFamily,
                  fontSize: 12 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.4166666667 * ffem / fem,
                  color: kPrimaryColor,
                ),
              ),
            ),
            SizedBox(height: 39 * fem),
            _buildLoginButton(context,fem, ffem),
            SizedBox(height: 90 * fem),
            _buildSignUpButton(context, fem, ffem),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(double fem, double ffem, String placeholder, String icon, {bool isPassword = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.45 * fem),
      width: double.infinity,
      height: 38.15 * fem,
      child: Row(
        children: [
          Image.asset('assets/page-1/images/$icon', width: 19.05 * fem, height: 18.23 * fem),
          SizedBox(width: 15.5 * fem),
          Expanded(
            child: Material(  // Wrap your TextField in a Material widget
              child: TextField(
                controller: isPassword ? passwordController : emailController,
                obscureText: isPassword,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: SafeGoogleFont(
                    kFontFamily,
                    fontSize: 16 * ffem,
                    fontWeight: FontWeight.w400,
                    height: 1.0625 * ffem / fem,
                    color: Color(0xffc6cedd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context,double fem, double ffem) {
    return TextButton(
      onPressed: () async {
          var url = Uri.parse('http://10.0.2.2:5000/api/user/login');
          var response = await http.post(
            url,
            body: json.encode({
              'username': emailController.text, 
              'password': passwordController.text
            }),
            headers: {"Content-Type": "application/json"},
          );
          if (response.statusCode == 200) {
            Map<String, dynamic> res = jsonDecode(response.body);

            // Save token, username, email, and active to SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', res['data']['token']);
            await prefs.setString('username', res['data']['user']['username']);
            await prefs.setString('email', res['data']['user']['email']);
            await prefs.setInt('active', res['data']['user']['active']);
            await prefs.setString('id', res['data']['user']['_id']);
            // For the IC number, if it is a String
            await prefs.setString('icNo', res['data']['user']['icNo']);



            // Update user in UserProvider
            Provider.of<UserProvider>(context, listen: false).setUser(UserModel(
              token: res['data']['token'],
              username: res['data']['user']['username'],
              email: res['data']['user']['email'],
              active: res['data']['user']['active'],
              id: res['data']['user']['_id'],
            ));

            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logged in successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (response.statusCode == 400) {
            // If the server returns a 400 response,
            // show a dialog with an error message.
            Map<String, dynamic> res = jsonDecode(response.body);
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Login Failed'),
                  content: Text(res['message'] ?? 'An error occurred'),
                  actions: [
                    TextButton(
                      child: Text('Dismiss'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            // For other error codes, show a simple snackbar.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to log in. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: 52 * fem,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(14 * fem),
          boxShadow: [
            BoxShadow(
              color: Color(0xfff1f6ff),
              offset: Offset(-3 * fem, 7 * fem),
              blurRadius: 6.5 * fem,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Login',
            style: SafeGoogleFont(
              kFontFamily,
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w600,
              height: 1.0625 * ffem / fem,
              color: Color(0xfffafafa),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, double fem, double ffem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup()),
        );
      },
      child: RichText(
        text: TextSpan(
          style: SafeGoogleFont(
            kFontFamily,
            fontSize: 14 * ffem,
            fontWeight: FontWeight.w400,
            height: 1.2142857143 * ffem / fem,
            color: kSecondaryColor,
          ),
          children: [
            TextSpan(
              text: 'Don’t have an account? ',
            ),
            TextSpan(
              text: 'Sign Up',
              style: SafeGoogleFont(
                kFontFamily,
                fontSize: 14 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.2142857143 * ffem / fem,
                color: kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
