import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Enumerated data type
enum Classification {
  employee,
  student,
  businessOwner,
  other,
}

// User class using the enum
class User {
  static int _idCounter = 0;
  final int _userId;

  int get userId => _userId;

  String name;
  String email;
  String passwordHash;
  Classification classification;
  DateTime dateJoined;

  // Constructor with named parameters
  User({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.classification,
    required this.dateJoined,
  }) : _userId = ++_idCounter;

  String getClassificationLabel() {
    return classification.name;
  }

}

enum TransactionType{
  income, expense;
}
enum PaymentMethod {
  creditCard, cash;
}

class Transaction {
  int transactionId;
  int userId;
  TransactionType transactionType;
  double amount;
  String description;
  String category;
  PaymentMethod payment_method;
  DateTime transaction_date;

  Transaction({
    required this.transactionId,
    this.userId = 0,
    required this.transactionType,
    required this.amount,
    required this.description,
    required this.category,
    required this.payment_method,
    required this.transaction_date,
  });


}

class _MyHomePageState extends State<MyHomePage> {
  @override  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Financial Tracker'),
      ),
      body: Container(),
    );
  }
}
