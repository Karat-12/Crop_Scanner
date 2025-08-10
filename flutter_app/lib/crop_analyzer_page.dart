import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CropAnalyzerPage extends StatefulWidget {
  @override
  _CropAnalyzerPageState createState() => _CropAnalyzerPageState();
}

class _CropAnalyzerPageState extends State<CropAnalyzerPage> {
  File? _image;
  String _result = '';
  final picker = ImagePicker();

  Future pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        setState(() {
          _result = 'No image selected.';
        });
        return;
      }

      setState(() {
        _image = File(pickedFile.path);
        _result = 'Uploading...';
      });

      await uploadImage(_image!);
    } catch (e) {
      setState(() {
        _result = 'Error picking image: $e';
      });
    }
  }

  Future uploadImage(File imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/analyze'); // Change to your backend URL
    var request = http.MultipartRequest('POST', uri);

    try {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      print('Sending request to $uri ...');

      var response = await request.send();
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        print('Response body: $respStr');
        setState(() {
          _result = 'Result: $respStr';
        });
      } else {
        setState(() {
          _result = 'Error: Server returned ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Upload exception: $e');
      setState(() {
        _result = 'Exception during upload: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Analyzer'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text('No image selected.', style: TextStyle(fontSize: 18))
                  : Image.file(_image!, height: 250),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              Text(_result, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
