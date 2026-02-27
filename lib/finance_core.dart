import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================= 1. MÀU SẮC AIA (DARK MODE) =======================
class AppColors {
  static const background = Color(0xFF0F172A);
  static const cardBg = Color(0xFF1E293B);
  static const primary = Color(0xFF0EA5E9);
  static const accent = Color(0xFFF59E0B);
  static const expense = Color(0xFFEF4444);
  static const income = Color(0xFF22C55E);
  static const textMain = Colors.white;
  static const textSub = Color(0xFF94A3B8);
}

// ======================= 2. ENUMS & MODELS =======================
enum TransactionType { expense, income, transfer, adjustment }

enum AccountType {
  cash,
  bankAccount,
  creditCard,
  eWallet,
  saving,
  accumulation,
}

class UserProfile {
  String name;
  String email;
  String avatarUrl;
  int coins;
  bool isPremium;
  String lastCheckIn;
  bool isLoggedIn;

  UserProfile({
    this.name = "Khách hàng",
    this.email = "guest",
    this.avatarUrl = "",
    this.coins = 0,
    this.isPremium = false,
    this.lastCheckIn = "",
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'coins': coins,
    'isPremium': isPremium,
    'lastCheckIn': lastCheckIn,
    'isLoggedIn': isLoggedIn,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? "Khách hàng",
    email: json['email'] ?? "guest",
    avatarUrl: json['avatarUrl'] ?? "",
    coins: json['coins'] ?? 0,
    isPremium: json['isPremium'] ?? false,
    lastCheckIn: json['lastCheckIn'] ?? "",
    isLoggedIn: json['isLoggedIn'] ?? false,
  );
}

class Account {
  final String id;
  String name;
  double balance;
  double initialBalance;
  AccountType type;
  String iconPath;
  int colorValue;
  bool isExcludeTotal;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    this.initialBalance = 0,
    required this.type,
    required this.iconPath,
    required this.colorValue,
    this.isExcludeTotal = false,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balance': balance,
    'initialBalance': initialBalance,
    'type': type.index,
    'iconPath': iconPath,
    'colorValue': colorValue,
    'isExcludeTotal': isExcludeTotal,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    name: json['name'],
    balance: json['balance'],
    initialBalance: json['initialBalance'],
    type: AccountType.values[json['type']],
    iconPath: json['iconPath'],
    colorValue: json['colorValue'],
    isExcludeTotal: json['isExcludeTotal'],
  );
}

class Category {
  final String id;
  String name;
  TransactionType type;
  int iconCode;
  int colorValue;
  bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'iconCode': iconCode,
    'colorValue': colorValue,
    'isDefault': isDefault,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    type: TransactionType.values[json['type']],
    iconCode: json['iconCode'],
    colorValue: json['colorValue'],
    isDefault: json['isDefault'] ?? false,
  );
}

class Transaction {
  final String id;
  double amount;
  String accountId;
  String? toAccountId;
  String categoryId;
  DateTime date;
  String note;
  String? contactName;

  Transaction({
    required this.id,
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.contactName,
    this.toAccountId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'accountId': accountId,
    'toAccountId': toAccountId,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'note': note,
    'contactName': contactName,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    amount: json['amount'],
    accountId: json['accountId'],
    toAccountId: json['toAccountId'],
    categoryId: json['categoryId'],
    date: DateTime.parse(json['date']),
    note: json['note'],
    contactName: json['contactName'],
  );
}

class Budget {
  final String id;
  final String categoryId;
  double limit;
  int month;
  int year;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'limit': limit,
    'month': month,
    'year': year,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    categoryId: json['categoryId'],
    limit: json['limit'],
    month: json['month'],
    year: json['year'],
  );
}

class Saving {
  final String id;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime deadline;

