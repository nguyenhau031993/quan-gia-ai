import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _manager = FinanceManager();
  final _fmt = NumberFormat("#,###");

  void _addSaving() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tạo mục tiêu tiết kiệm"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên mục tiêu (VD: Mua xe)",
                ),
              ),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số tiền cần (Mục tiêu)",
                ),
              ),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Đã có hiện tại"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && targetCtrl.text.isNotEmpty) {
                _manager.addSaving(
                  nameCtrl.text,
                  double.tryParse(targetCtrl.text) ?? 0,
                  double.tryParse(currentCtrl.text) ?? 0,
                  DateTime.now().add(
                    const Duration(days: 365),
                  ), // Mặc định 1 năm
                );
                setState(() {}); // Refresh UI
                Navigator.pop(ctx);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _delete(String id) {
    _manager.deleteSaving(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sổ tiết kiệm"), elevation: 0),
      body: _manager.savings.isEmpty
          ? const Center(
              child: Text(
                "Chưa có mục tiêu tiết kiệm nào",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _manager.savings.length,
              itemBuilder: (context, index) {
                final item = _manager.savings[index];
                double percent = item.targetAmount > 0
                    ? (item.currentAmount / item.targetAmount)
                    : 0;
                if (percent > 1) percent = 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () => _delete(item.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: percent,
                          color: Colors.green,
                          backgroundColor: Colors.grey[200],
                          minHeight: 8,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Đã có: ${_fmt.format(item.currentAmount)} đ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              "Mục tiêu: ${_fmt.format(item.targetAmount)} đ",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSaving,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
