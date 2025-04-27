import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedType = 'Income';
  final List<String> _types = ['Income', 'Expense'];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Groceries';
  final List<String> _categories = ['Groceries', 'Entertainment', 'Bills'];

  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer'];

  DateTime _selectedDate = DateTime.now();

  // Controller for the custom category input
  final TextEditingController _customCategoryController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppConstants.accentColor,
              onPrimary: AppConstants.textColor,
              surface: AppConstants.primaryColor,
              onSurface: AppConstants.textColor,
            ),
            dialogBackgroundColor: AppConstants.primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to show dialog and add custom category
  Future<void> _addCustomCategory(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Category'),
          backgroundColor: AppConstants.primaryColor,
          titleTextStyle: TextStyle(color: AppConstants.textColor),
          content: TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              hintStyle: TextStyle(color: AppConstants.textColor.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppConstants.textColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppConstants.textColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppConstants.accentColor,
                ),
              ),
            ),
            style: TextStyle(color: AppConstants.textColor),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add', style: TextStyle(color: AppConstants.accentColor)),
              onPressed: () {
                if (_customCategoryController.text.isNotEmpty) {
                  setState(() {
                    _categories.add(_customCategoryController.text);
                    _selectedCategory = _customCategoryController.text;
                  });
                  _customCategoryController.clear();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category "${_selectedCategory}" added!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        title: const Text('Add Transaction', style: TextStyle(color: AppConstants.textColor)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Radio Buttons
            Text('Type:', style: TextStyle(color: AppConstants.textColor)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Income', style: TextStyle(color: AppConstants.textColor)),
                    value: 'Income',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: AppConstants.accentColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Expense', style: TextStyle(color: AppConstants.textColor)),
                    value: 'Expense',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: AppConstants.accentColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Field
            Text('Amount:', style: TextStyle(color: AppConstants.textColor)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money, color: AppConstants.textColor),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppConstants.textColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppConstants.textColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppConstants.accentColor,
                  ),
                ),
              ),
              style: TextStyle(color: AppConstants.textColor),
            ),
            const SizedBox(height: 16),

            // Description Field (Now Multi-line)
            Text('Description:', style: TextStyle(color: AppConstants.textColor)),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Enter your notes here...',
                hintStyle: TextStyle(color: AppConstants.textColor.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppConstants.textColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppConstants.textColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppConstants.accentColor,
                  ),
                ),
              ),
              style: TextStyle(color: AppConstants.textColor),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            Text('Category:', style: TextStyle(color: AppConstants.textColor)),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: AppConstants.primaryColor.withOpacity(0.9),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: TextStyle(color: AppConstants.textColor)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              style: TextStyle(color: AppConstants.textColor),
              underline: Container(
                height: 1,
                color: AppConstants.textColor.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 8),

            // Add Custom Category Button
            ElevatedButton(
              onPressed: () {
                _addCustomCategory(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Custom Category'),
            ),
            const SizedBox(height: 16),

            // Payment Method Dropdown
            Text('Payment Method:', style: TextStyle(color: AppConstants.textColor)),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              isExpanded: true,
              dropdownColor: AppConstants.primaryColor.withOpacity(0.9),
              items: _paymentMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method, style: TextStyle(color: AppConstants.textColor)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              style: TextStyle(color: AppConstants.textColor),
              underline: Container(
                height: 1,
                color: AppConstants.textColor.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            Text('Date:', style: TextStyle(color: AppConstants.textColor)),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppConstants.textColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: TextStyle(color: AppConstants.textColor),
                    ),
                    Icon(Icons.calendar_today, color: AppConstants.textColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save and Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction Saved!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}