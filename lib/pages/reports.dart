import 'package:project_part1/pages/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import 'budget.dart';
import 'home.dart';

class ReportsScreen extends StatelessWidget {
  String uid='';
  final String userName; // Add this parameter
  ReportsScreen({Key? key, required this.userName}) : super(key: key);
  final double totalIncome = 1500;
  final double totalExpenses = 600;

  final Map<String, double> categorySpending = {
    'Groceries': 300,
    'Entertainment': 100,
    'Utilities': 200,
  };

  // BottomNavigationBar items extracted as a constant for reusability
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    final double spendingPercentage = (totalExpenses / totalIncome) * 100;
    final double netSavings = totalIncome - totalExpenses;

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
            SizedBox(height: 20),
            _buildBarChart(context, netSavings),
            SizedBox(height: 30),
            Text("Detailed Financial Report", style: _sectionTitleStyle),
            SizedBox(height: 10),
            _buildFinancialSummary(spendingPercentage, netSavings),
            SizedBox(height: 30),
            Text("Actionable Insights", style: _sectionTitleStyle),
            SizedBox(height: 10),
            _buildInsights(),
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
                builder: (context) => HomeScreen(uid: uid), // Pass userName
              ),
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
                builder: (context) => BudgetScreen(uid: uid),
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

  Widget _buildPieChart(BuildContext context) {
    final total = categorySpending.values.reduce((a, b) => a + b);
    return Card(
      color: Colors.blue.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Spending Breakdown by Category", style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categorySpending.entries.map((entry) {
                    final percent = entry.value / total;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${(percent * 100).toStringAsFixed(1)}%',
                      color: Colors.primaries[categorySpending.keys.toList().indexOf(entry.key) % Colors.primaries.length],
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
  }

  Widget _buildBarChart(BuildContext context, netSavings) {
    return Card(
      color: Colors.blue.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Income vs Expense", style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold)),
            SizedBox(height:20),
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
                      topTitles: AxisTitles()
                  ),
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

  Widget _buildFinancialSummary(spendingPercentage, netSavings) {
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

  Widget _buildInsights() {
    Map<String, String> tips = {};
    if (totalExpenses > totalIncome * 0.8) {
      tips["Warning: You are spending more than 80% of your income."] = "💡Review your spending habits monthly to identify patterns. Recognizing consistent overspending early can help you adjust your behavior before it becomes a serious problem.";
    } else if (totalExpenses > totalIncome * 0.5) {
      tips["Good: Try to optimize your expenses further."] = "💡Keep an eye on growing expenses in specific categories over time. Gradually rising bills could signal inefficiencies, waste, or new habits that need attention.";
    } else {
      tips["Excellent: You are managing your finances well!"] = "💡Regularly monitor your overall financial performance, not just individual expenses. Consistent tracking builds awareness and motivates smarter financial decisions.";
    }

    return Column(
      children: tips.entries.map((tip) => Card(
        color: Colors.amber[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column (
            children: [
              Text(tip.key, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              Text(tip.value, style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      )
      ).toList(),
    );
  }

  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppConstants.textColor,
  );
}


