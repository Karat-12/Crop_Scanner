import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: Color(0xFF121212),
        brightness: Brightness.dark,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGreen,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: CropAnalyzerPage(),
    );
  }
}

class CropAnalyzerPage extends StatefulWidget {
  @override
  _CropAnalyzerPageState createState() => _CropAnalyzerPageState();
}

class _CropAnalyzerPageState extends State<CropAnalyzerPage> {
  static const Color cardColor = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF66BB6A);

  File? _image;
  String _resultMessage = 'No image selected.';
  Map<String, dynamic>? _parsedResult;
  bool _isLoading = false;
  final picker = ImagePicker();

  Future pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() {
          _resultMessage = 'No image selected.';
          _parsedResult = null;
          _image = null;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _image = File(pickedFile.path);
        _resultMessage = '';
        _parsedResult = null;
        _isLoading = true;
      });

      await uploadImage(_image!);
    } catch (e) {
      setState(() {
        _resultMessage = 'Error picking image: $e';
        _parsedResult = null;
        _isLoading = false;
      });
    }
  }

  Future uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/crop/analyze');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResult = jsonDecode(respStr);

        setState(() {
          _parsedResult = jsonResult;
          _resultMessage = '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _resultMessage = 'Error: Server returned ${response.statusCode}';
          _parsedResult = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Exception during upload: $e';
        _parsedResult = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: accentGreen,
      fontSize: 20,
    );

    final TextStyle valueStyle = TextStyle(color: Colors.white, fontSize: 18);

    final TextStyle metricKeyStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white70,
      fontSize: 16,
    );

    final TextStyle metricValueStyle = TextStyle(
      color: Colors.white70,
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Crop Analyzer'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _image == null
                    ? Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentGreen, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'No Image Selected',
                          style: titleStyle.copyWith(fontSize: 22),
                        ),
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _image!,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                SizedBox(height: 24),
                ElevatedButton(
  onPressed: _isLoading ? null : pickImage,
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,  // <-- this sets the text color
    backgroundColor: Colors.greenAccent.shade700, // keep your button bg color
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  child: Text(_isLoading ? 'Uploading...' : 'Pick Image'),
),

                SizedBox(height: 24),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: accentGreen,
                      strokeWidth: 3,
                    ),
                  ),
                if (!_isLoading && _parsedResult == null)
                  Text(
                    _resultMessage,
                    style: titleStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_parsedResult != null) ...[
                  _infoCard(
                    'Crop',
                    _parsedResult!['crop'],
                    titleStyle,
                    valueStyle,
                  ),
                  _infoCard(
                    'Health',
                    _parsedResult!['health'],
                    titleStyle,
                    valueStyle,
                  ),
                  _infoCard(
                    'Nutrition',
                    _parsedResult!['nutrition'],
                    titleStyle,
                    valueStyle,
                  ),
                  if (_parsedResult!['metrics'] != null)
                    _metricsCard(
                      _parsedResult!['metrics'],
                      metricKeyStyle,
                      metricValueStyle,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    String? value,
    TextStyle titleStyle,
    TextStyle valueStyle,
  ) {
    return Card(
      color: Color(0xFF2E7D32),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            Text(title + ':', style: titleStyle),
            SizedBox(width: 12),
            Expanded(child: Text(value ?? 'N/A', style: valueStyle)),
          ],
        ),
      ),
    );
  }

  Widget _metricsCard(
    Map<String, dynamic> metrics,
    TextStyle keyStyle,
    TextStyle valueStyle,
  ) {
    return Card(
      color: Color(0xFF2E7D32),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metrics', style: keyStyle.copyWith(fontSize: 20)),
            SizedBox(height: 12),
            ...metrics.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(entry.key, style: keyStyle)),
                    Expanded(
                      flex: 2,
                      child: Text(
                        (entry.value is double)
                            ? entry.value.toStringAsFixed(2)
                            : entry.value.toString(),
                        textAlign: TextAlign.right,
                        style: valueStyle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
