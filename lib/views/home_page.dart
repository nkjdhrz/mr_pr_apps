import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pr/views/manual_receipt_details.dart';
import 'custom_bottom_nav_bar.dart';
import 'generate_qr_page.dart';
import 'manual_receipt_form.dart';
// import 'profile_page.dart';  // Import the ProfilePage class
// import 'notifications_page.dart';  // Import the NotificationsPage class
import 'draft_page.dart';  // Import the DraftPage class
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_pr/auth_utils.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'My PR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.hindSiliguriTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<String?> _username; // Make it late as it will be initialized in initState()
  late Future<List> _receipts;

  @override
  void initState() {
    super.initState();
    _username = _getUsername();
    _receipts = _getReceipts();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Future<String?> _getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username') ?? 'Guest'; // Provide a default value in case username is not set
    print('Username from SharedPreferences: $username');
    return username;
  }

  Future<List> _getReceipts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userId = prefs.getString('id');
    if (token == null || userId == null) {
      print('Token or User ID is null');
      throw Exception('Token or User ID is null');
    }
    print('Token: $token');
    print('UserID: $userId');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/receipt/all'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    else if (response.statusCode == 401) { // Unauthorized
        logoutAndRedirectToLogin();
        throw Exception('Unauthorized, redirected to login');  // You can handle this exception where _getReceipts() is being called
    } 
    else {
      throw Exception('Failed to load receipts');
    }
  }

  Future<void> _refreshReceipts() async {
    setState(() {
      _receipts = _getReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 22, 51, 131);
    final Color accentColor = Color.fromRGBO(91, 103, 202, 1);
    const Color backgroundColor = Colors.white;
    const Color textColor = Color.fromRGBO(44, 64, 110, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // AppBar section
          Container(
            height: 200.0,
            color: backgroundColor,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
                FutureBuilder<String?>(
                  future: _username,
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();  // Show loading spinner while waiting for username
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Hi, ${snapshot.data}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // List section
          Expanded(
            child: FutureBuilder<List>(
              future: _receipts,
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading receipts'));
                } else if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No Receipt available'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshReceipts,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final receiptObject = snapshot.data![index];
                        final dateTime = DateTime.parse(receiptObject['createdAt']);
                        final formattedDate = DateFormat('hh:mm a dd/MM/yyyy').format(dateTime);
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.all(10),
                          color: Color(0xFFF9FAFD),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            title: IntrinsicHeight(
                              child: Row(
                                children: [
                                  VerticalDivider(
                                    thickness: 2.0,
                                    color: Color(0xff8F99EB),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Receipt Ref: ${receiptObject['refNo']}',
                                          style: TextStyle(color: textColor),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(color: Color(0xff9AA8C7), fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ManualReceiptDetails(receiptObject['_id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                  ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMyDialog(context);
        },
        child: Icon(Icons.add, size: 25.0),
        backgroundColor: accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }


  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please choose type of receipt'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'MANUAL RECEIPT',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManualReceiptForm()));
                  },
                ),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'GENERATE QR/LINK',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GenerateQRPage())); // Change here
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
