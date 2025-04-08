import 'package:flutter/material.dart';
import '../models/budget_category.dart';
import '../constants/app_constants.dart';

class BudgetSummaryItem extends StatelessWidget {
  final BudgetCategory category;

  const BudgetSummaryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    double progress = category.spent / category.total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.name}: \$${category.spent.toStringAsFixed(2)} / \$${category.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppConstants.textColor,
              fontSize: 18, // Larger font size
            ),
          ),
          SizedBox(height: 8), // Increased spacing
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}