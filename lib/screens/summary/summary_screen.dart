import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xpenzo/providers/expense_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final categoryColors = {
      'Food': Colors.green,
      'Travel': Colors.blue,
      'Shopping': Colors.red,
      'Bills': Colors.orange,
      'Others': Colors.blueGrey,
    };

    List<PieChartSectionData> expenseData = categoryTotals.entries
        .map(
          (entry) => PieChartSectionData(
            value: entry.value,
            title: entry.key,
            color: categoryColors[entry.key] ?? Colors.grey,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text("Summary"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            totalAmountCard(context, total),
            SizedBox(height: 30),
            Text(
              "Expense Stats:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  centerSpaceColor: Colors.grey.shade100,

                  sections: expenseData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget totalAmountCard(BuildContext context, double total) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.5, color: Colors.teal),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Total Amount : ",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          Text(
            "₹${total.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
