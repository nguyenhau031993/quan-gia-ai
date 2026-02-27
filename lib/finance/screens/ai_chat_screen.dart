import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FinanceManager _manager = FinanceManager();
  final NumberFormat _fmt = NumberFormat("#,###", "vi_VN");

  final List<Map<String, String>> _messages = [
    {
      "role": "ai",
      "text":
          "Chào sếp! Tôi là Quản gia AI. Sếp có thể hỏi tôi về số dư, tổng chi tiêu tháng này, hoặc mắng vốn tôi nếu sếp lỡ tiêu hoang nhé! 🤖",
    },
  ];
  bool _isTyping = false;

  // BỘ NÃO AI (Phân tích truy vấn nội bộ)
  String _processAIQuery(String query) {
    String lower = query.toLowerCase();

    // 1. Hỏi về số dư
    if (lower.contains("số dư") ||
        lower.contains("còn lại") ||
        lower.contains("có bao nhiêu")) {
      double total = _manager.getTotalAssets();
      return "Sếp hiện đang có tổng cộng ${_fmt.format(total)} VNĐ trong tất cả các ví. ${total < 500000 ? 'Sắp mạt rệp rồi, tiết kiệm đi sếp!' : 'Khá rủng rỉnh đấy sếp!'}";
    }

    // 2. Hỏi về tổng chi tiêu
    if (lower.contains("chi tiêu") ||
        lower.contains("đã tiêu") ||
        lower.contains("tổng chi")) {
      DateTime now = DateTime.now();
      double totalSpent = _manager.transactions
          .where((t) => t.date.month == now.month && t.date.year == now.year)
          .where((t) {
            try {
              return _manager.categories
                      .firstWhere((c) => c.id == t.categoryId)
                      .type ==
                  TransactionType.expense;
            } catch (_) {
              return false;
            }
          })
          .fold(0, (sum, item) => sum + item.amount);

      return "Trong tháng này sếp đã đốt hết ${_fmt.format(totalSpent)} VNĐ rồi. ${totalSpent > 3000000 ? 'Tốc độ đốt tiền của sếp nhanh hơn tốc độ ánh sáng đấy!' : 'Vẫn trong tầm kiểm soát, tốt lắm sếp!'}";
    }

    // 3. Phân tích một khoản vừa mua (Ví dụ: "Tôi vừa mua trà sữa 50k")
    if (lower.contains("trà sữa") ||
        lower.contains("nhậu") ||
        lower.contains("shopee")) {
      return "Lại nữa à sếp? Những khoản lặt vặt như thế này chính là nguyên nhân khiến cuối tháng sếp phải ăn mì tôm đấy. Lần sau kiềm chế lại nhé!";
    }

    // 4. Mặc định
    return "Tính năng này đang được nâng cấp. Sếp hãy hỏi tôi về 'Số dư' hoặc 'Tổng chi tiêu tháng này' nhé!";
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _controller.clear();
      _isTyping = true;
    });

    FocusScope.of(context).unfocus(); // Đóng bàn phím

    // Giả lập AI đang suy nghĩ
    await Future.delayed(const Duration(seconds: 1));

    String reply = _processAIQuery(userText);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({"role": "ai", "text": reply});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.amber),
            SizedBox(width: 10),
            Text("Quản gia AI"),
          ],
        ),
        backgroundColor: AppColors.cardBg,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quản gia đang gõ chữ...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.cardBg,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Hỏi: Tháng này tiêu bao nhiêu?",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
