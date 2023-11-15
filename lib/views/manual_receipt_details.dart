import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_pr/views/pdf_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ManualReceiptDetails extends StatefulWidget {
  final String receiptId;

  ManualReceiptDetails(this.receiptId);

  @override
  _ManualReceiptDetailsState createState() => _ManualReceiptDetailsState();
}

class _ManualReceiptDetailsState extends State<ManualReceiptDetails> {
  Map<String, dynamic>? receiptDetails;

  Future<void> _fetchReceiptDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      final uri = Uri.parse('http://10.0.2.2:5000/api/receipt/details/${widget.receiptId}');
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      print("Fetching details for receipt ID: ${widget.receiptId}");

      if (response.statusCode == 200) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        final responseJson = json.decode(response.body);
        final receiptData = responseJson['data'];

        DateTime date = DateTime.parse(receiptData['date']);
        DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm a");
        String formattedDate = dateFormat.format(date);
        receiptData['date'] = formattedDate;

        setState(() {
          receiptDetails = receiptData;
        });
        print("Receipt details: $receiptDetails");
      } else {
        print("Error fetching details: status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error in _fetchReceiptDetails: $e");
    }
  }

  Future<void> _downloadFile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      final uri = Uri.parse('http://10.0.2.2:5000/api/receipt/download-attachment/${widget.receiptId}');
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      print("Downloading file for receipt ID: ${widget.receiptId}");
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${widget.receiptId}.pdf');

        await file.writeAsBytes(bytes);
        print("File downloaded and saved at: ${file.path}");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PDFViewPage(path: file.path)),
        );
      } else {
        print("Error downloading file: status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error in _downloadFile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReceiptDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (receiptDetails == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Receipt Details...')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Receipt Details')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['category'] ?? 'N/A',
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['date'] ?? 'N/A',
                decoration: InputDecoration(labelText: 'Date'),
              ),
              // TextFormField(
              //   readOnly: true,
              //   initialValue: receiptDetails!['time'] ?? 'N/A',
              //   decoration: InputDecoration(labelText: 'Time'),
              // ),
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['refNo'] ?? 'N/A',
                decoration: InputDecoration(labelText: 'No Reference Receipt'),
              ),
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['registrationNo'] ?? 'N/A',
                decoration: InputDecoration(labelText: 'No Registration Company'),
              ),
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['approvalNo'] ?? 'N/A',
                decoration: InputDecoration(labelText: 'No Approval'),
              ),
              TextFormField(
                readOnly: true,
                initialValue: receiptDetails!['total']?.toString() ?? 'N/A',
                decoration: InputDecoration(labelText: 'Total (RM)'),
              ),
              ListTile(
                title: Text('Attachment'),
                subtitle: Text(receiptDetails!['filePath'] ?? 'N/A'),
                trailing: IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: _downloadFile,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
