// lib/widgets/budget_summary_item.dart

import 'package:flutter/material.dart';
import '../models/budget_category.dart';
import '../constants/app_constants.dart';

class BudgetSummaryItem extends StatelessWidget {
  final BudgetCategory category;

  const BudgetSummaryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = category.total > 0 ? category.spent / category.total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.name}: \$${category.spent.toStringAsFixed(2)} / \$${category.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppConstants.textColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
