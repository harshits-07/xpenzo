import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:xpenzo/providers/expense_provider.dart';
import 'package:xpenzo/screens/add_expense/add_expense.dart';
import 'package:xpenzo/screens/summary/summary_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ref.read(expenseProvider.notifier).loadExpenses(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Xpenzo"),
        centerTitle: true,
        actions: [
            IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SummaryScreen()),
        );
      },
      icon: const Icon(Icons.bar_chart, color: Colors.teal),
    ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout, color: Colors.teal),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: expenseState.isEmpty
            ? const Center(
                child: Text(
                  "No expenses yet!\nTap + to add one 💸",
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: expenseState.length,
                itemBuilder: (context, index) {
                  var expense = expenseState[index];
                  return Dismissible(
                    key: Key(expense.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (direction) => ref
                        .read(expenseProvider.notifier)
                        .deleteExpense(expense.id),
                    child: ListTile(
                      leading: Text("${index + 1}"),
                      title: Text(expense.title.toString()),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('₹${expense.amount.toStringAsFixed(2)}'),
                          Text(DateFormat("dd-MM-yyyy").format(expense.date)),
                          Text(
                            expense.category,
                            style: TextStyle(color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
