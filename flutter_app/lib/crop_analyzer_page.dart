import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // make sure BASE_URL is defined
import 'theme/app_theme.dart'; // Import the custom theme

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
    final uri = Uri.parse('$BASE_URL/analyze'); // from config.dart
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
        };

        _updateState(result: safeResult, message: '', loading: false);
      } else {
        _updateState(message: 'Error: Server returned ${response.statusCode}', result: null, loading: false);
      }
    } catch (e) {
      _updateState(message: 'Exception during upload: $e', result: null, loading: false);
    }
  }

  Color getHealthColor(String health) {
    return health.toLowerCase() == 'healthy'
        ? AppColors.healthy
        : AppColors.diseased;
  }

  Widget _infoCard(String title, String value, {Color? valueColor}) => Card(
        color: AppColors.cardBackground,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Text('$title:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 20)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Analyzer'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: _image == null
                    ? Center(
                        child: Text(
                          'No image selected',
                          style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, fit: BoxFit.cover)),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : pickImage,
                child: _isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : Text('Pick Image'),
              ),
              SizedBox(height: 24),
              if (!_isLoading && _parsedResult == null)
                Text(_resultMessage, style: TextStyle(fontSize: 18, color: AppColors.secondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              if (_parsedResult != null) ...[
                _infoCard('Crop', _parsedResult!['crop']),
                _infoCard('Health', _parsedResult!['health'], valueColor: getHealthColor(_parsedResult!['health'])),
                _infoCard('Disease %', _parsedResult!['disease_percentage'].toStringAsFixed(2) + '%'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
