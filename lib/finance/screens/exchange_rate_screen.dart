import 'dart:convert'; // Để xử lý dữ liệu JSON từ mạng
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Thư viện kết nối mạng
import 'package:intl/intl.dart'; // Để định dạng số tiền

// 1. MODEL DỮ LIỆU (Cấu trúc của một đồng tiền)
class RateInfo {
  final String code; // Mã tiền tệ (USD, EUR...)
  final String name; // Tên đầy đủ
  final String flag; // Cờ quốc gia
  double buyPrice; // Giá mua vào (VND)
  double sellPrice; // Giá bán ra (VND)

  RateInfo({
    required this.code,
    required this.name,
    required this.flag,
    required this.buyPrice,
    required this.sellPrice,
  });
}

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  // Danh sách các đồng tiền muốn theo dõi
  final List<RateInfo> _currencies = [
    RateInfo(
      code: 'USD',
      name: 'Đô la Mỹ',
      flag: '🇺🇸',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'EUR',
      name: 'Euro',
      flag: '🇪🇺',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'JPY',
      name: 'Yên Nhật',
      flag: '🇯🇵',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'GBP',
      name: 'Bảng Anh',
      flag: '🇬🇧',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'CNY',
      name: 'Nhân dân tệ',
      flag: '🇨🇳',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'KRW',
      name: 'Won Hàn Quốc',
      flag: '🇰🇷',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'SGD',
      name: 'Đô la Singapore',
      flag: '🇸🇬',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'THB',
      name: 'Baht Thái',
      flag: '🇹🇭',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'AUD',
      name: 'Đô la Úc',
      flag: '🇦🇺',
      buyPrice: 0,
      sellPrice: 0,
    ),
    RateInfo(
      code: 'CAD',
      name: 'Đô la Canada',
      flag: '🇨🇦',
      buyPrice: 0,
      sellPrice: 0,
    ),
  ];

  bool _isLoading = true; // Trạng thái đang tải
  String _errorMessage = ''; // Lưu lỗi nếu có
  String _lastUpdated = ''; // Thời gian cập nhật cuối

  @override
  void initState() {
    super.initState();
    _fetchLiveRates(); // Gọi hàm lấy dữ liệu ngay khi mở màn hình
  }

  // 2. HÀM KẾT NỐI MẠNG LẤY TỶ GIÁ THẬT (CORE FUNCTION)
  Future<void> _fetchLiveRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // API miễn phí lấy tỷ giá dựa trên USD
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> rates = data['rates'];

        // Lấy tỷ giá USD/VND làm gốc (Ví dụ: 1 USD = 25,400 VND)
        double usdToVnd = (rates['VND'] as num).toDouble();

        // Cập nhật giá cho từng đồng tiền trong danh sách
        for (var item in _currencies) {
          if (item.code == 'USD') {
            item.buyPrice = usdToVnd;
            item.sellPrice = usdToVnd + 300; // Giá bán thường cao hơn chút
          } else {
            // Tính chéo: 1 EUR = (1 / Tỷ giá EUR_so_với_USD) * Tỷ giá USD_VND
            // Ví dụ: 1 USD = 0.92 EUR -> 1 EUR = 1.08 USD -> 1.08 * 25,400 = 27,432 VND
            double rateToUsd = (rates[item.code] as num).toDouble();
            double priceInVnd = (1 / rateToUsd) * usdToVnd;

            item.buyPrice = priceInVnd;
            item.sellPrice =
                priceInVnd * 1.015; // Giả lập chênh lệch mua/bán 1.5%
          }
        }

        // Lấy thời gian cập nhật
        int timestamp = data['time_last_updated'];
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        _lastUpdated = DateFormat('HH:mm dd/MM/yyyy').format(date);

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Không thể kết nối Internet!\nVui lòng kiểm tra Wifi/4G.";
      });
      debugPrint("Lỗi lấy tỷ giá: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat("#,###.##", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tỷ giá Ngoại tệ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchLiveRates,
            tooltip: "Cập nhật",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header thông báo trạng thái
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.grey[100],
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLoading ? "Đang cập nhật..." : "Cập nhật: $_lastUpdated",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const Text(
                  "Đơn vị: VNĐ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          // Nội dung chính
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchLiveRates,
                          child: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _currencies.length,
                    separatorBuilder: (ctx, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _currencies[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Cờ và Mã tiền tệ
                            Text(
                              item.flag,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Giá Mua / Bán
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Mua: ",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      currencyFmt.format(item.buyPrice),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      "Bán: ",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      currencyFmt.format(item.sellPrice),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Ghi chú nguồn dữ liệu
          if (!_isLoading && _errorMessage.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Nguồn dữ liệu: ExchangeRate-API (Quốc tế)",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
