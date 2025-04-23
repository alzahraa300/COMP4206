import 'package:flutter/material.dart';
import '../models/budget_page_category.dart';


class NewBudgetForm extends StatefulWidget {
  final Function(BudgetPageCategory) onSubmit;

  NewBudgetForm({required this.onSubmit});

  @override
  _NewBudgetFormState createState() => _NewBudgetFormState();
}

class _NewBudgetFormState extends State<NewBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String _category = '';
  double _limit = 0.0;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(BudgetPageCategory(category: _category, limit: _limit, spent: 0.0));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();}}