import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_page_category.dart';

Stream<List<BudgetPageCategory>> getBudgets() {
  return FirebaseFirestore.instance
      .collection('BudgetPageCategory')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetPageCategory.fromDoc(data);
  }).toList());
}

Future<List<String>> getAllCategoryNames() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('BudgetPageCategory')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data['category'] as String;
  }).toList();
}

