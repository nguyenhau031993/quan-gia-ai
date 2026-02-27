import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _manager = FinanceManager();

  void _addBudget() {
    final amountCtrl = TextEditingController();
    Category? selectedCat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thiết lập ngân sách tháng này",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              DropdownButton<Category>(
                value: selectedCat,
                hint: const Text("Chọn hạng mục chi tiêu"),
                isExpanded: true,
                items: _manager.categories
                    .where((c) => c.type == TransactionType.expense)
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setStateModal(() => selectedCat = val),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Hạn mức (VNĐ)"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedCat != null && amountCtrl.text.isNotEmpty) {
                      _manager.addBudget(
                        selectedCat!.id,
                        double.tryParse(amountCtrl.text) ?? 0,
                      );
                      setState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Lưu Ngân Sách"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgets = _manager.getBudgetStatus();
    final fmt = NumberFormat("#,###");

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Ngân sách"), elevation: 0),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.money_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "Chưa có ngân sách nào",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBudget,
                    child: const Text("Tạo ngay"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final item = budgets[index];
                final cat = item['category'] as Category;
                final percent = item['percent'] as double;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(cat.icon, color: Colors.white),
                      backgroundColor: cat.color,
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: percent > 1 ? 1 : percent,
                          color: percent > 1 ? Colors.red : Colors.green,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Đã chi: ${fmt.format(item['spent'])} / ${fmt.format(item['budget'].limit)}",
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _manager.deleteBudget(cat.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        child: const Icon(Icons.add),
      ),
    );
  }
}
