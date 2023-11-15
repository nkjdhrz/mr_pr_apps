// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_receipt_details.dart';

class ManualReceiptForm extends StatefulWidget {
  const ManualReceiptForm({super.key});

  @override
  _ManualReceiptFormState createState() => _ManualReceiptFormState();
}

class _ManualReceiptFormState extends State<ManualReceiptForm> {

  final category = {
    1:'Individu dan saudara tanggungan',
    2:'Yuran pengajian (Sendiri)-Peringkat selain sarjana atau doktor falsafah - Bidang undang-undang, perakaunan, kewangan islam, teknikal, vokasional, industri, saintifik atau teknologi',
    3:'Yuran pengajian (Sendiri)-Peringkat sarjana atau doktor falsafah - Sebarang bidang atau kursus pengajian',
  };



  int? categoryValue;
  bool showExtraField = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final totalController = TextEditingController();
  final _noReferenceReceiptController = TextEditingController();
  final _noRegistrationCompanyController = TextEditingController();
  PlatformFile? _pdfFile;
  File? _pdfFileFile;
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

  _pickOrScanPdfFile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload or Capture PDF'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Pick PDF from device"),
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null) {
                      setState(() {
                        _pdfFile = result.files.single;
                        _pdfFileFile = File(_pdfFile!.path!);
                        // update the attachmentController text here
                        attachmentController.text = _pdfFile!.name;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Capture document image"),
                  onTap: () async {
                    final pickedFile = await picker.getImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      final pdf = pw.Document();
                      final image = pw.MemoryImage(
                        File(pickedFile.path).readAsBytesSync(),
                      );

                      pdf.addPage(pw.Page(
                        build: (pw.Context context) => pw.Center(child: pw.Image(image)),
                      ));

                      final output = await getTemporaryDirectory();
                      final file = File("${output.path}/example.pdf");
                      await file.writeAsBytes(await pdf.save());

                      setState(() {
                        _pdfFileFile = file;
                        // update the attachmentController text here
                        attachmentController.text = file.path.split("/").last;
                      });

                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<bool> _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('http://10.0.2.2:5000/api/receipt/create');

    final request = http.MultipartRequest('POST', uri);


    var userId = prefs.getString('id');
    var username = prefs.getString('username');
    var token = prefs.getString('token');

    if(userId == null || username == null || token == null) {
      print("Missing user id, username, or token");
      return false;
    }

    final dataToSend = {
      'userId': userId,
      'username': username,
      'category': categoryValue,
      'date': selectedDate.toIso8601String(),
      'time': selectedTime.format(context),
      'refNo': _noReferenceReceiptController.text,
      'registrationNo': _noRegistrationCompanyController.text,
      'amount': totalController.text,
    };

    print('Data to send: $dataToSend');

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(dataToSend.map((key, value) => MapEntry(key, value.toString())));

    if (_pdfFileFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'pdfFile',
        _pdfFileFile!.path,
      ));
    }

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receipt saved successfully')));
      final responseJson = json.decode(response.body);
      final receiptId = responseJson['receipt']['_id'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManualReceiptDetails(receiptId)),
      );
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Receipt')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0), // Add some spacing between the label and dropdown
            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSelectedItems: true,
              ),
              items: category.values.toList(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Category",
                  hintText: "Select a category",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  categoryValue = category.keys.firstWhere((k) => category[k] == value);
                });
              },
              selectedItem: category[categoryValue],
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
            TextFormField(
              controller: attachmentController,
              readOnly: true,  // make this field uneditable
              decoration: InputDecoration(
                labelText: 'Attachment',
              ),
            ),
            ElevatedButton(
              child: Text('Upload or Capture PDF'),
              onPressed: _pickOrScanPdfFile,
            ),
            if (_pdfFile != null)
              Text('Picked PDF: ${_pdfFile!.path}'),
            // ElevatedButton(
            //   child: Text('Submit'),
            //   onPressed: _submitForm,
            // ),
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
