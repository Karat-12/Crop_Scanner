import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode

class CropAnalyzerPage extends StatefulWidget {
  @override
  _CropAnalyzerPageState createState() => _CropAnalyzerPageState();
}

class _CropAnalyzerPageState extends State<CropAnalyzerPage> {
  File? _image;
  String _result = '';
  Map<String, dynamic>? _parsedResult;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() {
          _result = 'No image selected.';
          _parsedResult = null;
          _image = null;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _image = File(pickedFile.path);
        _result = '';
        _parsedResult = null;
        _isLoading = true;
      });

      await uploadImage(_image!);
    } catch (e) {
      setState(() {
        _result = 'Error picking image: $e';
        _parsedResult = null;
        _isLoading = false;
      });
    }
  }

  Future uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/crop/analyze');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResult = jsonDecode(respStr);

        setState(() {
          _parsedResult = jsonResult;
          _result = '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = 'Error: Server returned ${response.statusCode}';
          _parsedResult = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Exception during upload: $e';
        _parsedResult = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Analyzer'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Image preview or placeholder box
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.green[900],
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                child: _image == null
                    ? Center(
                        child: Text(
                          'No image selected',
                          style: TextStyle(
                            color: Colors.greenAccent.shade400,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),

              SizedBox(height: 24),

              // Pick Image Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Pick Image',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 24),

              // Result message or info cards
              if (!_isLoading && _parsedResult == null)
                Text(
                  _result,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.greenAccent.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

              if (_parsedResult != null)
                ...[
                  _infoCard('Crop', _parsedResult!['crop']),
                  _infoCard('Health', _parsedResult!['health']),
                  _infoCard('Nutrition', _parsedResult!['nutrition']),
                  _metricsCard(_parsedResult!['metrics']),
                ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String? value) {
    return Card(
      color: Colors.green[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            Text(
              '$title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent.shade400,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? 'N/A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricsCard(Map<String, dynamic> metrics) {
    return Card(
      color: Colors.green[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metrics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent.shade400,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 12),
            ...metrics.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        (entry.value is double)
                            ? entry.value.toStringAsFixed(2)
                            : entry.value.toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
