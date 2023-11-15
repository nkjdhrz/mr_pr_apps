import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  final String code;

  const QRCodePage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: 'localhost:3000/receiptdetails?code=$code',
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text('Code: $code'),
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
