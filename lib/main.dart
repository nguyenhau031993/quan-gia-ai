import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Đã thêm thư viện quảng cáo

// --- IMPORT TOÀN BỘ HỆ SINH THÁI ---
import 'finance_core.dart';
import 'finance/screens/finance_dashboard.dart';
import 'finance/screens/finance_report_screen.dart';
import 'finance/screens/utilities_screen.dart';
import 'finance/screens/ai_chat_screen.dart';
import 'finance/screens/account_screen.dart';
import 'finance/screens/add_transaction_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // KHỞI TẠO QUẢNG CÁO ADMOB
  MobileAds.instance.initialize();
  runApp(const AiaFinanceApp());
}

class AiaFinanceApp extends StatelessWidget {
  const AiaFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBg,

        // Font chữ toàn ứng dụng
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),

      // Load dữ liệu trước khi vào áp
      home: FutureBuilder(
        future: FinanceManager().loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MainContainer();
          }
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // DANH SÁCH MÀN HÌNH CHÍNH
  final List<Widget> _screens = [
    const DashboardScreen(), // 0: Tổng quan
    const AccountScreen(), // 1: Tài khoản
    const SizedBox(), // 2: Nút rỗng (Cho nút +)
    const FinanceReportScreen(), // 3: Báo cáo
    const UtilitiesScreen(), // 4: Tiện ích
  ];

  // Hàm mở màn hình thêm giao dịch
  void _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    // Reload lại app để cập nhật số tiền sau khi thêm
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // STACK: Để nút Chat AI nổi lên trên cùng
      body: Stack(
        children: [
          _screens[_currentIndex],

          // NÚT CHAT AI (ROBOT)
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: "ai_chat_btn",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              elevation: 10,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),

      // NÚT THÊM GIAO DỊCH (+) TO Ở GIỮA
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          heroTag: "add_transaction_btn",
          onPressed: _openAddTransaction,
          backgroundColor: AppColors.primary,
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 36, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) return;
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tổng quan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Tài khoản",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Báo cáo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Tiện ích",
          ),
        ],
      ),
    );
  }
}
