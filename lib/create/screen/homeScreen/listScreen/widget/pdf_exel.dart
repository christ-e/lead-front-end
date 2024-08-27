import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfandExel extends StatefulWidget {
  const PdfandExel({
    super.key,
    required this.leads,
  });

  final dynamic leads;

  @override
  State<PdfandExel> createState() => _PdfandExelState();
}

class _PdfandExelState extends State<PdfandExel> {
  @override
  void initState() {
    super.initState();
  }

  void _showDownloadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () {
                  // Call your PDF generation method here
                  _generatePDF();
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              Text('Download PDF'),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.table_chart),
                onPressed: () {
                  // Call your Excel generation method here
                  _generateExcel();
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              Text('Download Excel'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generatePDF() async {
    // Your PDF generation code goes here
    // You can use the 'leads' data from widget.leads to populate the PDF
    print("PDF generation triggered");
  }

  Future<void> _generateExcel() async {
    // Your Excel generation code goes here
    // You can use the 'leads' data from widget.leads to populate the Excel file
    print("Excel generation triggered");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF and Excel Download'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _showDownloadOptions(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Your content here'),
      ),
    );
  }
}
