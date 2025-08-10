import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CropAnalyzerPage extends StatefulWidget {
  const CropAnalyzerPage({super.key});

  @override
  _CropAnalyzerPageState createState() => _CropAnalyzerPageState();
}

class _CropAnalyzerPageState extends State<CropAnalyzerPage> {
  File? _image;
  String? _result;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8080/api/crop/analyze'), // use 10.0.2.2 for Android emulator
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file', // this must match your @RequestParam name in Spring Boot
        _image!.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          _result = jsonEncode(jsonResponse, toEncodable: (e) => e.toString());
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _analyzeImage,
              child: Text('Analyze'),
            ),
            if (_isLoading) CircularProgressIndicator(),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result ?? '', style: TextStyle(fontSize: 14)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
