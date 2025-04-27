import 'package:comp4206ver3/pages/reports.dart';
import 'package:comp4206ver3/pages/transaction.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/budget_card.dart';
import '../models/budget_category.dart';
import '../widgets/budget_summary_item.dart';
import 'budget.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BudgetCategory> budgetCategories = [
    BudgetCategory(name: 'Groceries', spent: 200.00, total: 300.00),
    BudgetCategory(name: 'Entertainment', spent: 100.00, total: 150.00),
    BudgetCategory(name: 'Transportation', spent: 50.00, total: 100.00),
  ];

  void _addCategory(String name, double spent, double total) {
    setState(() {
      budgetCategories.add(BudgetCategory(name: name, spent: spent, total: total));
    });
  }

  // Refresh budget data (placeholder for actual data refresh logic)
  Future<void> _refreshBudgets() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() {
      // Optionally update budgetCategories here with fresh data
    });
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppConstants.textColor),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showMaterialBanner(
                      MaterialBanner(
                        content: Text(
                          'Welcome, ${widget.userName}!',
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
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.userName,
                  style: TextStyle(color: AppConstants.accentColor),
                ),
              ],
            ),
            Image.asset(
              'assets/images/logo-background.png',
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported,
                color: AppConstants.textColor,
                size: 50,
              ), // Fallback if asset fails to load
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppConstants.primaryColor,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/drawer_background.jpg'), // Add this asset to your project
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppConstants.accentColor,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userName,
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.userName.toLowerCase()}@gmail.com', // Placeholder email
                      style: TextStyle(
                        color: AppConstants.textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: AppConstants.textColor),
                title: Text('Home', style: TextStyle(color: AppConstants.textColor)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Already on Home')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.receipt, color: AppConstants.textColor),
                title: Text('Transactions', style: TextStyle(color: AppConstants.textColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet, color: AppConstants.textColor),
                title: Text('Budget', style: TextStyle(color: AppConstants.textColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetScreen(userName: widget.userName),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart, color: AppConstants.textColor),
                title: Text('Reports', style: TextStyle(color: AppConstants.textColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => ReportsScreen(),
                  ),
                  );
                  },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppConstants.textColor),
                title: Text('Logout', style: TextStyle(color: AppConstants.textColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBudgets,
        color: AppConstants.accentColor,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const BudgetCard(title: 'Income', value: 'OMR 1500.00'),
            const SizedBox(height: 20),
            const BudgetCard(title: 'Expenses', value: 'OMR 350.00'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.textColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Summary',
                    style: TextStyle(
                      color: AppConstants.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  budgetCategories.isEmpty
                      ? Center(
                    child: Text(
                      'No budget categories added yet.',
                      style: TextStyle(
                        color: AppConstants.textColor.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  )
                      : Column(
                    children: budgetCategories.map((category) => Column(
                      children: [
                        BudgetSummaryItem(category: category),
                        Divider(
                          color: AppConstants.textColor.withOpacity(0.2),
                          thickness: 1,
                        ),
                      ],
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: AppConstants.accentColor,
        unselectedItemColor: AppConstants.textColor.withOpacity(0.6),
        items: _navItems,
        onTap: (index) {
          if (index == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already on Home')),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransactionScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BudgetScreen(userName: widget.userName),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                //change to report
                builder: (context) => ReportsScreen(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetScreen(userName: widget.userName),
            ),
          );
        },
        child: const Icon(Icons.account_balance_wallet, size: 28),
      ),
    );
  }
}