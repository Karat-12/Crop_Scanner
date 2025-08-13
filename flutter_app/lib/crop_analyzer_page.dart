import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropAnalyzerPage extends StatefulWidget {
  @override
  _CropAnalyzerPageState createState() => _CropAnalyzerPageState();
}

class _CropAnalyzerPageState extends State<CropAnalyzerPage> {
  File? _image;
  Map<String, dynamic>? _parsedResult;
  String _resultMessage = 'No image selected.';
  bool _isLoading = false;
  final picker = ImagePicker();

  void _updateState({String? message, Map<String, dynamic>? result, File? image, bool? loading}) {
    setState(() {
      if (message != null) _resultMessage = message;
      _parsedResult = result;
      if (image != null) _image = image;
      if (loading != null) _isLoading = loading;
    });
  }

  Future pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        _updateState(message: 'No image selected.', result: null, image: null, loading: false);
        return;
      }
      _updateState(image: File(pickedFile.path), result: null, message: '', loading: true);
      await uploadImage(_image!);
    } catch (e) {
      _updateState(message: 'Error picking image: $e', result: null, loading: false);
    }
  }

  Future uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.144.248.37:8000/api/crop/analyze'); // update IP
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResp = jsonDecode(respStr);

        Map<String, dynamic> safeResult = {
          "crop": jsonResp["crop"] ?? "Unknown",
          "health": jsonResp["health"] ?? "Unknown",
          "disease_percentage": jsonResp["disease_percentage"] ?? 0.0,
          "metrics": jsonResp["metrics"] ?? {},
        };

        _updateState(result: safeResult, message: '', loading: false);
      } else {
        _updateState(message: 'Error: Server returned ${response.statusCode}', result: null, loading: false);
      }
    } catch (e) {
      _updateState(message: 'Exception during upload: $e', result: null, loading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Colors.green;
    final greenAccent = Colors.greenAccent;

    Widget _infoCard(String title, String? value) => Card(
      color: green[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            Text('$title:', style: TextStyle(fontWeight: FontWeight.bold, color: greenAccent.shade400, fontSize: 20)),
            SizedBox(width: 12),
            Expanded(child: Text(value ?? 'N/A', style: TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),
      ),
    );

    Widget _metricsCard(Map<String, dynamic> metrics) => Card(
      color: green[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metrics', style: TextStyle(fontWeight: FontWeight.bold, color: greenAccent.shade400, fontSize: 20)),
            SizedBox(height: 12),
            ...metrics.entries.map((e) => Row(
              children: [
                Expanded(flex: 3, child: Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70))),
                Expanded(flex: 2, child: Text(
                  (e.value is double) ? e.value.toStringAsFixed(2) : e.value.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70),
                )),
              ],
            )),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Crop Analyzer'), centerTitle: true, backgroundColor: green[700]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: green[900],
                  border: Border.all(color: greenAccent, width: 2),
                ),
                child: _image == null
                    ? Center(child: Text('No image selected', style: TextStyle(color: greenAccent.shade400, fontSize: 22, fontWeight: FontWeight.bold)))
                    : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, fit: BoxFit.cover)),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenAccent.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: _isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : Text('Pick Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 24),
              if (!_isLoading && _parsedResult == null)
                Text(_resultMessage, style: TextStyle(fontSize: 18, color: greenAccent.shade400, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              if (_parsedResult != null)
                ...[
                  _infoCard('Crop', _parsedResult!['crop']),
                  _infoCard('Health', _parsedResult!['health']),
                  _infoCard('Disease %', _parsedResult!['disease_percentage'].toString()),
                  if (_parsedResult!['metrics'] != null) _metricsCard(_parsedResult!['metrics']),
                ]
            ],
          ),
        ),
      ),
    );
  }
}