  Saving({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline.toIso8601String(),
  };

  factory Saving.fromJson(Map<String, dynamic> json) => Saving(
    id: json['id'],
    name: json['name'],
    targetAmount: json['targetAmount'],
    currentAmount: json['currentAmount'],
    deadline: DateTime.parse(json['deadline']),
  );
}

// ======================= 3. FINANCE MANAGER (LOGIC LÕI) =======================
class FinanceManager {
  static final FinanceManager _instance = FinanceManager._internal();
  factory FinanceManager() => _instance;
  FinanceManager._internal();

  // Dữ liệu người dùng hiện tại
  UserProfile user = UserProfile();
  List<Account> accounts = [];
  List<Category> categories = [];
  List<Transaction> transactions = [];
  List<Budget> budgets = [];
  List<Saving> savings = [];

  // --- CÁC BIẾN CÀI ĐẶT (ĐÃ KHÔI PHỤC ĐẦY ĐỦ) ---
  bool hideBalance = false;
  String currency = "VND";
  String language = "Tiếng Việt";
  String dateFormat = "dd/MM/yyyy";
  String defaultScreen = "Tổng quan";
  String detailDisplay = "Chi tiết";

  bool enablePasscode = false;
  bool enableFaceID = false;
  bool enableReminder = true;
  String reminderTime = "20:00";
  bool enableUpdateNotify = true;

  String startDayOfWeek = "Thứ 2";
  int startDayOfMonth = 1;
  String startMonthOfYear = "Tháng 1";

  bool get isPremium => user.isPremium;

  // --- HÀM TẠO KEY DỮ LIỆU RIÊNG BIỆT (QUAN TRỌNG CHO ĐA USER) ---
  // Nếu là khách -> key="guest_accounts", Nếu user -> key="email_accounts"
  String get _keyPrefix =>
      user.isLoggedIn ? user.email.replaceAll('.', '_') : "guest";

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load User hiện tại (Để biết đang là ai)
    if (prefs.getString('currentUser') != null) {
      try {
        user = UserProfile.fromJson(
          jsonDecode(prefs.getString('currentUser')!),
        );
      } catch (e) {
        user = UserProfile();
      }
    } else {
      user = UserProfile();
    }

    // 2. Load Dữ liệu riêng của User đó
    String p = _keyPrefix;

    // Settings
    hideBalance = prefs.getBool('${p}_hideBalance') ?? false;
    currency = prefs.getString('${p}_currency') ?? "VND";
    language = prefs.getString('${p}_language') ?? "Tiếng Việt";
    dateFormat = prefs.getString('${p}_dateFormat') ?? "dd/MM/yyyy";
    enablePasscode = prefs.getBool('${p}_enablePasscode') ?? false;
    // ... load các setting khác tương tự

    // Data List
    if (prefs.getString('${p}_accounts') != null) {
      accounts = (jsonDecode(prefs.getString('${p}_accounts')!) as List)
          .map((e) => Account.fromJson(e))
          .toList();
    } else {
      _initDefaultAccounts(); // New user -> tạo ví mặc định
    }

