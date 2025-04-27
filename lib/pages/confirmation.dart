import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ConfirmationPage extends StatelessWidget {
  final String action;
  final String? details;

  ConfirmationPage({
    required this.action,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        title: Text("Confirmation", style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Success! $action Completed",
              style: TextStyle(fontSize: 24, color: AppConstants.textColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (details != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  details!,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
