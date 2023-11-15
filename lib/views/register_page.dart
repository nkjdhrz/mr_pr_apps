import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';
import 'package:my_pr/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:5000/api/user/signup'), // or replace with your computer's IP address
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': _nameController.text,
      'ic': _icController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Text('Successfully registered, please login.'),
          actions: <Widget>[
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  } else {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to register user.');
  }
}


  @override
  Widget build(BuildContext context) {
    double baseWidth = 393;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(35 * fem, 100 * fem, 42 * fem, 126 * fem),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sign Up',
                style: SafeGoogleFont(
                  'Hind Siliguri',
                  fontSize: 36 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.615 * ffem / fem,
                  color: Color(0xff5b67ca),
                ),
              ),
              SizedBox(height: 20 * fem),
              _buildInputField(fem, ffem, 'Full Name', 'iconly-curved-message-X8V.png', _nameController),
              SizedBox(height: 20 * fem),
              _buildInputField(fem, ffem, 'IC No.', 'iconly-curved-message-zkh.png', _icController),
              SizedBox(height: 20 * fem),
              _buildInputField(fem, ffem, 'Username', 'iconly-curved-message-P53.png', _usernameController),
              SizedBox(height: 20 * fem),
              _buildInputField(fem, ffem, 'Email ID', 'iconly-curved-lock-r9X.png', _emailController),
              SizedBox(height: 20 * fem),
              _buildInputField(fem, ffem, 'Password', 'iconly-curved-lock.png', _passwordController, isPassword: true),
              SizedBox(height: 20 * fem),
              _buildCreateButton(fem, ffem),
              SizedBox(height: 20 * fem),
              _buildSignInButton(context, fem, ffem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(double fem, double ffem, String placeholder, String icon, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.45 * fem),
      width: double.infinity,
      height: 38.15 * fem,
      child: Row(
        children: [
          Image.asset('assets/page-1/images/$icon', width: 19.05 * fem, height: 18.23 * fem),
          SizedBox(width: 15.5 * fem),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: SafeGoogleFont(
                  'Hind Siliguri',
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.0625 * ffem / fem,
                  color: Color(0xffc6cedd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(double fem, double ffem) {
    return TextButton(
      onPressed: _registerUser,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: 52 * fem,
        decoration: BoxDecoration(
          color: Color(0xff5b67ca),
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
            'Create',
            style: SafeGoogleFont(
              'Hind Siliguri',
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

  Widget _buildSignInButton(BuildContext context, double fem, double ffem) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: RichText(
        text: TextSpan(
          style: SafeGoogleFont(
            'Hind Siliguri',
            fontSize: 14 * ffem,
            fontWeight: FontWeight.w400,
            height: 1.2142857143 * ffem / fem,
            color: Color(0xff2c406e),
          ),
          children: [
            TextSpan(
              text: 'Have any account? ',
            ),
            TextSpan(
              text: 'Sign In',
              style: SafeGoogleFont(
                'Hind Siliguri',
                fontSize: 14 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.2142857143 * ffem / fem,
                color: Color(0xff2c406e),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
