import 'package:project_part1/models/budget_page_category.dart';
import 'package:project_part1/pages/reports.dart';
import 'package:project_part1/pages/transaction.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/budget_card.dart';
import '../services/budget_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/transaction_service.dart';
import 'budget.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionService _transactionService = TransactionService();
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          String firstName = userDoc['firstName'] ?? '';
          String lastName = userDoc['lastName'] ?? '';
          fullName = '$firstName $lastName';
          email = userDoc['email'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
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
                          'Welcome, ${fullName}!',
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
                  fullName,
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
                    image: AssetImage('assets/images/drawer_background.jpg'),
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
                      fullName,
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email, // Placeholder email
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
                    MaterialPageRoute(builder: (context) => TransactionScreen(uid: widget.uid)),
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
                      builder: (context) => BudgetScreen(uid: widget.uid),
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
                  builder: (context) => ReportsScreen (uid: widget.uid),
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
      body: SafeArea(
//        onRefresh: _refreshBudgets,
  //      color: AppConstants.accentColor,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            FutureBuilder<double>(
              future: _transactionService.getTotalIncome(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return BudgetCard(title: 'Income', value: 'Loading...');
                }
                if (snapshot.hasError) {
                  return BudgetCard(title: 'Income', value: 'Error');
                }
                final income = snapshot.data?.toStringAsFixed(2) ?? '0.00';
                return BudgetCard(title: 'Income', value: 'OMR $income');
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<double>(
              future: _transactionService.getTotalExpense(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return BudgetCard(title: 'Expenses', value: 'Loading...');
                }
                if (snapshot.hasError) {
                  return BudgetCard(title: 'Expenses', value: 'Error');
                }
                final expenses = snapshot.data?.toStringAsFixed(2) ?? '0.00';
                return BudgetCard(title: 'Expenses', value: 'OMR $expenses');
              },
            ),
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

                      return Column(
                        children: budgets.map((budget) =>
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${budget.category}: \$${budget.spent.toStringAsFixed(2)} / \$${budget.limit.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppConstants.textColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (budget.spent / budget.limit).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
                                minHeight: 8,
                              ),
                            Divider(
                              color: AppConstants.textColor.withOpacity(
                                  0.2),
                              thickness: 1,
                            ),
                          ],
                          )).toList(),
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppConstants.navColor,
          selectedItemColor: Colors.amber,
          unselectedItemColor: AppConstants.textColor,
          items: _navItems,

          onTap: (index) {
          if (index == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already on Home')),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionScreen(uid: widget.uid)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BudgetScreen(uid: widget.uid),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                //change to report
                builder: (context) =>  ReportsScreen(uid: widget.uid),
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
              builder: (context) => BudgetScreen(uid: widget.uid),
            ),
          );
        },
        child: const Icon(Icons.account_balance_wallet, size: 28),
      ),
    );
  }
}