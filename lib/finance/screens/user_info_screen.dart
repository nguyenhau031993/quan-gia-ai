import 'package:flutter/material.dart';
import '../../finance_core.dart';
import 'auth_screen.dart';
import 'settings_screen.dart'; // ĐÃ IMPORT FILE CÀI ĐẶT

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});
  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _manager = FinanceManager();

  @override
  Widget build(BuildContext context) {
    bool isGuest = !_manager.user.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tài khoản"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            if (isGuest) _buildGuestHeader() else _buildUserHeader(),

            const SizedBox(height: 30),
            // Menu chức năng
            _menuItem(
              "Nâng cấp Premium",
              Icons.diamond,
              AppColors.accent,
              () {},
            ),

            // --- NÚT CÀI ĐẶT ĐÃ HOẠT ĐỘNG ---
            _menuItem("Cài đặt chung", Icons.settings, Colors.grey, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),

            _menuItem(
              "Xuất khẩu dữ liệu",
              Icons.file_download,
              Colors.grey,
              () {},
            ),
            const Divider(color: Colors.grey),

            // Nút Đăng xuất / Xóa dữ liệu
            _menuItem(
              isGuest ? "Xóa dữ liệu máy" : "Đăng xuất",
              Icons.logout,
              Colors.red,
              _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestHeader() {
    return Column(
      children: [
        const Icon(Icons.account_circle, size: 80, color: Colors.grey),
        const SizedBox(height: 10),
        const Text(
          "Bạn đang dùng chế độ Khách",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40),
          ),
          child: const Text(
            "Đăng nhập ngay",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            _manager.user.name[0],
            style: const TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _manager.user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(_manager.user.email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _menuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _handleLogout() async {
    await _manager.logout(); // Gọi hàm logout đã nâng cấp ở Core
    setState(() {}); // Refresh màn hình
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã đăng xuất & chuyển về dữ liệu khách")),
    );
  }
}
