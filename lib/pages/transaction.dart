import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/budget_page_category.dart';
import '../models/transactions.dart';
import '../services/budget_services.dart';
import '../services/transaction_service.dart';
import 'confirmation.dart';

class TransactionScreen extends StatefulWidget {
  final String uid;
  const TransactionScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late final TransactionService _transactionService;
  String _selectedType = 'Income';
  final List<String> _types = ['Income', 'Expense'];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  String? _selectedCategory; // Changed to nullable to handle initial null state
  List<String> _categories = []; // Initial default categories

  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer'];

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isCategoriesLoading = true; // Track category loading state
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final budgetCategories = await getAllCategoryNames(widget.uid);
    setState(() {
      _categories = budgetCategories;
      _selectedCategory = budgetCategories.isNotEmpty ? budgetCategories.first : null;
      _isCategoriesLoading = false;
    });
  }


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

  Future<void> _checkBudget() async {
    if (_selectedType == 'Expense') {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      try {
        final budgets = await getBudgets(widget.uid).first;
        final budget = budgets.firstWhere(
              (b) => b.category == _selectedCategory,
          orElse: () => BudgetPageCategory(category: _selectedCategory!, limit: 0.0, spent: 0.0, uid:widget.uid),
        );

        final newSpent = budget.spent + amount;
        if (budget.limit > 0 && newSpent > budget.limit) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Budget Warning'),
              content: Text(
                'Adding this expense (${amount.toStringAsFixed(2)}) will exceed the budget limit (${budget.limit.toStringAsFixed(2)}) for $_selectedCategory by ${(newSpent - budget.limit).toStringAsFixed(2)}. Proceed?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveTransaction(); // Proceed with saving
                  },
                  child: const Text('Proceed'),
                ),
              ],
            ),
          );
        } else {
          _saveTransaction(); // Budget is under the limit, proceed
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking budget: $e')),
          );
        }
      }
    } else {
      _saveTransaction(); // Not an expense, save directly
    }
  }


  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      await _transactionService.addTransaction(
        amount: amount,
        description: _descriptionController.text,
        paymentMethod: _selectedPaymentMethod,
        transactionDate: _selectedDate,
        transactionType: _selectedType,
        category: _selectedCategory!,
        uid: widget.uid
      );

      final budgets = await getBudgets(widget.uid).first;
      final selectedBudget = budgets.firstWhere(
            (budget) => budget.category == _selectedCategory,
        orElse: () => throw Exception('Selected category not found in budgets.'),
      );

      final newSpent = selectedBudget.spent + amount;
      final updatedBudget = selectedBudget.copyWith(spent: newSpent);

      await updateSpent(widget.uid, _selectedCategory!, amount);


      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(
            action: 'Transaction Added',
            details: 'Amount: ${_amountController.text}\n'
                'Type: $_selectedType\n'
                'Category: $_selectedCategory\n'
                'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        child: _isCategoriesLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type:', style: TextStyle(color: AppConstants.textColor)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Income', style: TextStyle(color: AppConstants.textColor)),
                        value: 'Income',
                        groupValue: _selectedType,
                        onChanged: (String? value) => setState(() => _selectedType = value!),
                        activeColor: AppConstants.accentColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Expense', style: TextStyle(color: AppConstants.textColor)),
                        value: 'Expense',
                        groupValue: _selectedType,
                        onChanged: (String? value) => setState(() => _selectedType = value!),
                        activeColor: AppConstants.accentColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Amount:', style: TextStyle(color: AppConstants.textColor)),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Amount is required';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    if (double.parse(value) <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money, color: AppConstants.textColor),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppConstants.textColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppConstants.textColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppConstants.accentColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  style: const TextStyle(color: AppConstants.textColor),
                ),
                const SizedBox(height: 16),

                const Text('Description:', style: TextStyle(color: AppConstants.textColor)),
                TextFormField(
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
                      borderSide: BorderSide(color: AppConstants.textColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppConstants.textColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppConstants.accentColor),
                    ),
                  ),
                  style: const TextStyle(color: AppConstants.textColor),
                ),
                const SizedBox(height: 16),



                const Text('Category:', style: TextStyle(color: AppConstants.textColor)),
                DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppConstants.primaryColor.withOpacity(0.9),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(color: AppConstants.textColor)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
                  style: const TextStyle(color: AppConstants.textColor),
                  underline: Container(height: 1, color: AppConstants.textColor.withOpacity(0.3)),
                  hint: const Text('Select a category', style: TextStyle(color: AppConstants.textColor)),
                ),
                const SizedBox(height: 8),



                const Text('Payment Method:', style: TextStyle(color: AppConstants.textColor)),
                DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  dropdownColor: AppConstants.primaryColor.withOpacity(0.9),
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: const TextStyle(color: AppConstants.textColor)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) => setState(() => _selectedPaymentMethod = newValue!),
                  style: const TextStyle(color: AppConstants.textColor),
                  underline: Container(height: 1, color: AppConstants.textColor.withOpacity(0.3)),
                ),
                const SizedBox(height: 16),

                const Text('Date:', style: TextStyle(color: AppConstants.textColor)),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: AppConstants.textColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: const TextStyle(color: AppConstants.textColor),
                        ),
                        const Icon(Icons.calendar_today, color: AppConstants.textColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                          : const Text('Save'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}