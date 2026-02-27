import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});
  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FinanceManager _manager = FinanceManager();
  final NumberFormat _formatter = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Sổ ghi nợ", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.cardBg,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "PHẢI THU"),
            Tab(text: "PHẢI TRẢ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildList(true), _buildList(false)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.expense,
        label: const Text(
          "Thêm khoản nợ",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(bool isReceivable) {
    String targetId = isReceivable ? 'l1' : 'l2';
    List<Transaction> list = _manager.transactions
        .where((t) => t.categoryId == targetId)
        .toList();
    if (list.isEmpty)
      return const Center(
        child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final tx = list[i];
        return Card(
          color: AppColors.cardBg,
          child: ListTile(
            title: Text(
              tx.contactName ?? "Người quen",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(tx.date),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              "${_formatter.format(tx.amount)} đ",
              style: TextStyle(
                color: isReceivable ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    bool isLend = _tabController.index == 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          isLend ? "Ghi: CHO VAY" : "Ghi: ĐI VAY",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Tên người"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amtCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số tiền"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && amtCtrl.text.isNotEmpty) {
                _manager.addTransaction(
                  Transaction(
                    id: DateTime.now().toString(),
                    amount: double.parse(amtCtrl.text),
                    accountId: _manager.accounts[0].id,
                    categoryId: isLend ? 'l1' : 'l2',
                    date: DateTime.now(),
                    contactName: nameCtrl.text,
                  ),
                );
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
