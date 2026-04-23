import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Center(child: Text("Coming soon! 🔥")),
      ),
    );
  }
}
