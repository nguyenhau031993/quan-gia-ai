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

  // DANH SÁCH 2 GÓI CƯỚC (BẮT BUỘC PHẢI TẠO TRÊN GOOGLE PLAY)
  final List<String> _kProductIds = [
    'premium_monthly_39k',
    'premium_yearly_365k',
  ];

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String _selectedProductId = 'premium_monthly_39k';

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
    );
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() => _isAvailable = isAvailable);
      return;
    }
    if (Platform.isAndroid) {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_kProductIds.toSet());
      if (response.error == null && response.productDetails.isNotEmpty) {
        setState(() => _products = response.productDetails);
      }
    }
    setState(() => _isAvailable = isAvailable);
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _purchasePending = true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() => _purchasePending = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Thanh toán bị hủy.")));
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _manager.upgradeToPremium();
          setState(() => _purchasePending = false);
          if (mounted) _showSuccessDialog();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _buyPremium() {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Không tìm thấy gói cước. Vui lòng thử lại sau."),
        ),
      );
      return;
    }
    ProductDetails product = _products.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => _products.first,
    );
    PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Icon(
          Icons.workspace_premium,
          color: Colors.amber,
          size: 60,
        ),
        content: const Text(
          "Chúc mừng Sếp đã lên cấp VIP!",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("BẮT ĐẦU"),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Nâng cấp VIP"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: isVip ? _buildVipActive() : _buildPurchaseLayout(),
    );
  }

  Widget _buildVipActive() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
          SizedBox(height: 20),
          Text(
            "BẠN ĐANG LÀ THÀNH VIÊN VIP",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tất cả tính năng đã được mở khóa",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.diamond, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          const Text(
            "Không Quảng Cáo & Đầy Đủ Tiện Ích",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          // Gói Tháng
          _buildPackageOption(
            'premium_monthly_39k',
            "Gói Hàng Tháng",
            "39.000đ / tháng",
            "Dùng thử linh hoạt",
          ),
          const SizedBox(height: 15),
          // Gói Năm
          _buildPackageOption(
            'premium_yearly_365k',
            "Gói Hàng Năm",
            "365.000đ / năm",
            "Tiết kiệm 20%",
            isBestValue: true,
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (_purchasePending || !_isAvailable)
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
                  : const Text(
                      "THANH TOÁN NGAY",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(
    String id,
    String title,
    String price,
    String sub, {
    bool isBestValue = false,
  }) {
    bool isSelected = _selectedProductId == id;
    return InkWell(
      onTap: () => setState(() => _selectedProductId = id),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.cardBg,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "HOT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    sub,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
