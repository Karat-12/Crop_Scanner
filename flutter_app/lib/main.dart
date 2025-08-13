import 'package:flutter/material.dart';
import 'crop_analyzer_page.dart'; // Import the separate page file

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
