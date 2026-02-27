import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  final _manager = FinanceManager();

  @override
  Widget build(BuildContext context) {
    final history = _manager.getSixMonthHistory();
    final structure = _manager.getSpendingStructure();
    final fmt = NumberFormat("#,###");

    return Scaffold(
      appBar: AppBar(title: const Text("Báo cáo Tài chính"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tình hình 6 tháng gần đây",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: history.map((item) {
                  double h = 150;
                  double max = 50000000; // Giả sử max là 50tr để vẽ tỷ lệ
                  double barH = (item['expense'] / max) * h;
                  if (barH > h) barH = h;
                  if (barH < 5 && item['expense'] > 0) barH = 5;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(width: 20, height: barH, color: Colors.blue),
                      const SizedBox(height: 5),
                      Text(
                        item['month'].toString().split('/')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Cơ cấu chi tiêu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...structure.map((item) {
              Category cat = item['category'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: cat.color.withOpacity(0.2),
                  child: Icon(cat.icon, color: cat.color),
                ),
                title: Text(cat.name),
                trailing: Text(
                  "${fmt.format(item['amount'])} đ (${(item['percent'] * 100).toStringAsFixed(1)}%)",
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
