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

  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    if (_manager.accounts.isNotEmpty) {
      _selectedAccountId = _manager.accounts[0].id;
    }
    if (_manager.categories.isNotEmpty) {
      _selectedCategoryId = _manager.categories
          .firstWhere((c) => c.type == _type)
          .id;
    }
  }

  // ==========================================
  // HỆ THỐNG AI PHÂN TÍCH HÀNH VI CHI TIÊU
  // ==========================================
  String _analyzeBehavior(double amount, String note, TransactionType type) {
    if (type != TransactionType.expense) return ""; // Chỉ phân tích chi tiêu

    String noteLower = note.toLowerCase();

    // 1. Phân tích theo từ khóa
    if (noteLower.contains("trà sữa") ||
        noteLower.contains("cafe") ||
        noteLower.contains("cafe")) {
      return "🤖 Trợ lý AI: Hoang phí quá! Một ly trà sữa bằng 1 bữa cơm rồi đấy. Cắt giảm nhé!";
    }
    if (noteLower.contains("nhậu") ||
        noteLower.contains("bia") ||
        noteLower.contains("rượu")) {
      return "🤖 Trợ lý AI: Nhậu nhẹt vừa hại sức khỏe vừa đau ví. Hạn chế nhé sếp!";
    }
    if (noteLower.contains("shopee") ||
        noteLower.contains("lazada") ||
        noteLower.contains("quần áo")) {
      return "🤖 Trợ lý AI: Lại chốt đơn à? Bạn có thực sự cần món đồ này không đấy?";
    }
    if (noteLower.contains("game") || noteLower.contains("nạp")) {
      return "🤖 Trợ lý AI: Nạp game ít thôi! Tiền này đem đầu tư sinh lời ngon hơn.";
    }

    // 2. Phân tích theo số tiền (Nếu không có từ khóa nhưng tiêu lớn)
    if (amount >= 2000000) {
      return "🤖 Trợ lý AI: Cảnh báo! Bạn vừa xuất một khoản khá lớn. Hãy đảm bảo nó nằm trong ngân sách.";
    } else if (amount >= 500000) {
      return "🤖 Trợ lý AI: Khoản chi này không nhỏ đâu nha. Rút ví từ từ thôi!";
    }

    return ""; // Tiêu ít và bình thường thì không nhắc
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

    double amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;

    // Lưu giao dịch vào Core
    _manager.addTransaction(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteCtrl.text,
      ),
    );

    // KÍCH HOẠT AI PHÂN TÍCH VÀ CẢNH BÁO
    String aiMessage = _analyzeBehavior(amount, _noteCtrl.text, _type);

    Navigator.pop(context, true); // Đóng màn hình trước

    // Hiện thông báo AI
    if (aiMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.smart_toy, color: Colors.amber, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  aiMessage,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // Báo lưu thành công bình thường
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu giao dịch thành công"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm giao dịch"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    "Chi tiêu",
                    TransactionType.expense,
                    AppColors.expense,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTypeButton(
                    "Thu nhập",
                    TransactionType.income,
                    AppColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: _inputDecor("Số tiền (VND)", Icons.attach_money),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor(
                "Ghi chú (Ví dụ: Trà sữa, Mua sắm...)",
                Icons.notes,
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdown<String>(
              "Chọn ví",
              Icons.account_balance_wallet,
              _selectedAccountId,
              _manager.accounts
                  .map(
                    (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                  )
                  .toList(),
              (val) => setState(() => _selectedAccountId = val),
            ),
            const SizedBox(height: 20),
            _buildDropdown<String>(
              "Chọn hạng mục",
              Icons.category,
              _selectedCategoryId,
              _manager.categories
                  .where((c) => c.type == _type)
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 15),
                    Text(
                      DateFormat("dd/MM/yyyy").format(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "LƯU GIAO DỊCH",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        _selectedCategoryId = _manager.categories
            .firstWhere(
              (c) => c.type == _type,
              orElse: () =>
                  _manager.categories[0], // Sửa chữ orelse thành orElse ở đây
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

  Widget _buildDropdown<T>(
    String hint,
    IconData icon,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                dropdownColor: AppColors.cardBg,
                value: value,
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(color: Colors.grey)),
                items: items,
                onChanged: onChanged,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
