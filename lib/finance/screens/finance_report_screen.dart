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

    // Khắc phục lỗi crash khi max = 0
    double maxVal = 0;
    if (history.isNotEmpty) {
      maxVal = history
          .map((e) => e['expense'] as double)
          .reduce((a, b) => a > b ? a : b);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Báo cáo Tài chính"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chi tiêu 6 tháng gần đây",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // BIỂU ĐỒ CỘT AN TOÀN
            Container(
              height: 220,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: history.map((item) {
                  double h = 140;
                  double expense = item['expense'] as double;
                  // Tính chiều cao cột an toàn, tránh lỗi NaN
                  double barH = (maxVal == 0 || expense == 0)
                      ? 0
                      : (expense / maxVal) * h;
                  if (barH > h) barH = h;
                  if (barH > 0 && barH < 5)
                    barH = 5; // Tối thiểu 5px nếu có tiêu

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text hiện số tiền nhỏ trên cột
                      if (expense > 0)
                        Text(
                          NumberFormat.compact().format(expense),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 25,
                        height: barH,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['month'].toString().split('/')[0],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Cơ cấu chi tiêu tháng này",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            if (structure.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "Chưa có dữ liệu chi tiêu tháng này",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...structure.map((item) {
                // Lấy an toàn, tránh lỗi rỗng
                Category? cat = item['category'];
                if (cat == null) return const SizedBox.shrink();

                return Card(
                  color: AppColors.cardBg,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color.withOpacity(0.2),
                      child: Icon(cat.icon, color: cat.color),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${fmt.format(item['amount'])} đ",
                          style: const TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${(item['percent'] * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
