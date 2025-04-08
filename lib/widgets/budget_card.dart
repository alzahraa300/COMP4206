import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final String value;

  const BudgetCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 120,
        width: double.infinity, // Full width
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppConstants.textColor,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: AppConstants.textColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}