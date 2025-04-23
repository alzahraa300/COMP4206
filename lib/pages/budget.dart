import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/budget_page_category.dart';
import '../pages/add_budget.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<BudgetScreen> {
  List<BudgetPageCategory> budgets = [
    BudgetPageCategory(category: 'Groceries', limit: 300, spent: 400),
    BudgetPageCategory(category: 'Entertainment', limit: 100, spent: 70),
    BudgetPageCategory(category: 'Utilities', limit: 200, spent: 150),
  ];

  String? selectedCategory;

  void _showBudgetExceededAlert(BuildContext context,String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Exceeded!', style: TextStyle(color: Colors.red),),
          content: Text('You have exceeded your budget for $category.'),
          actions: [
            TextButton( onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
              child: Text('OK', style: TextStyle(color: Colors.red),),
            ),
          ],
        );
        },
    );
  }

  void _addNewBudget(BudgetPageCategory category) {
    setState(() {
      budgets.add(category);
    });
  }

  void _deleteBudget() {
    if (selectedCategory != null) {
      setState(() {
        budgets.removeWhere((item) => item.category == selectedCategory);
        selectedCategory = null;
      });
    }
  }

  void _showAddBudgetForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewBudgetForm(onSubmit: _addNewBudget),
      ),
    );
  }

  void _editBudget() {
    if (selectedCategory != null) {
      // logic to edit
    }
  }

  // BottomNavigationBar items extracted as a constant for reusability
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Budget Management',
              style: TextStyle(
                fontSize: 24,
                color: AppConstants.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: AppConstants.gradientDecoration,
              child: Column(
                children: [
                  _buildTableHeader(),
                  Divider(color: Colors.white),
                  ...budgets.map((item) => _buildTableRow(item)).toList(),
                ],
              ),
            ),
            if (selectedCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _editBudget,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        child: Text("Edit", style: TextStyle(color: AppConstants.textColor),),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteBudget,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text("Delete", style: TextStyle(color: AppConstants.textColor),),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetForm,
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.navColor,
        selectedItemColor: Colors.amber,
        unselectedItemColor: AppConstants.textColor,
        items: _navItems
      ),

    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: const [
        Expanded(flex: 2, child: Text('Category', style: _headerStyle)),
        Expanded(flex: 2, child: Text('Limit', style: _headerStyle)),
        Expanded(flex: 2, child: Text('Spent', style: _headerStyle)),
        Expanded(flex: 2, child: Text('Remaining', style: _headerStyle)),
        Expanded(child: Text('Progress', style: _headerStyle)),
        Text("Select", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTableRow(BudgetPageCategory item) {
    double remaining = item.limit - item.spent;
    double progress = item.spent / item.limit;

    if (item.spent > item.limit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBudgetExceededAlert(context, item.category);
      });
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.category)),
          Expanded(flex: 2, child: Text('\$${item.limit.toStringAsFixed(2)}')),
          Expanded(flex: 2, child: Text('\$${item.spent.toStringAsFixed(2)}')),
          Expanded(flex: 2, child: Text('\$${remaining.toStringAsFixed(2)}')),
          Expanded(
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              color: AppConstants.accentColor,
              backgroundColor: Colors.white,
            ),
          ),
          Radio<String>(
            value: item.category,
            groupValue: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13);