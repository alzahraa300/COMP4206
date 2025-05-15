import 'package:project_part1/pages/reports.dart';
import 'package:project_part1/pages/transaction.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
//import '../pages/transaction.dart';
import '../models/budget_page_category.dart';
import '../pages/add_budget.dart';
import '../pages/confirmation.dart';
import '../services/budget_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class BudgetScreen extends StatefulWidget {
  final String uid;
  const BudgetScreen({Key? key, required this.uid}) : super(key: key);
  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<BudgetScreen> {

  String? selectedCategory;
  bool _hasShownExceededAlert = false;

  void SnackBarMessenger(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

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

  void _deleteBudget() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('BudgetPageCategory')
          .where('category', isEqualTo: selectedCategory).get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          await doc.reference.delete(); //delete one document
          SnackBarMessenger(context, "Deleted ${selectedCategory} budget successfully.");
        }
      } else {  print('No budget found with category: $selectedCategory');  }
    } catch (e) { print('Error deleting budget: $e');  }
  }


  void _showAddBudgetForm() async {
    List<String> existingCategories = [];

    existingCategories = await getAllCategoryNames(widget.uid);
    setState(() {}); // if you're in a StatefulWidget

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewBudgetForm(
          existingCategories: existingCategories,
          uid: widget.uid,
        ),
      ),
    );

    if (result == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(
            action: "New Budget Added",
            details: "Your budget has been successfully set.",
          ),
        ),
      );

    }
  }


  // BottomNavigationBar items extracted as a constant for reusability
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        title: const Text('Budget Management', style: TextStyle(color: AppConstants.textColor)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  StreamBuilder<List<BudgetPageCategory>>(
                    stream: getBudgets(widget.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No budgets found", style: TextStyle(color: Colors.white));
                      }

                      final budgets = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: budgets.length,
                        itemBuilder: (context, index) {
                          final budget = budgets[index];
                          double remaining = budget.limit - budget.spent;
                          double progress = budget.spent / budget.limit;

                          if (budget.spent > budget.limit && !_hasShownExceededAlert) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showBudgetExceededAlert(context, budget.category);
                              _hasShownExceededAlert = true;
                            });
                          }

                          return ListTile(
                            title: Text(budget.category, style: TextStyle(color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Limit: \$${budget.limit.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                Text('Spent: \$${budget.spent.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                Text('Remaining: \$${remaining.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: progress > 1.0 ? 1.0 : progress,
                                  color: AppConstants.accentColor,
                                  backgroundColor: Colors.grey[300],
                                ),

                              ],
                            ),
                            trailing: Radio<String>(
                              value: budget.category,
                              groupValue: selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            if (selectedCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  children: [
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.navColor,
        selectedItemColor: Colors.amber,
        unselectedItemColor: AppConstants.textColor,
        items: _navItems,

        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(uid: widget.uid), // Pass userName
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionScreen(uid: widget.uid)),
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already on Budget')),
            );
          } /*else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                //change to report
                builder: (context) => ReportsScreen(uid: widget.uid),
              ),
            );
          }*/
        },
      ),

    );
  }
}

