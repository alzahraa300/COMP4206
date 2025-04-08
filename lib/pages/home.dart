import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/budget_category.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_summary_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BudgetCategory> budgetCategories = [
    BudgetCategory(name: 'Groceries', spent: 200.00, total: 300.00),
    BudgetCategory(name: 'Entertainment', spent: 100.00, total: 150.00),
    BudgetCategory(name: 'Transportation', spent: 50.00, total: 100.00),
  ];

  // Method to add a new budget category dynamically
  void _addCategory(String name, double spent, double total) {
    setState(() {
      budgetCategories.add(BudgetCategory(name: name, spent: spent, total: total));
    });
  }

  // BottomNavigationBar items extracted as a constant for reusability
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    // Show MaterialBanner when user icon is pressed
                    ScaffoldMessenger.of(context).showMaterialBanner(
                      MaterialBanner(
                        content: Text(
                          'Welcome, Al Zahraa!',
                          style: TextStyle(color: AppConstants.textColor),
                        ),
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.9),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                            },
                            child: Text(
                              'Dismiss',
                              style: TextStyle(color: AppConstants.accentColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                SizedBox(width: 10),
                Text('Al Zahraa'),
              ],
            ),
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings pressed')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetCard(title: 'Income', value: '\$1500.00'),
            SizedBox(height: 20),
            BudgetCard(title: 'Expenses', value: '\$350.00'),
            SizedBox(height: 20),
            BudgetCard(title: 'Savings Goals', value: '70% towards goal'),
            SizedBox(height: 30),
            Text(
              'Budget Summary',
              style: TextStyle(
                color: AppConstants.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            // Budget summary items with dividers
            ...budgetCategories.map((category) => Column(
              children: [
                BudgetSummaryItem(category: category),
                Divider(
                  color: AppConstants.textColor.withOpacity(0.2),
                  thickness: 1,
                ),
              ],
            )).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: AppConstants.accentColor,
        unselectedItemColor: AppConstants.textColor,
        items: _navItems,
        onTap: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigated to ${_navItems[index].label}')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.accentColor,
        onPressed: () {
          _addCategory('New Category ${budgetCategories.length + 1}', 0.0, 100.0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New budget category added!')),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}