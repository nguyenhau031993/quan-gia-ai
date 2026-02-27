import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:csv/csv.dart'; // Tạm đóng comment để chạy được ngay không cần cài thêm thư viện
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import '../../finance_core.dart';

class ExportExcelScreen extends StatelessWidget {
  const ExportExcelScreen({super.key});

  Future<void> _exportToExcel(BuildContext context) async {
    // Logic xuất Excel sẽ được kích hoạt khi anh cài đủ thư viện
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tính năng đang chờ cập nhật thư viện CSV")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Xuất khẩu dữ liệu"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_view, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Xuất toàn bộ giao dịch ra file Excel",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _exportToExcel(context),
              icon: const Icon(Icons.download),
              label: const Text("XUẤT BÁO CÁO NGAY"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