    if (prefs.getString('${p}_categories') != null)
      categories = (jsonDecode(prefs.getString('${p}_categories')!) as List)
          .map((e) => Category.fromJson(e))
          .toList();
    else
      _initDefaultCategories();
    if (prefs.getString('${p}_transactions') != null)
      transactions = (jsonDecode(prefs.getString('${p}_transactions')!) as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    else
      transactions = [];
    if (prefs.getString('${p}_budgets') != null)
      budgets = (jsonDecode(prefs.getString('${p}_budgets')!) as List)
          .map((e) => Budget.fromJson(e))
          .toList();
    else
      budgets = [];
    if (prefs.getString('${p}_savings') != null)
      savings = (jsonDecode(prefs.getString('${p}_savings')!) as List)
          .map((e) => Saving.fromJson(e))
          .toList();
    else
      savings = [];
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu thông tin User chung
    prefs.setString('currentUser', jsonEncode(user.toJson()));

    String p = _keyPrefix;

    // Lưu Settings riêng
    prefs.setBool('${p}_hideBalance', hideBalance);
    prefs.setString('${p}_currency', currency);
    prefs.setString('${p}_language', language);
    prefs.setString('${p}_dateFormat', dateFormat);
    prefs.setBool('${p}_enablePasscode', enablePasscode);

    // Lưu Data riêng
    prefs.setString(
      '${p}_accounts',
      jsonEncode(accounts.map((e) => e.toJson()).toList()),
    );
    prefs.setString(
      '${p}_categories',
      jsonEncode(categories.map((e) => e.toJson()).toList()),
    );
    prefs.setString(
      '${p}_transactions',
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
    prefs.setString(
      '${p}_budgets',
      jsonEncode(budgets.map((e) => e.toJson()).toList()),
    );
    prefs.setString(
      '${p}_savings',
      jsonEncode(savings.map((e) => e.toJson()).toList()),
    );
  }

  // --- LOGIC ĐĂNG NHẬP / ĐĂNG XUẤT ---
  Future<void> loginSuccess(String email, String name) async {
    user.email = email;
    user.name = name;
    user.isLoggedIn = true;
    await loadData(); // Load lại dữ liệu của user mới
    await saveData();
  }

  Future<void> logout() async {
    user = UserProfile(); // Reset về guest
    await loadData(); // Load lại dữ liệu guest
    await saveData();
  }

  // --- CRUD METHODS ---
  // => ĐÂY LÀ HÀM QUAN TRỌNG ĐANG THIẾU
  void upgradeToPremium() {
    user.isPremium = true;
    saveData();
  }

  void addAccount(String name, double balance, AccountType type) {
    accounts.add(
      Account(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        balance: balance,
        initialBalance: balance,
        type: type,
        iconPath: 'assets/bank.png',
        colorValue: Colors.blue.value,
      ),
    );
    saveData();
  }

  void deleteAccount(String id) {
    accounts.removeWhere((a) => a.id == id);
    saveData();
  }

  void addCategory(
    String name,
    TransactionType type,
    IconData icon,
    Color color,
  ) {
    categories.add(
      Category(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        iconCode: icon.codePoint,
        colorValue: color.value,
      ),
    );
    saveData();
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id && !c.isDefault);
    saveData();
  }

  void addBudget(String categoryId, double limit) {
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    int index = budgets.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );
    if (index >= 0) {
      budgets[index] = Budget(
        id: budgets[index].id,
        categoryId: categoryId,
        limit: limit,
        month: month,
        year: year,
      );
    } else {
      budgets.add(
        Budget(
          id: 'bg_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: categoryId,
          limit: limit,
          month: month,
          year: year,
        ),
      );
    }
    saveData();
  }

  void deleteBudget(String categoryId) {
    budgets.removeWhere((b) => b.categoryId == categoryId);
    saveData();
  }

  void addSaving(
    String name,
    double target,
    double current,
    DateTime deadline,
  ) {
    savings.add(
      Saving(
        id: 'sav_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        targetAmount: target,
        currentAmount: current,
        deadline: deadline,
      ),
    );
    saveData();
  }

  void deleteSaving(String id) {
    savings.removeWhere((s) => s.id == id);
    saveData();
  }

