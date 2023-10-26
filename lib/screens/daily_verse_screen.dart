import 'package:flutter/material.dart';

class QuranVerseScreen extends StatelessWidget {
  const QuranVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Quran Verse')),
      body:const  Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arabic Verse Here', // Retrieve and place the Arabic verse here
              style: TextStyle(
                fontSize: 24,
                fontFamily:
                    'Your Arabic Font Family', // If you have a specific font for Arabic
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 16),
            Text(
              'Urdu Translation Here', // Retrieve and place the Urdu translation here
              style: TextStyle(
                fontSize: 20,
                fontFamily:
                    'Your Urdu Font Family', // If you have a specific font for Urdu
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 16),
            Text(
              'English Translation Here', // Retrieve and place the English translation here
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Your English Font Family',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
