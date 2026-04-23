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

  List<String> categories = [
    "~Select~",
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Others",
  ];
  var selectedCategory = "~Select~";

  DateTime? selectedDate;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "title"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "amount"),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((ct) {
                return DropdownMenuItem(value: ct, child: Text(ct));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 18),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: pickDate,
              child: (selectedDate == null)
                  ? Text("Select Date")
                  : Text(DateFormat("dd-MM-yyyy").format(selectedDate!)),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
              onPressed: saveExpense,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveExpense() async {
    if (titleController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        selectedCategory == "~Select~" ||
        selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all feilds!")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: titleController.text,
      amount: double.parse(amountController.text.trim()),
      category: selectedCategory,
      date: selectedDate!,
      userId: user.uid,
    );

    ref.read(expenseProvider.notifier).addExpense(expense);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
