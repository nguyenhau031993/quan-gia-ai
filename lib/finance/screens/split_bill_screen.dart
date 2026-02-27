import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final _totalCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController(text: "2");
  final _tipCtrl = TextEditingController(text: "0");
  double _perPerson = 0;

  void _calculate() {
    double total = double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;
    double people = double.tryParse(_peopleCtrl.text) ?? 1;
    double tip = double.tryParse(_tipCtrl.text) ?? 0;

    setState(() {
      _perPerson = (total + tip) / (people > 0 ? people : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chia tiền nhóm"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tổng hóa đơn",
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _peopleCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số người",
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tipCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tiền Tip/Khác",
                      prefixIcon: Icon(Icons.volunteer_activism),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "CHIA ĐỀU",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_perPerson > 0)
              Column(
                children: [
                  const Text(
                    "Mỗi người cần đóng:",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "${NumberFormat("#,###").format(_perPerson)} đ",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
