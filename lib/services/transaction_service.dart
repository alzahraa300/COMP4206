import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/transactions.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _transactionsCollection = 'transactions';
  final String _categoriesCollection = 'categories';

  Future<void> addTransaction({
    required double amount,
    required String description,
    required String paymentMethod,
    required DateTime transactionDate,
    required String transactionType,
    required String category,
    required String uid,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
      'amount': amount,
      'description': description,
      'paymentMethod': paymentMethod,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'transactionType': transactionType, // "Income" or "Expense"
      'category': category,
      'uid': uid,
    });
  }

  Future<List<Transactions>> getTransactions() async {
    final snapshot = await _firestore
        .collection(_transactionsCollection)
        .orderBy('transaction_date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Transactions.fromDoc(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addCustomCategory(String categoryName) async {
    final categoryDoc = _firestore.collection(_categoriesCollection).doc(categoryName);
    await categoryDoc.set({
      'name': categoryName,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Retrieve categories
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore
        .collection(_categoriesCollection)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();

  }

  Stream<double> getTotalIncome(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('transactionType', isEqualTo: 'Income')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final amount = (doc['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }
      print('Income total: $total'); // Debug
      return total;
    });
  }

  Stream<double> getTotalExpense(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('transactionType', isEqualTo: 'Expense')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final amount = (doc['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }
      print('Expense total: $total'); // Debug
      return total;
    });
  }
  Stream<QuerySnapshot> getTransactionsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('transactionDate', descending: true) // Sort by date, newest first
        .limit(10) // Limit to 10 recent transactions
        .snapshots();
  }



}