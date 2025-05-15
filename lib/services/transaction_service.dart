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
    final transaction = Transactions(
      transaction_id: const Uuid().v4(),
      amount: amount,
      description: description,
      payment_method: paymentMethod,
      transaction_date: transactionDate,
      transaction_type: transactionType,
      uid: uid, // Removed authentication dependency
    );

    await _firestore
        .collection(_transactionsCollection)
        .doc(transaction.transaction_id)
        .set(transaction.toMap());
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



  Future<double> getTotalIncome(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'income')
        .get();

    double totalIncome = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      totalIncome += amount;
    }

    return totalIncome;
  }


  Future<double> getTotalExpense(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'expense')
        .get();

    double totalExpense = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      totalExpense += amount;
    }

    return totalExpense;
  }}