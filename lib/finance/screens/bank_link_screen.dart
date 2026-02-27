import 'package:flutter/material.dart';
import '../../finance_core.dart';

class BankLinkScreen extends StatefulWidget {
  const BankLinkScreen({super.key});
  @override
  State<BankLinkScreen> createState() => _BankLinkScreenState();
}

class _BankLinkScreenState extends State<BankLinkScreen> {
  // Danh sách ngân hàng hỗ trợ VietQR
  final List<String> _banks = [
    "Vietcombank",
    "MBBank",
    "Techcombank",
    "ACB",
    "VPBank",
    "TPBank",
    "VietinBank",
    "BIDV",
    "Agribank",
  ];
  String? _selectedBank;
  final _accNumCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();

  void _saveBank() {
    if (_selectedBank != null && _accNumCtrl.text.isNotEmpty) {
      // Lưu vào Core như một tài khoản mới
      FinanceManager().addAccount(
        "$_selectedBank - ${_accNumCtrl.text}",
        0,
        AccountType.bankAccount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Liên kết thành công! Đã thêm vào danh sách ví."),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Liên kết Ngân hàng"),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn ngân hàng của bạn:",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBank,
                  hint: const Text(
                    "Chọn ngân hàng",
                    style: TextStyle(color: Colors.grey),
                  ),
                  dropdownColor: AppColors.cardBg,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: _banks
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBank = val),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accNumCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Số tài khoản",
                filled: true,
                fillColor: AppColors.cardBg,
                prefixIcon: Icon(Icons.numbers, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tên chủ tài khoản (Không dấu)",
                filled: true,
                fillColor: AppColors.cardBg,
                prefixIcon: Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveBank,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                ),
                child: const Text(
                  "LIÊN KẾT NGAY",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lưu ý: Ứng dụng chỉ lưu thông tin để tạo mã QR và ghi chép, tuyệt đối không yêu cầu mật khẩu ngân hàng/OTP của bạn.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
