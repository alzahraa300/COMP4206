import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_page_category.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final String _collection = 'BudgetPageCategory';

Stream<List<BudgetPageCategory>> getBudgets(String uid) {
  return FirebaseFirestore.instance
      .collection('BudgetPageCategory')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
    final data = doc.data();
    return BudgetPageCategory.fromDoc(data);
  }).toList());
}

Future<List<String>> getAllCategoryNames(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('BudgetPageCategory')
      .where('uid', isEqualTo: uid)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data['category'] as String;
  }).toList();
}

Future<double> getTotalSpent(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('BudgetPageCategory')
      .where('uid', isEqualTo: uid)
      .get();

  double totalSpent = 0.0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final spent = (data['spent'] as num?)?.toDouble() ?? 0.0;
    totalSpent += spent;
  }

  return totalSpent;
}

Future<void> updateSpent(String uid, String category, double amount) async {
  try {
    final query = await _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .where('category', isEqualTo: category)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first.reference;
      final currentSpent = (query.docs.first.data()['spent'] as num).toDouble();
      await doc.update({'spent': currentSpent + amount});
    }
  } catch (e) {
    print('Error updating spent: $e');
    throw Exception('Failed to update spent amount: $e');
  }
}


