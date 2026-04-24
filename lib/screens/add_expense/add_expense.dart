import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:xpenzo/models/expense_model.dart';
import 'package:xpenzo/providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Others",
  ];

  String? selectedCategory;
  DateTime? selectedDate;

  // category icons
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Travel': return Icons.directions_car;
      case 'Shopping': return Icons.shopping_bag;
      case 'Bills': return Icons.receipt_long;
      default: return Icons.more_horiz;
    }
  }

  // category colors
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.green;
      case 'Travel': return Colors.blue;
      case 'Shopping': return Colors.red;
      case 'Bills': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> saveExpense() async {
    if (titleController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        selectedCategory == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: titleController.text.trim(),
      amount: double.parse(amountController.text.trim()),
      category: selectedCategory!,
      date: selectedDate!,
      userId: user.uid,
    );

    await ref.read(expenseProvider.notifier).addExpense(expense);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          "Add Expense",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title field
            const Text(
              "Title",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "e.g. Lunch, Petrol, Netflix",
                prefixIcon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.teal,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.teal,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount field
            const Text(
              "Amount",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "₹ 0.00",
                prefixIcon: const Icon(
                  Icons.currency_rupee,
                  color: Colors.teal,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.teal,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category selector
            const Text(
              "Category",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                final color = getCategoryColor(category);
                final icon = getCategoryIcon(category);
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                          color: isSelected ? color : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? color : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date picker
            const Text(
              "Date",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedDate != null
                        ? Colors.teal
                        : Colors.grey.shade200,
                    width: selectedDate != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: selectedDate != null
                          ? Colors.teal
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      style: TextStyle(
                        color: selectedDate != null
                            ? Colors.black87
                            : Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save button
            ElevatedButton(
              onPressed: saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Save Expense"),
            ),
          ],
        ),
      ),
    );
  }
}