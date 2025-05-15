class BudgetPageCategory {
  final String category;
  final double limit;
  final double spent;
  final String uid;

  BudgetPageCategory({
    required this.category,
    required this.limit,
    required this.spent,
    required this.uid
  });

  // Factory constructor to create from a Firestore document
  factory BudgetPageCategory.fromDoc(Map<String, dynamic> data) {
    return BudgetPageCategory(
      category: data['category'] ?? '',
      limit: (data['limit'] as num).toDouble(),
      spent: (data['spent'] as num).toDouble(),
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'spent': spent,
      'uid': uid
    };
  }
}
