import 'package:project_part1/pages/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_page_category.dart';
import '../services/budget_services.dart';
import 'budget.dart';
import 'home.dart';
import '../services/transaction_service.dart'; // Import TransactionService
import 'package:intl/intl.dart'; // For date formatting

class ReportsScreen extends StatefulWidget {
  final String uid;

  const ReportsScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TransactionService _transactionService = TransactionService(); // Initialize TransactionService

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
        title: Text("Financial Insights & Reports", style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Visual Summary", style: _sectionTitleStyle),
            SizedBox(height: 10),
            _buildPieChart(context),
            SizedBox(height: 10),
            StreamBuilder<double>(
              stream: _transactionService.getTotalIncome(widget.uid),
              builder: (context, incomeSnapshot) {
                return StreamBuilder<double>(
                  stream: _transactionService.getTotalExpense(widget.uid),
                  builder: (context, expenseSnapshot) {
                    if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final double totalIncome = incomeSnapshot.data!;
                    final double totalExpenses = expenseSnapshot.data!;
                    final double netSavings = totalIncome - totalExpenses;

                    return _buildBarChart(context, totalIncome, totalExpenses, netSavings);
                  },
                );
              },
            ),
            SizedBox(height: 30),
            Text("Detailed Financial Report", style: _sectionTitleStyle),
            SizedBox(height: 10),
            StreamBuilder<double>(
              stream: _transactionService.getTotalIncome(widget.uid),
              builder: (context, incomeSnapshot) {
                return StreamBuilder<double>(
                  stream: _transactionService.getTotalExpense(widget.uid),
                  builder: (context, expenseSnapshot) {
                    if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final double totalIncome = incomeSnapshot.data!;
                    final double totalExpenses = expenseSnapshot.data!;
                    final double netSavings = totalIncome - totalExpenses;
                    final double spendingPercentage = (totalExpenses / totalIncome) * 100;

                    return _buildFinancialSummary(spendingPercentage, totalIncome, totalExpenses, netSavings);
                  },
                );
              },
            ),
            SizedBox(height: 30),
            Text("Actionable Insights", style: _sectionTitleStyle),
            SizedBox(height: 10),
            StreamBuilder<double>(
              stream: _transactionService.getTotalIncome(widget.uid),
              builder: (context, incomeSnapshot) {
                return StreamBuilder<double>(
                  stream: _transactionService.getTotalExpense(widget.uid),
                  builder: (context, expenseSnapshot) {
                    if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final double totalIncome = incomeSnapshot.data!;
                    final double totalExpenses = expenseSnapshot.data!;

                    return _buildInsights(totalIncome, totalExpenses);
                  },
                );
              },
            ),

            SizedBox(height: 30),

            // New Section: ListView for Recent Transactions
            Text("Recent Transactions", style: _sectionTitleStyle),
            SizedBox(height: 10),
            _buildTransactionList(),
            SizedBox(height: 30),

            // New Section: GridView for Budget Categories
            Text("Budget Categories", style: _sectionTitleStyle),
            SizedBox(height: 10),
            _buildCategoryGrid(),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(uid: widget.uid),
              ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already on Reports')),
            );
          }
        },
      ),
    );
  }

  // Existing Methods (Unchanged)
  Widget _buildPieChart(BuildContext context) {
    return StreamBuilder<List<BudgetPageCategory>>(
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
        final categorySpending = <String, double>{};

        for (var budget in budgets) {
          final category = budget.category;
          final spent = budget.spent;
          if (categorySpending.containsKey(category)) {
            categorySpending[category] = categorySpending[category]! + spent;
          } else {
            categorySpending[category] = spent;
          }
        }

        final total = categorySpending.values.fold(0.0, (a, b) => a + b);

        return Card(
          color: Colors.blue.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  "Spending Breakdown by Category",
                  style: TextStyle(
                    color: AppConstants.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: categorySpending.entries.map((entry) {
                        final percent = entry.value / total;
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${(percent * 100).toStringAsFixed(1)}%',
                          color: Colors.primaries[
                          categorySpending.keys.toList().indexOf(entry.key) %
                              Colors.primaries.length],
                          radius: 50,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: List.generate(categorySpending.length, (index) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.primaries[index % Colors.primaries.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          categorySpending.keys.elementAt(index),
                          style: TextStyle(color: AppConstants.textColor),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(BuildContext context, double totalIncome, double totalExpenses, double netSavings) {
    return Card(
      color: Colors.blue.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Income vs Expense", style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: (totalIncome > totalExpenses ? totalIncome : totalExpenses) + 200,
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Text('Income');
                              case 1:
                                return Text('Expenses');
                              default:
                                return Text('');
                            }
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles()),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalIncome,
                          color: Colors.greenAccent,
                          width: 30,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpenses,
                          color: Colors.redAccent,
                          width: 30,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                  groupsSpace: 50,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Net Savings: \$${netSavings.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: netSavings >= 0 ? Color(0xFF006400) : Color(0xFF8B0000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(spendingPercentage, double totalIncome, double totalExpenses, double netSavings) {
    return Card(
      color: Colors.blue.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Total Income: \$${totalIncome.toStringAsFixed(2)}\n'
              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}\n'
              'Remaining Balance: \$${netSavings.toStringAsFixed(2)}\n'
              'Financial Health: ${spendingPercentage.toStringAsFixed(1)}% of income spent',
          style: TextStyle(color: AppConstants.textColor),
        ),
      ),
    );
  }

  Widget _buildInsights(double totalIncome, double totalExpenses) {
    Map<String, String> tips = {};
    if (totalExpenses > totalIncome * 0.8) {
      tips["Warning: You are spending more than 80% of your income."] =
      "💡Review your spending habits monthly to identify patterns. Recognizing consistent overspending early can help you adjust your behavior before it becomes a serious problem.";
    } else if (totalExpenses > totalIncome * 0.5) {
      tips["Good: Try to optimize your expenses further."] =
      "💡Keep an eye on growing expenses in specific categories over time. Gradually rising bills could signal inefficiencies, waste, or new habits that need attention.";
    } else {
      tips["Excellent: You are managing your finances well!"] =
      "💡Regularly monitor your overall financial performance, not just individual expenses. Consistent tracking builds awareness and motivates smarter financial decisions.";
    }

    return Column(
      children: tips.entries
          .map((tip) => Card(
        color: Colors.amber[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(tip.key,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic)),
              Text(tip.value, style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ))
          .toList(),
    );
  }

  // New Method: ListView for Recent Transactions
  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionService.getTransactionsStream(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No transactions found", style: TextStyle(color: Colors.white));
        }

        final transactions = snapshot.data!.docs;

        return Container(
          height: 200, // Fixed height for the ListView
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index].data() as Map<String, dynamic>;
              final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
              final type = transaction['transactionType'] as String? ?? 'Unknown';
              final category = transaction['category'] as String? ?? 'Uncategorized';
              final date = (transaction['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final description = transaction['description'] as String? ?? 'No description';

              return Card(
                color: Colors.blue.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: type == 'Income' ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '$type: \$${amount.toStringAsFixed(2)}',
                    style: TextStyle(color: AppConstants.textColor),
                  ),
                  subtitle: Text(
                    'Category: $category\nDate: ${DateFormat('dd/MM/yyyy').format(date)}',
                    style: TextStyle(color: AppConstants.textColor.withOpacity(0.7)),
                  ),
                  onTap: () {
                    _showTransactionDetails(context, transaction);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // New Method: GridView for Budget Categories
  Widget _buildCategoryGrid() {
    return StreamBuilder<List<BudgetPageCategory>>(
      stream: getBudgets(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No budgets found", style: TextStyle(color: Colors.white));
        }

        final budgets = snapshot.data!;

        return Container(
          height: 200, // Fixed height for the GridView
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5, // Adjust the aspect ratio for better appearance
            ),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                color: Colors.blue.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    _showCategoryDetails(context, budget);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          budget.category,
                          style: TextStyle(
                            color: AppConstants.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Spent: \$${budget.spent.toStringAsFixed(2)}',
                          style: TextStyle(color: AppConstants.textColor),
                        ),
                        Text(
                          'Limit: \$${budget.limit.toStringAsFixed(2)}',
                          style: TextStyle(color: AppConstants.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // New Method: Show Transaction Details in Bottom Sheet
  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final type = transaction['transactionType'] as String? ?? 'Unknown';
    final category = transaction['category'] as String? ?? 'Uncategorized';
    final date = (transaction['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final description = transaction['description'] as String? ?? 'No description';
    final paymentMethod = transaction['paymentMethod'] as String? ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: TextStyle(
                  color: AppConstants.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('Type: $type', style: TextStyle(color: AppConstants.textColor)),
              Text('Amount: \$${amount.toStringAsFixed(2)}', style: TextStyle(color: AppConstants.textColor)),
              Text('Category: $category', style: TextStyle(color: AppConstants.textColor)),
              Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}', style: TextStyle(color: AppConstants.textColor)),
              Text('Payment Method: $paymentMethod', style: TextStyle(color: AppConstants.textColor)),
              Text('Description: $description', style: TextStyle(color: AppConstants.textColor)),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // New Method: Show Category Details in Bottom Sheet
  void _showCategoryDetails(BuildContext context, BudgetPageCategory budget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Details',
                style: TextStyle(
                  color: AppConstants.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('Category: ${budget.category}', style: TextStyle(color: AppConstants.textColor)),
              Text('Spent: \$${budget.spent.toStringAsFixed(2)}', style: TextStyle(color: AppConstants.textColor)),
              Text('Limit: \$${budget.limit.toStringAsFixed(2)}', style: TextStyle(color: AppConstants.textColor)),
              Text(
                'Remaining: \$${((budget.limit - budget.spent) > 0 ? (budget.limit - budget.spent) : 0).toStringAsFixed(2)}',
                style: TextStyle(color: AppConstants.textColor),
              ),
              Text(
                'Status: ${budget.spent > budget.limit ? "Over Budget" : "Within Budget"}',
                style: TextStyle(
                  color: budget.spent > budget.limit ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppConstants.textColor,
  );
}