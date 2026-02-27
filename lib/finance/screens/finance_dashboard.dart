import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

// Import các màn hình chức năng
import 'user_info_screen.dart';
import 'account_screen.dart';
import 'budget_screen.dart';
import 'savings_screen.dart';
import 'finance_report_screen.dart';
import 'daily_checkin_screen.dart';
import 'ad_banner.dart'; // QUAN TRỌNG: File này phải tồn tại (đã tạo ở Bước 1)

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _manager = FinanceManager();
  bool _isShowBalance = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserInfoScreen()),
            ).then((_) => setState(() {})),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: _manager.user.avatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_manager.user.avatarUrl),
                      )
                    : null,
              ),
              child: _manager.user.avatarUrl.isEmpty
                  ? CircleAvatar(
                      backgroundColor: AppColors.cardBg,
                      child: Text(
                        _manager.user.name.isNotEmpty
                            ? _manager.user.name[0].toUpperCase()
                            : "K",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Xin chào,",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              _manager.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _manager.loadData();
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalAssetCard(),
              const SizedBox(height: 24),
              _buildSectionHeader("Ví của tôi", "Xem tất cả", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              }),
              const SizedBox(height: 12),
              _buildWalletList(),
              const SizedBox(height: 24),
              _buildCashFlowCard(),
              const SizedBox(height: 24),
              _buildQuickShortcuts(),
              const SizedBox(height: 24),
              _buildSectionHeader("Giao dịch gần đây", "Xem lịch sử", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinanceReportScreen(),
                  ),
                );
              }),
              const SizedBox(height: 12),
              _buildRecentTransactions(),
              const SizedBox(height: 20),

              // --- ĐÃ SỬA LỖI: Xóa 'const' vì Widget này có trạng thái động ---
              Center(child: AdBannerWidget()),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON GIỮ NGUYÊN ---
  Widget _buildTotalAssetCard() {
    double total = _manager.getTotalAssets();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBg, Colors.black.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: AppColors.textSub,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Tổng tài sản hiện có",
                    style: TextStyle(color: AppColors.textSub, fontSize: 14),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _isShowBalance = !_isShowBalance),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _isShowBalance ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSub,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isShowBalance
                ? "${NumberFormat("#,###").format(total)} đ"
                : "**********",
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.income, size: 20),
              const SizedBox(width: 8),
              Text(
                "Đang tăng trưởng tốt",
                style: TextStyle(
                  color: AppColors.income.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _manager.accounts.length + 1,
        itemBuilder: (ctx, i) {
          if (i == _manager.accounts.length) {
            return Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.add, color: AppColors.primary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Thêm ví",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          final acc = _manager.accounts[i];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: acc.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: acc.color,
                    size: 24,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acc.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isShowBalance
                          ? "${NumberFormat("#,###").format(acc.balance)} đ"
                          : "***",
                      style: const TextStyle(
                        color: AppColors.textSub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCashFlowCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tình hình thu chi (Tháng này)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Thu nhập",
                      style: TextStyle(color: AppColors.textSub, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.income.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "---",
                      style: TextStyle(
                        color: AppColors.income,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Chi tiêu",
                      style: TextStyle(color: AppColors.textSub, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.expense.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "---",
                      style: TextStyle(
                        color: AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcuts() {
    return Column(
      children: [
        _shortcutItem(
          Icons.pie_chart,
          "Hạn mức chi",
          "Quản lý chi tiêu tốt hơn",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BudgetScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _shortcutItem(
          Icons.savings,
          "Sổ tiết kiệm",
          "Theo dõi tích lũy",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SavingsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _shortcutItem(
          Icons.check_circle,
          "Điểm danh",
          "Nhận quà mỗi ngày",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DailyCheckInScreen()),
          ),
        ),
      ],
    );
  }

  Widget _shortcutItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_manager.transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Chưa có giao dịch nào gần đây",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _manager.transactions.take(5).length,
      itemBuilder: (ctx, i) {
        final tx = _manager.transactions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.expense),
            ),
            title: Text(
              tx.note.isEmpty ? "Chi tiêu" : tx.note,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat("dd/MM/yyyy").format(tx.date),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              "${NumberFormat("#,###").format(tx.amount)} đ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        InkWell(
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
