import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../finance_core.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _manager = FinanceManager();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // MÃ GÓI CƯỚC TẠO TRÊN GOOGLE PLAY CONSOLE
  final String _productId = 'premium_monthly_39k';

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Lắng nghe luồng thanh toán trả về từ Google
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // Xử lý lỗi kết nối
      },
    );

    _initStoreInfo();
  }

  // Khởi tạo và lấy thông tin gói cước từ Google
  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _loading = false;
      });
      return;
    }

    if (Platform.isAndroid) {
      final ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails({_productId}.toSet());

      if (productDetailResponse.error == null &&
          productDetailResponse.productDetails.isNotEmpty) {
        setState(() {
          _products = productDetailResponse.productDetails;
        });
      }
    }

    setState(() {
      _isAvailable = isAvailable;
      _loading = false;
    });
  }

  // Hàm xử lý khi Google báo kết quả thanh toán
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _purchasePending = true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() => _purchasePending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thanh toán bị hủy hoặc có lỗi.")),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // === THANH TOÁN THÀNH CÔNG ===
          _manager.upgradeToPremium(); // Kích hoạt VIP trong Core
          setState(() => _purchasePending = false);

          if (mounted) {
            _showSuccessDialog();
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Hàm bấm nút Mua
  void _buyPremium() {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy thông tin gói cước.")),
      );
      return;
    }
    late PurchaseParam purchaseParam;
    purchaseParam = PurchaseParam(productDetails: _products.first);
    // Đây là lệnh gọi cửa sổ thanh toán của Google Play lên
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text(
              "Thanh toán thành công!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Cảm ơn bạn đã nâng cấp VIP. Mọi quảng cáo đã được gỡ bỏ.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "BẮT ĐẦU TRẢI NGHIỆM",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVip = _manager.isPremium;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AIA Premium", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            width: double.infinity,
            color: Colors.amber,
            child: const Column(
              children: [
                Icon(Icons.diamond, size: 80, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Nâng tầm quản lý tài chính",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                ListTile(
                  leading: Icon(Icons.block, color: Colors.red),
                  title: Text("Xóa toàn bộ quảng cáo"),
                ),
                ListTile(
                  leading: Icon(Icons.cloud_sync, color: Colors.blue),
                  title: Text("Đồng bộ dữ liệu đám mây"),
                ),
                ListTile(
                  leading: Icon(Icons.pie_chart, color: Colors.purple),
                  title: Text("Báo cáo nâng cao không giới hạn"),
                ),
                ListTile(
                  leading: Icon(Icons.support_agent, color: Colors.green),
                  title: Text("Hỗ trợ ưu tiên 24/7"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: isVip
                ? Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          "BẠN ĐÃ LÀ VIP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_loading || !_isAvailable || _purchasePending)
                          ? null
                          : _buyPremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _purchasePending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _products.isNotEmpty
                                  ? "NÂNG CẤP NGAY - ${_products.first.price}" // Lấy giá thật từ Google (39.000đ)
                                  : "ĐANG KẾT NỐI CH PLAY...",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
