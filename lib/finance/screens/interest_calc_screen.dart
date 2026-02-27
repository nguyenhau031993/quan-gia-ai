import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class InterestCalcScreen extends StatefulWidget {
  const InterestCalcScreen({super.key});

  @override
  State<InterestCalcScreen> createState() => _InterestCalcScreenState();
}

class _InterestCalcScreenState extends State<InterestCalcScreen> {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();

  double _monthlyPayment = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;

  void _calculate() {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    double principal =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    double rateYear = double.tryParse(_rateCtrl.text) ?? 0;
    double months = double.tryParse(_termCtrl.text) ?? 0;

    if (principal > 0 && months > 0) {
      // Công thức lãi đơn giản: Lãi = Tiền gốc * Lãi suất/năm * (Số tháng / 12)
      double totalInt = principal * (rateYear / 100) * (months / 12);

      setState(() {
        _totalInterest = totalInt;
        _totalPayment = principal + totalInt;
        _monthlyPayment = _totalPayment / months;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return Scaffold(
      appBar: AppBar(title: const Text("Tính lãi vay"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField(
              "Số tiền vay (VNĐ)",
              _amountCtrl,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    "Lãi suất (%/năm)",
                    _rateCtrl,
                    icon: Icons.percent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputField(
                    "Thời hạn (Tháng)",
                    _termCtrl,
                    icon: Icons.calendar_month,
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
                  "TÍNH TOÁN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_totalPayment > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _row(
                      "Trả hàng tháng",
                      _monthlyPayment,
                      formatter,
                      isBold: true,
                    ),
                    const Divider(),
                    _row(
                      "Tổng lãi phải trả",
                      _totalInterest,
                      formatter,
                      color: Colors.orange,
                    ),
                    _row(
                      "Tổng gốc + Lãi",
                      _totalPayment,
                      formatter,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _row(
    String label,
    double val,
    NumberFormat fmt, {
    Color color = Colors.black,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            "${fmt.format(val)} đ",
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
