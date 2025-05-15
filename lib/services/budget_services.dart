import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_page_category.dart';

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


