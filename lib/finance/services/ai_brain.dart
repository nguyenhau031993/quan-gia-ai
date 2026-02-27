import 'package:intl/intl.dart';
import '../../finance_core.dart';
import 'dart:math';

class AIBrain {
  final FinanceManager _manager = FinanceManager();
  final NumberFormat _fmt = NumberFormat("#,###", "vi_VN");

  // Hàm nhận câu hỏi và trả về câu trả lời
  String ask(String question) {
    String q = question.toLowerCase();

    // 1. Hỏi về số dư / tài sản
    if (q.contains('tiền') || q.contains('số dư') || q.contains('tài sản')) {
      double total = _manager.getTotalAssets();
      if (total == 0)
        return "Bạn đang chưa có đồng nào (0đ). Hãy chăm chỉ kiếm tiền nhé! 💪";
      if (total < 0)
        return "Cảnh báo! Bạn đang âm nợ ${_fmt.format(total.abs())} đ. Cần thắt chặt chi tiêu ngay! 🚨";
      return "Tổng tài sản hiện tại của bạn là ${_fmt.format(total)} đ. 💰";
    }

    // 2. Hỏi về tình hình chi tiêu tháng này
    if (q.contains('chi tiêu') ||
        q.contains('tiêu') ||
        q.contains('tháng này')) {
      DateTime now = DateTime.now();
      double expense = _manager.transactions
          .where(
            (t) =>
                t.date.month == now.month &&
                _manager.categories
                        .firstWhere((c) => c.id == t.categoryId)
                        .type ==
                    TransactionType.expense,
          )
          .fold(0, (sum, t) => sum + t.amount);

      if (expense == 0)
        return "Tháng này bạn chưa tiêu gì cả. Quá tiết kiệm! 👏";
      return "Tháng này bạn đã tiêu hết ${_fmt.format(expense)} đ. Hãy xem lại ngân sách nếu thấy con số này quá lớn nhé.";
    }

    // 3. Hỏi về nợ nần
    if (q.contains('nợ') || q.contains('vay')) {
      // Logic tìm nợ (l2 là đi vay)
      double debt = _manager.transactions
          .where((t) => t.categoryId == 'l2') // l2 là Đi vay
          .fold(0, (sum, t) => sum + t.amount);

      if (debt == 0)
        return "Tuyệt vời! Bạn không nợ ai đồng nào cả. Tự do tài chính! 🗽";
      return "Bạn đang ghi nhận khoản nợ là ${_fmt.format(debt)} đ. Hãy nhớ trả đúng hạn nhé.";
    }

    // 4. Tư vấn tài chính (Lời khuyên)
    if (q.contains('khuyên') || q.contains('tư vấn')) {
      return _getAdvice();
    }

    // 5. Chào hỏi
    if (q.contains('chào') || q.contains('hello') || q.contains('hi')) {
      return "Xin chào! Tôi là Trợ lý AIA. Tôi có thể giúp bạn tra cứu số dư, xem chi tiêu hoặc đưa ra lời khuyên. Bạn muốn hỏi gì?";
    }

    // Mặc định
    return "Xin lỗi, tôi chưa hiểu ý bạn. Bạn thử hỏi: 'Tôi còn bao nhiêu tiền?' hoặc 'Tư vấn cho tôi' xem sao?";
  }

  // Hàm sinh lời khuyên ngẫu nhiên dựa trên dữ liệu
  String _getAdvice() {
    double total = _manager.getTotalAssets();
    List<String> advices = [
      "Quy tắc 50/30/20: Hãy dành 50% cho thiết yếu, 30% cho sở thích và 20% để tiết kiệm nhé.",
      "Đừng để tiền nằm im! Hãy thử gửi tiết kiệm hoặc đầu tư vào bản thân.",
      "Bạn nên kiểm tra lại các khoản chi nhỏ lẻ (như cà phê, ăn vặt), chúng tốn kém hơn bạn nghĩ đấy!",
    ];

    if (total > 100000000) {
      advices.add(
        "Tài sản của bạn khá tốt! Hãy cân nhắc đầu tư để tiền đẻ ra tiền.",
      );
    } else if (total < 5000000) {
      advices.add(
        "Số dư hiện tại hơi thấp. Hãy cố gắng tăng thu nhập và giảm chi tiêu nhé.",
      );
    }

    return advices[Random().nextInt(advices.length)];
  }
}
