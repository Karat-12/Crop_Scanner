import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    } catch (e, stackTrace) {
      print('Error in pickImage: $e');
      print(stackTrace);
      setState(() {
        _result = 'Error picking image: $e';
      });
    }
  }

Future uploadImage(File imageFile) async {
  final uri = Uri.parse('http://10.0.2.2:8080/api/crop/analyze');  // Correct endpoint
  var request = http.MultipartRequest('POST', uri);

  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));  // Correct param name

  try {
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Crop Analyze')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ? Text('No image selected.') : Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(onPressed: pickImage, child: Text('Pick Image')),
              SizedBox(height: 20),
              Text(_result),
            ],
          ),
        ),
      ),
    );
  }
}
