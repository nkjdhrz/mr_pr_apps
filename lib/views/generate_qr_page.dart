import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pr/views/qr_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_receipt_details.dart';

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  String? categoryValue;
  String? subCategoryValue;
  List<String> subCategoryOptions = [];
  final dermaSubCategoryOptions = [
    'Hadiah wang kepada Kerajaan / Kerajaan Negeri / pihak berkuasa tempatan',
    'Hadiah wang kepada institusi / organisasi / tabung yang diluluskan',
    'Hadiah wang bagi aktiviti sukan yang diluluskan oleh Menteri Kewangan',
    'Hadiah wang atau kos sumbangan barangan kepada projek berkepentingan negara yang diluluskan oleh Menteri Kewangan',
    'Hadiah artifak / manuskrip / lukisan kepada Kerajaan atau Kerajaan Negeri',
  ];
  final pelepasanSubCategoryOptions = [
    'Individu dan saudara tanggungan',
    'Yuran pengajian (Sendiri)-Peringkat selain sarjana atau doktor falsafah - Bidang undang-undang, perakaunan, kewangan islam, teknikal, vokasional, industri, saintifik atau teknologi',
    'Yuran pengajian (Sendiri)-Peringkat sarjana atau doktor falsafah - Sebarang bidang atau kursus pengajian',
  ];
  bool showExtraField = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final totalController = TextEditingController();
  final _noReferenceReceiptController = TextEditingController();
  final _noRegistrationCompanyController = TextEditingController();
  final _noApprovalController = TextEditingController();
  final picker = ImagePicker();
  final attachmentController = TextEditingController();

  Future<bool>? _submitFuture;

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, 
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }


  Future<bool> _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('http://10.0.2.2:5000/api/receipt/generate-code');  // replace with your server URI

    // Get user's id, username, and token from wherever you store your session data
    var userId = prefs.getString('id');
    var username = prefs.getString('username');
    var token = prefs.getString('token');

    if(userId == null || username == null || token == null) {
      // handle null values, possibly show an error message to the user
      print("Missing user id, username, or token");
      return false;
    }

    final data = {
      'userId': userId,
      'username': username,
      'data': {
        'category': categoryValue,
        'subCategory': subCategoryValue,
        'date': selectedDate.toIso8601String(),
        'time': selectedTime.format(context),
        'noReferenceReceipt': _noReferenceReceiptController.text,
        'noRegistrationCompany': _noRegistrationCompanyController.text,
        'noApproval': _noApprovalController.text,
        'total': totalController.text,
      }
    };

    print('Data to send: $data');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receipt saved successfully')));
      final responseJson = json.decode(response.body);
      final receiptId = responseJson['receipt']['_id'];
      final code = responseJson['receipt']['code']; // Assuming the server returns a 'code' for the receipt
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRCodePage(code: code)),
      );
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
      return false; // added this line
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate QR')),
      body: ListView(
        padding: EdgeInsets.all(16.0),

          children: <Widget>[
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Category',
                contentPadding: EdgeInsets.zero,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: categoryValue,
                  items: ['DERMA / HADIAH / SUMBANGAN','PELEPASAN']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      categoryValue = newValue;
                      showExtraField = newValue == 'DERMA / HADIAH / SUMBANGAN';

                      // Update subcategory options based on selected category
                      if (newValue == 'DERMA / HADIAH / SUMBANGAN') {
                        subCategoryOptions = dermaSubCategoryOptions;
                      } else if (newValue == 'PELEPASAN') {
                        subCategoryOptions = pelepasanSubCategoryOptions;
                      } else {
                        subCategoryOptions = [];
                      }

                      // Reset sub category value
                      subCategoryValue = null;
                    });
                  },
                ),
              ),
            ),
            if (showExtraField)
              TextFormField(
                controller: _noApprovalController,
                decoration: InputDecoration(labelText: 'No. Kelulusan'),
              ),
            if (subCategoryOptions.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: subCategoryValue,
                    items: subCategoryOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        subCategoryValue = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
            TextFormField(
              readOnly: true,
              controller: TextEditingController()..text = "${selectedDate.toLocal()}".split(' ')[0],
              decoration: InputDecoration(labelText: 'Date'),
              onTap: () => _selectDate(context),
            ),
            TextFormField(
              readOnly: true,
              controller: TextEditingController()..text = "${selectedTime.format(context)}",
              decoration: InputDecoration(labelText: 'Time'),
              onTap: () => _selectTime(context),
            ),
            TextField(
              controller: _noReferenceReceiptController,
              decoration: InputDecoration(labelText: 'No Reference Receipt'),
            ),
            TextField(
              controller: _noRegistrationCompanyController,
              decoration: InputDecoration(labelText: 'No Registration Company'),
            ),
            TextFormField(
              controller: totalController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Total (RM)',
                prefixText: 'RM ',
              ),
            ),
             FutureBuilder(
              future: _submitFuture,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If the future is still running, show a loading indicator
                  return CircularProgressIndicator();
                } else {
                  // If the future has completed, show the submit button
                  return ElevatedButton(
                    child: Text('Submit'),
                    onPressed: () {
                      setState(() {
                        // When the button is pressed, run _submitForm and store the Future
                        _submitFuture = _submitForm();
                      });
                    },
                  );
                }
              },
            ),
          ],
      ),
    );
  }
}
