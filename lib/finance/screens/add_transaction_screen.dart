import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _manager = FinanceManager();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense; // Mặc định là Chi tiêu
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    // Chọn mặc định ví đầu tiên và hạng mục đầu tiên
    if (_manager.accounts.isNotEmpty)
      _selectedAccountId = _manager.accounts[0].id;
    if (_manager.categories.isNotEmpty)
      _selectedCategoryId = _manager.categories
          .firstWhere((c) => c.type == _type)
          .id;
  }

  void _save() {
    if (_amountCtrl.text.isEmpty ||
        _selectedCategoryId == null ||
        _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập số tiền và chọn ví/hạng mục"),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;

    _manager.addTransaction(
      Transaction(
        id: DateTime.now().toString(),
        amount: amount,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteCtrl.text,
      ),
    );

    Navigator.pop(context, true); // Trả về true để màn hình chính reload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu giao dịch thành công!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Thêm giao dịch mới"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHỌN LOẠI (THU / CHI)
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    "CHI TIÊU",
                    TransactionType.expense,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTypeButton(
                    "THU NHẬP",
                    TransactionType.income,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. NHẬP SỐ TIỀN
            const Text("Số tiền", style: TextStyle(color: Colors.white70)),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                suffixText: "đ",
                suffixStyle: TextStyle(color: Colors.white),
              ),
            ),
            const Divider(color: Colors.grey),

            // 3. CHỌN HẠNG MỤC
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              dropdownColor: AppColors.cardBg,
              decoration: _inputDecor("Hạng mục", Icons.category),
              style: const TextStyle(color: Colors.white),
              items: _manager.categories.where((c) => c.type == _type).map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),

            // 4. CHỌN VÍ
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedAccountId,
              dropdownColor: AppColors.cardBg,
              decoration: _inputDecor(
                "Tài khoản / Ví",
                Icons.account_balance_wallet,
              ),
              style: const TextStyle(color: Colors.white),
              items: _manager.accounts.map((a) {
                return DropdownMenuItem(
                  value: a.id,
                  child: Text(
                    "${a.name} (${NumberFormat("#,###").format(a.balance)} đ)",
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),

            // 5. NGÀY THÁNG & GHI CHÚ
            const SizedBox(height: 15),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: _selectedDate,
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: InputDecorator(
                decoration: _inputDecor("Ngày giao dịch", Icons.calendar_today),
                child: Text(
                  DateFormat("dd/MM/yyyy").format(_selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor("Ghi chú / Diễn giải", Icons.edit),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "LƯU GIAO DỊCH",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, Color color) {
    bool isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() {
        _type = type;
        // Reset category khi đổi loại
        _selectedCategoryId = _manager.categories
            .firstWhere(
              (c) => c.type == _type,
              orElse: () => _manager.categories[0],
            )
            .id;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.cardBg,
          border: Border.all(color: isSelected ? color : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
