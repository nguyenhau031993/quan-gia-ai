import 'package:flutter/material.dart';
import '../../finance_core.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _manager = FinanceManager();
  bool _isLoading = false;

  void _checkIn() async {
    setState(() => _isLoading = true);
    // Giả lập xem quảng cáo 3 giây
    await Future.delayed(const Duration(seconds: 3));

    _manager.doCheckIn();
    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text(
                "Điểm danh thành công!",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            "Bạn đã nhận được +100 Xu.\nDùng xu để đổi gói VIP.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canCheckIn = _manager.canCheckIn();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Điểm danh nhận quà"),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              "Hôm nay: ${_manager.user.lastCheckIn}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),

            if (canCheckIn)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.play_circle_fill, color: Colors.white),
                label: Text(
                  _isLoading
                      ? "Đang tải quảng cáo..."
                      : "XEM QUẢNG CÁO (+100 XU)",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    Text(
                      "Đã điểm danh hôm nay",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 50),
            const Text(
              "Tổng xu tích lũy:",
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              "${_manager.user.coins}",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
