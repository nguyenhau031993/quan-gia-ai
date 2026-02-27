import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final _salaryController = TextEditingController();
  final _dependentsController = TextEditingController(text: "0");
  double _netSalary = 0;
  double _tax = 0;

  void _calculateTax() {
    FocusScope.of(context).unfocus();
    double gross =
        double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0;
    int dependents = int.tryParse(_dependentsController.text) ?? 0;

    if (gross > 0) {
      // 1. Giảm trừ gia cảnh
      double personalDeduction = 11000000; // Bản thân 11tr
      double dependentDeduction = dependents * 4400000.0; // Phụ thuộc 4.4tr
      double insurance = gross * 0.105; // Bảo hiểm 10.5% (tương đối)

      // Lương chịu thuế
      double taxableIncome =
          gross - personalDeduction - dependentDeduction - insurance;

      // 2. Tính thuế theo bậc thang (Lũy tiến từng phần)
      double tax = 0;
      if (taxableIncome > 0) {
        if (taxableIncome <= 5000000)
          tax = taxableIncome * 0.05;
        else if (taxableIncome <= 10000000)
          tax = 250000 + (taxableIncome - 5000000) * 0.1;
        else if (taxableIncome <= 18000000)
          tax = 750000 + (taxableIncome - 10000000) * 0.15;
        else if (taxableIncome <= 32000000)
          tax = 1950000 + (taxableIncome - 18000000) * 0.2;
        else if (taxableIncome <= 52000000)
          tax = 4750000 + (taxableIncome - 32000000) * 0.25;
        else if (taxableIncome <= 80000000)
          tax = 9750000 + (taxableIncome - 52000000) * 0.3;
        else
          tax = 18150000 + (taxableIncome - 80000000) * 0.35;
      }

      setState(() {
        _tax = tax;
        _netSalary = gross - insurance - tax;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###");
    return Scaffold(
      appBar: AppBar(title: const Text("Tính thuế TNCN"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Lương Gross (VNĐ)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _dependentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số người phụ thuộc",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateTax,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "TÍNH NET",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_netSalary > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _row("Thuế phải đóng", _tax, fmt, color: Colors.red),
                    const Divider(),
                    _row(
                      "Lương thực nhận (NET)",
                      _netSalary,
                      fmt,
                      color: Colors.green,
                      isBold: true,
                      size: 20,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    double val,
    NumberFormat fmt, {
    Color? color,
    bool isBold = false,
    double size = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          "${fmt.format(val)} đ",
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: size,
          ),
        ),
      ],
    );
  }
}
