import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../finance_core.dart';
// import '../../main.dart'; // Bỏ import main để tránh vòng lặp nếu không cần thiết

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // IP VPS CỦA ANH
  final String serverUrl = "http://103.130.218.246:3000/api";

  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$serverUrl/${_isLogin ? "login" : "register"}');
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailCtrl.text,
          "password": _passCtrl.text,
          if (!_isLogin) "name": _nameCtrl.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // GỌI HÀM LOGIN CỦA CORE ĐỂ LOAD DỮ LIỆU RIÊNG
        await FinanceManager().loginSuccess(
          _emailCtrl.text,
          _isLogin ? (data['user']?['name'] ?? "User") : _nameCtrl.text,
        );

        if (mounted) {
          Navigator.pop(context); // Quay về màn hình trước
          Navigator.pop(context); // Quay về Home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng nhập thành công!")),
          );
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi: ${response.body}")));
      }
    } catch (e) {
      // Chế độ Offline (Demo) nếu Server chết
      await FinanceManager().loginSuccess(
        _emailCtrl.text,
        _isLogin ? "User Offline" : _nameCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã đăng nhập (Chế độ Offline)")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "ĐĂNG NHẬP" : "TẠO TÀI KHOẢN",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (!_isLogin) _input("Họ tên", _nameCtrl, Icons.person),
            const SizedBox(height: 15),
            _input("Email", _emailCtrl, Icons.email),
            const SizedBox(height: 15),
            _input("Mật khẩu", _passCtrl, Icons.lock, isPass: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? "Chưa có tài khoản? Đăng ký" : "Quay lại Đăng nhập",
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isPass = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
