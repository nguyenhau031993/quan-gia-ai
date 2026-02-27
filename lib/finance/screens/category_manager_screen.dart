import 'package:flutter/material.dart';
import '../../finance_core.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen>
    with SingleTickerProviderStateMixin {
  final _manager = FinanceManager();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addCategory(TransactionType type) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thêm hạng mục mới"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Tên hạng mục"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _manager.addCategory(
                    nameCtrl.text,
                    type,
                    Icons.category,
                    Colors.blue,
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category cat) {
    if (cat.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể xóa hạng mục mặc định")),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa hạng mục?"),
        content: const Text(
          "Dữ liệu lịch sử của hạng mục này vẫn sẽ được giữ lại.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              setState(() => _manager.deleteCategory(cat.id));
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Hạng mục"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "CHI TIÊU"),
            Tab(text: "THU NHẬP"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(TransactionType.expense),
          _buildList(TransactionType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategory(
          _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(TransactionType type) {
    final list = _manager.categories.where((c) => c.type == type).toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final cat = list[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: cat.color.withOpacity(0.1),
            child: Icon(cat.icon, color: cat.color),
          ),
          title: Text(cat.name),
          trailing: cat.isDefault
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => _deleteCategory(cat),
                ),
        );
      },
    );
  }
}
