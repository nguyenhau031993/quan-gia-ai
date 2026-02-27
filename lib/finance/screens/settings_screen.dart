import 'package:flutter/material.dart';
import '../../finance_core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _manager = FinanceManager();

  // Hàm hiển thị hộp thoại chọn (Chung cho các cài đặt)
  void _showSelectionDialog(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => RadioListTile<String>(
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: option,
                  groupValue: currentValue,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      onSelected(val);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Cài đặt chung"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _section("HIỂN THỊ"),
          // 1. Cài đặt Ngôn ngữ
          _tile(
            "Ngôn ngữ",
            _manager.language,
            Icons.language,
            onTap: () {
              _showSelectionDialog(
                "Chọn ngôn ngữ",
                ["Tiếng Việt", "English"],
                _manager.language,
                (val) {
                  setState(() {
                    _manager.language = val;
                    _manager.saveData();
                  });
                },
              );
            },
          ),

          // 2. Cài đặt Định dạng ngày
          _tile(
            "Định dạng thời gian",
            _manager.dateFormat,
            Icons.calendar_today,
            onTap: () {
              _showSelectionDialog(
                "Định dạng ngày",
                ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd"],
                _manager.dateFormat,
                (val) {
                  setState(() {
                    _manager.dateFormat = val;
                    _manager.saveData();
                  });
                },
              );
            },
          ),

          // 3. Màn hình mặc định
          _tile(
            "Màn hình mặc định",
            _manager.defaultScreen,
            Icons.home,
            onTap: () {
              _showSelectionDialog(
                "Màn hình mở đầu",
                ["Tổng quan", "Sổ ghi chép", "Báo cáo"],
                _manager.defaultScreen,
                (val) {
                  setState(() {
                    _manager.defaultScreen = val;
                    _manager.saveData();
                  });
                },
              );
            },
          ),

          // 4. Tiền tệ
          _tile(
            "Thiết lập tiền tệ",
            _manager.currency,
            Icons.attach_money,
            onTap: () {
              _showSelectionDialog(
                "Đơn vị tiền tệ",
                ["VND", "USD", "EUR", "JPY"],
                _manager.currency,
                (val) {
                  setState(() {
                    _manager.currency = val;
                    _manager.saveData();
                  });
                },
              );
            },
          ),

          SwitchListTile(
            title: const Text(
              "Ẩn số tiền (Chế độ riêng tư)",
              style: TextStyle(color: Colors.white),
            ),
            secondary: const Icon(Icons.visibility_off, color: Colors.grey),
            value: _manager.hideBalance,
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            onChanged: (val) => setState(() {
              _manager.hideBalance = val;
              _manager.saveData();
            }),
          ),

          _section("BẢO MẬT & AN TOÀN"),
          SwitchListTile(
            title: const Text(
              "Khóa ứng dụng (Passcode)",
              style: TextStyle(color: Colors.white),
            ),
            secondary: const Icon(Icons.lock, color: Colors.grey),
            value: _manager.enablePasscode,
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            onChanged: (val) {
              setState(() {
                _manager.enablePasscode = val;
                _manager.saveData();
              });
              if (val)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã bật khóa bảo vệ")),
                );
            },
          ),

          _section("NHẮC NHỞ"),
          SwitchListTile(
            title: const Text(
              "Nhắc nhập liệu hàng ngày",
              style: TextStyle(color: Colors.white),
            ),
            secondary: const Icon(Icons.alarm, color: Colors.grey),
            value: _manager.enableReminder,
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            onChanged: (val) => setState(() {
              _manager.enableReminder = val;
              _manager.saveData();
            }),
          ),
          if (_manager.enableReminder)
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.grey),
              title: const Text(
                "Thời gian nhắc",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _manager.reminderTime,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _pickTime,
            ),

          _section("DỮ LIỆU & HỆ THỐNG"),
          _tile(
            "Xóa toàn bộ dữ liệu",
            "",
            Icons.delete_forever,
            color: Colors.red,
            onTap: _confirmResetData,
          ),

          const SizedBox(height: 50),
          const Center(
            child: Text(
              "Phiên bản 1.0.2 - AIA Finance",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );

  Widget _tile(
    String title,
    String trailing,
    IconData icon, {
    required VoidCallback onTap,
    Color color = Colors.white,
  }) => ListTile(
    leading: Icon(icon, color: Colors.grey),
    title: Text(title, style: TextStyle(color: color)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing.isNotEmpty)
          Text(
            trailing,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        const SizedBox(width: 5),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    ),
    onTap: onTap,
  );

  void _pickTime() async {
    TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (t != null)
      setState(() {
        _manager.reminderTime =
            "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
        _manager.saveData();
      });
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text(
          "Cảnh báo nguy hiểm",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "Bạn có chắc muốn xóa sạch toàn bộ dữ liệu không? Hành động này không thể hoàn tác.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              // Gọi hàm xóa sạch dữ liệu trong Core (Sẽ bổ sung ở file Core)
              // _manager.resetAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã reset dữ liệu về mặc định")),
              );
            },
            child: const Text(
              "XÓA SẠCH",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
