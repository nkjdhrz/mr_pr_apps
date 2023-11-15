import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pr/auth_utils.dart';
import 'package:my_pr/views/manual_receipt_details.dart';
import 'custom_bottom_nav_bar.dart';
import 'generate_qr_page.dart';
import 'manual_receipt_form.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My PR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.hindSiliguriTextTheme(Theme.of(context).textTheme),
      ),
      home: const DraftPage(),
    );
  }
}

class DraftPage extends StatefulWidget{
  const DraftPage([Key? key]) : super(key:key);

  @override
  _DraftPageState createState()=> _DraftPageState();
}


class _DraftPageState extends State<DraftPage> {
  int _selectedIndex = 3;
  late Future<String?> _username; // Make it late as it will be initialized in initState()
  late Future<List> _receipts;

  @override
  void initState() {
    super.initState();
    _username = _getUsername();
    _receipts = _getDraftReceipts();
  }

  Future<String?> _getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('username') ?? 'Guest'; // Provide a default value in case username is not set
    // print('Username from SharedPreferences: $username');
    return username;
  }

  Future<List> _getDraftReceipts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userId = prefs.getString('id');
    if (token == null || userId == null) {
      // print('Token or User ID is null');
      throw Exception('Token or User ID is null');
    }
    // print('Token: $token');
    // print('UserID: $userId');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/receipt/all-draft'),
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

  Future<void> _refreshDraftReceipts() async {
    setState(() {
      _receipts = _getDraftReceipts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 22, 51, 131);
    const Color accentColor = Color.fromRGBO(91, 103, 202, 1);
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
                      return const CircularProgressIndicator();  // Show loading spinner while waiting for username
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Hi, ${snapshot.data}',
                        style: const TextStyle(
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading receipts'));
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Receipt available'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshDraftReceipts,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final receiptObject = snapshot.data![index];
                        final dateTimeString = receiptObject['createdAt'];
                        final dateTime = dateTimeString != null ? DateTime.parse(dateTimeString) : null;
                        final formattedDate = dateTime != null ? DateFormat('hh:mm a dd/MM/yyyy').format(dateTime) : 'Unknown date';
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.all(10),
                          color: Color(0xFFF9FAFD),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            title: IntrinsicHeight(
                              child: Row(
                                children: [
                                  const VerticalDivider(
                                    thickness: 2.0,
                                    color: Color(0xff8F99EB),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Attachment: ${receiptObject['filePath']}',
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
        backgroundColor: accentColor,
        child: const Icon(Icons.add, size: 25.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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