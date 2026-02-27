import 'package:flutter/material.dart';
import '../../finance_core.dart';

// --- IMPORT ĐẦY ĐỦ CÁC MÀN HÌNH CHỨC NĂNG ---
import 'debt_screen.dart';
import 'premium_screen.dart';
import 'exchange_rate_screen.dart';
import 'savings_screen.dart';
import 'export_excel_screen.dart';
import 'budget_screen.dart';
import 'category_manager_screen.dart';
import 'bank_link_screen.dart';
// Các file từ lần gửi 3:
import 'tax_screen.dart';
import 'interest_calc_screen.dart';
import 'split_bill_screen.dart';
import 'settings_screen.dart';

class UtilitiesScreen extends StatelessWidget {
  const UtilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tiện ích & Tính năng"),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Thêm nút Cài đặt ở góc
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                "Tính năng",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
              children: [
                _item(
                  context,
                  Icons.account_balance_wallet,
                  "Hạn mức chi",
                  Colors.orange[200]!,
                  const BudgetScreen(),
                ),
                _item(
                  context,
                  Icons.receipt_long,
                  "Hạng mục thu/chi",
                  Colors.pink[200]!,
                  const CategoryManagerScreen(),
                ),
                _item(
                  context,
                  Icons.account_balance,
                  "Liên Kết Ngân Hàng",
                  Colors.green[200]!,
                  const BankLinkScreen(),
                  isNew: true,
                ),
                _item(
                  context,
                  Icons.flight_takeoff,
                  "Du lịch",
                  Colors.red[200]!,
                  null,
                ), // Chưa có file Du lịch
                _item(
                  context,
                  Icons.shopping_bag,
                  "Danh sách mua sắm",
                  Colors.redAccent,
                  null,
                ), // Chưa có file Mua sắm
                // Đã kết nối Sổ nợ
                _item(
                  context,
                  Icons.book,
                  "Sổ nợ",
                  Colors.brown,
                  const DebtScreen(),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                "Tiện ích",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
              children: [
                // Đã kết nối Tính lãi vay
                _item(
                  context,
                  Icons.calculate,
                  "Tính lãi vay",
                  Colors.orange,
                  const InterestCalcScreen(),
                ),
                // Đã kết nối Thuế TNCN
                _item(
                  context,
                  Icons.person,
                  "Thuế TNCN",
                  Colors.blue,
                  const TaxScreen(),
                ),
                _item(
                  context,
                  Icons.currency_exchange,
                  "Tra cứu tỷ giá",
                  Colors.green,
                  const ExchangeRateScreen(),
                ),
                _item(
                  context,
                  Icons.savings,
                  "Tiết kiệm gửi góp",
                  Colors.pink,
                  const SavingsScreen(),
                ),
                // Đã kết nối Chia tiền
                _item(
                  context,
                  Icons.pie_chart,
                  "Chia tiền",
                  Colors.teal,
                  const SplitBillScreen(),
                ),
                _item(
                  context,
                  Icons.file_upload,
                  "Xuất khẩu dữ liệu",
                  Colors.purple,
                  const ExportExcelScreen(),
                ),
                _item(
                  context,
                  Icons.diamond,
                  "Premium miễn phí",
                  Colors.amber,
                  const PremiumScreen(),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Widget? page, {
    bool isNew = false,
  }) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tính năng đang được phát triển!"),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (isNew)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Mới",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
