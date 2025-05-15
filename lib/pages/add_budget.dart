import 'package:flutter/material.dart';
import '../models/budget_page_category.dart';
import '../constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NewBudgetForm extends StatefulWidget {
  final List<String> existingCategories;
  final String uid;

  NewBudgetForm({required this.existingCategories, required this.uid});

  @override
  _NewBudgetFormState createState() => _NewBudgetFormState();
}

class _NewBudgetFormState extends State<NewBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String _category = '';
  double _limit = 0.0;

  void add_new_budget(newBudget){
    FirebaseFirestore.instance.collection('BudgetPageCategory')
      .doc().set(newBudget.toMap()).then<void>((dynamic doc) {
      print('Budget added: $doc');
    }).catchError((dynamic error) {
      print('Error! $error');
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      BudgetPageCategory newBudget = BudgetPageCategory(category: _category, limit: _limit, spent: 0.0, uid: widget.uid);
      add_new_budget(newBudget);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text('Add New Budget',
          style: TextStyle(
            fontSize: 24,
            color: AppConstants.textColor,
            fontWeight: FontWeight.bold,
          ),),
        iconTheme: IconThemeData(
          color: AppConstants.textColor, // Change the back button color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: AppConstants.textColor),
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: AppConstants.textColor),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  final category_value = value.toLowerCase();
                  if (widget.existingCategories
                      .map((e) => e.toLowerCase())
                      .contains(category_value)) {
                    return 'Category already exists';
                  }
                  return null;
                },
                onSaved: (value) => _category = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: AppConstants.textColor),
                decoration: InputDecoration(
                  labelText: 'Budget Limit',
                  labelStyle: TextStyle(color: AppConstants.textColor),
                  prefix: Text("\$ ", style: TextStyle(color: AppConstants.textColor)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Budget must be a positive number';
                  }
                  return null;
                },
                onSaved: (value) => _limit = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Budget', style: TextStyle(color: AppConstants.textColor)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}