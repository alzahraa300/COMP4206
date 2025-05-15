import 'package:cloud_firestore/cloud_firestore.dart';

class Transactions {
  final String transaction_id;
  final double amount;
  final String description;
  final String payment_method;
  final DateTime transaction_date;
  final String transaction_type;
  final String? uid; // Made optional

  Transactions({
    required this.transaction_id,
    required this.amount,
    required this.description,
    required this.payment_method,
    required this.transaction_date,
    required this.transaction_type,
    this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transaction_id,
      'amount': amount,
      'description': description,
      'payment_method': payment_method,
      'transaction_date': transaction_date,
      'transaction_type': transaction_type,
      'uid': uid,
    };
  }

  factory Transactions.fromDoc(Map<String, dynamic> doc) {
    return Transactions(
      transaction_id: doc['transaction_id'],
      amount: doc['amount'],
      description: doc['description'],
      payment_method: doc['payment_method'],
      transaction_date: (doc['transaction_date'] as Timestamp).toDate(),
      transaction_type: doc['transaction_type'],
      uid: doc['uid'],
    );
  }
}