//lib/screen/trainee/certificate_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CertificateViewerPage extends StatefulWidget {
  final String pdfUrl;

  const CertificateViewerPage({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<CertificateViewerPage> createState() =>
      _CertificateViewerPageState();
}

class _CertificateViewerPageState
    extends State<CertificateViewerPage> {

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _downloadAndOpenPdf(widget.pdfUrl);
    });
  }

  Future<void> _downloadAndOpenPdf(String url) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading certificate...'),
        ),
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download certificate',
        );
      }

      final dir = await getTemporaryDirectory();

      final file = File(
        '${dir.path}/certificate_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      await file.writeAsBytes(response.bodyBytes);

      final result = await OpenFile.open(file.path);

      if (result.type == ResultType.done) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception(result.message);
      }

    } catch (e) {

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Certificate',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),

      body: Center(
        child: _isLoading
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Opening certificate...'),
          ],
        )
            : Text(
          _errorMessage ?? '',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}