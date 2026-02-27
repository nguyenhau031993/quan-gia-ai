import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _manager = FinanceManager();
  Account? _sourceAccount;
  Account? _destAccount;
  String _inputAmount = "0";
  final _noteCtrl = TextEditingController();
  final _formatter = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    if (_manager.accounts.isNotEmpty) {
      _sourceAccount = _manager.accounts[0];
      if (_manager.accounts.length > 1) _destAccount = _manager.accounts[1];
    }
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'DEL') {
        _inputAmount = _inputAmount.length > 1
            ? _inputAmount.substring(0, _inputAmount.length - 1)
            : "0";
      } else if (_inputAmount.length < 12) {
        _inputAmount = (_inputAmount == "0") ? value : _inputAmount + value;
      }
    });
  }

  void _save() {
    double amount = double.tryParse(_inputAmount) ?? 0;
    if (amount > 0 &&
        _sourceAccount != null &&
        _destAccount != null &&
        _sourceAccount != _destAccount) {
      _manager.addTransaction(
        Transaction(
          id: DateTime.now().toString(),
          amount: amount,
          accountId: _sourceAccount!.id,
          toAccountId: _destAccount!.id,
          categoryId: 'transfer', // ID đặc biệt cho chuyển tiền
          date: DateTime.now(),
          note: _noteCtrl.text.isEmpty ? "Chuyển tiền" : _noteCtrl.text,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Chuyển tiền nội bộ"), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Nhập tiền
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Số tiền chuyển",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${_formatter.format(double.parse(_inputAmount))} đ",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Divider(),

                // Từ ví
                ListTile(
                  title: const Text("Từ ví"),
                  trailing: DropdownButton<Account>(
                    value: _sourceAccount,
                    items: _manager.accounts
                        .map(
                          (a) =>
                              DropdownMenuItem(value: a, child: Text(a.name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _sourceAccount = val),
                    underline: SizedBox(),
                  ),
                ),
                // Đến ví
                ListTile(
                  title: const Text("Đến ví"),
                  trailing: DropdownButton<Account>(
                    value: _destAccount,
                    items: _manager.accounts
                        .map(
                          (a) =>
                              DropdownMenuItem(value: a, child: Text(a.name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _destAccount = val),
                    underline: SizedBox(),
                  ),
                ),
                if (_sourceAccount == _destAccount)
                  const Text(
                    "  ⚠️ Ví nguồn và đích phải khác nhau",
                    style: TextStyle(color: Colors.red),
                  ),

                const Divider(),
                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    hintText: "Ghi chú",
                    border: InputBorder.none,
                    icon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
          // Bàn phím
          Container(
            color: const Color(0xFFF2F2F7),
            child: Column(
              children: [
                _keyRow(['7', '8', '9']),
                _keyRow(['4', '5', '6']),
                _keyRow(['1', '2', '3']),
                _keyRow(['000', '0', 'DEL']),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        label: const Text("CHUYỂN NGAY"),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      children: keys
          .map(
            (k) => Expanded(
              child: InkWell(
                onTap: () => _onKeyTap(k),
                child: Container(
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: k == 'DEL'
                      ? const Icon(Icons.backspace)
                      : Text(k, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
