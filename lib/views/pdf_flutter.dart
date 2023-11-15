import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewPage extends StatelessWidget {
  final String path;

  PDFViewPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: path,
      autoSpacing: true,
      enableSwipe: true,
      pageSnap: true,
      swipeHorizontal: true,
      nightMode: false,
      onError: (error) {
        print(error.toString());
      },
      onRender: (_pages) {
        print("Total pages: $_pages");
      },
      onViewCreated: (PDFViewController pdfViewController) {
        print('PDF view created');
      },
      onPageChanged: (int? page, int? total) {
        print('Page changed: $page/$total');
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
    );
  }
}
