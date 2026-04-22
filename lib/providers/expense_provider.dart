import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xpenzo/models/expense_model.dart';
import 'package:xpenzo/services/firestore_service.dart';

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  final FirestoreService _firestoreService;
  ExpenseNotifier(this._firestoreService) : super([]);

  void loadExpenses(String userId) {
    _firestoreService.getExpenses(userId).listen((expense) => state = expense);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestoreService.addExpense(expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestoreService.deleteExpense(expenseId);
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier,List<ExpenseModel>>((ref){
return ExpenseNotifier(FirestoreService());
});