  bool canCheckIn() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return user.lastCheckIn != today;
  }

  void doCheckIn() {
    if (canCheckIn()) {
      user.coins += 100;
      user.lastCheckIn = DateFormat('yyyy-MM-dd').format(DateTime.now());
      saveData();
    }
  }

  void addTransaction(Transaction tx) {
    transactions.add(tx);
    try {
      if (tx.categoryId == 'transfer') {
        Account src = accounts.firstWhere((a) => a.id == tx.accountId);
        Account dest = accounts.firstWhere((a) => a.id == tx.toAccountId);
        src.balance -= tx.amount;
        dest.balance += tx.amount;
      } else {
        Account acc = accounts.firstWhere((a) => a.id == tx.accountId);
        Category cat = categories.firstWhere((c) => c.id == tx.categoryId);
        if (cat.type == TransactionType.expense)
          acc.balance -= tx.amount;
        else
          acc.balance += tx.amount;
      }
      saveData();
    } catch (_) {}
  }

  // --- INIT DEFAULT DATA ---
  void _initDefaultAccounts() {
    accounts = [
      Account(
        id: 'a1',
        name: 'Tiền mặt',
        balance: 0,
        type: AccountType.cash,
        iconPath: '',
        colorValue: Colors.green.value,
      ),
    ];
  }

  void _initDefaultCategories() {
    categories = [
      Category(
        id: 'c1',
        name: 'Ăn uống',
        type: TransactionType.expense,
        iconCode: Icons.restaurant.codePoint,
        colorValue: Colors.orange.value,
        isDefault: true,
      ),
      Category(
        id: 'i1',
        name: 'Lương',
        type: TransactionType.income,
        iconCode: Icons.attach_money.codePoint,
        colorValue: Colors.green.value,
        isDefault: true,
      ),
      Category(
        id: 'transfer',
        name: 'Chuyển tiền',
        type: TransactionType.transfer,
        iconCode: Icons.swap_horiz.codePoint,
        colorValue: Colors.grey.value,
        isDefault: true,
      ),
    ];
  }

  // --- REPORTS & HELPERS ---
  double getTotalAssets() => accounts
      .where((a) => !a.isExcludeTotal)
      .fold(0, (sum, item) => sum + item.balance);

  List<Map<String, dynamic>> getBudgetStatus() {
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    List<Map<String, dynamic>> result = [];
    for (var bg in budgets.where((b) => b.month == month && b.year == year)) {
      double spent = transactions
          .where(
            (t) =>
                t.categoryId == bg.categoryId &&
                t.date.month == month &&
                t.date.year == year,
          )
          .fold(0, (sum, item) => sum + item.amount);
      try {
        Category cat = categories.firstWhere((c) => c.id == bg.categoryId);
        result.add({
          'budget': bg,
          'category': cat,
          'spent': spent,
          'percent': spent / (bg.limit == 0 ? 1 : bg.limit),
        });
      } catch (_) {}
    }
    return result;
  }

  List<Map<String, dynamic>> getSixMonthHistory() {
    List<Map<String, dynamic>> data = [];
    DateTime now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      DateTime monthStart = DateTime(now.year, now.month - i, 1);
      DateTime monthEnd = DateTime(now.year, now.month - i + 1, 0);
      double expense = transactions
          .where(
            (t) =>
                t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                t.date.isBefore(monthEnd.add(const Duration(days: 1))),
          )
          .where((t) {
            try {
              var cat = categories.firstWhere((c) => c.id == t.categoryId);
              return cat.type == TransactionType.expense;
            } catch (_) {
              return false;
            }
          })
          .fold(0, (sum, item) => sum + item.amount);
      data.add({
        'month': "${monthStart.month}/${monthStart.year}",
        'expense': expense,
      });
    }
    return data;
  }

  List<Map<String, dynamic>> getSpendingStructure() {
    DateTime now = DateTime.now();
    Map<String, double> catMap = {};
    double totalExpense = 0;
    for (var tx in transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        try {
          var cat = categories.firstWhere((c) => c.id == tx.categoryId);
          if (cat.type == TransactionType.expense) {
            catMap[cat.id] = (catMap[cat.id] ?? 0) + tx.amount;
            totalExpense += tx.amount;
          }
        } catch (_) {}
      }
    }
    List<Map<String, dynamic>> result = [];
    catMap.forEach((key, value) {
      try {
        var cat = categories.firstWhere((c) => c.id == key);
        result.add({
          'category': cat,
          'amount': value,
          'percent': totalExpense == 0 ? 0 : (value / totalExpense),
        });
      } catch (_) {}
    });
    result.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );
    return result;
  }
}
