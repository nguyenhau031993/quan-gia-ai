import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../../finance_core.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _manager = FinanceManager();
  bool _isLoading = false;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd(); // Tải sẵn video quảng cáo ngay khi mở màn hình
  }

  // Tải Quảng Cáo Video
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-6795823365574837/5117645329', // MÃ QUẢNG CÁO VIDEO THẬT CỦA ANH
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void _checkIn() async {
    setState(() => _isLoading = true);

    // Nếu quảng cáo đã tải xong thì phát video
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // Chỉ cộng xu khi khách HỌC XEM HẾT VIDEO
          _manager.doCheckIn();
          _showSuccessDialog();
        },
      );

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // Tắt video xong tải luôn video khác cho ngày mai
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadRewardedAd();
          _fallbackCheckIn(); // Nếu video lỗi không hiện được thì cho điểm danh chay
        },
      );
    } else {
      // Nếu mạng lag chưa tải xong video, cho điểm danh chay để khách không chửi
      _fallbackCheckIn();
    }
  }

  void _fallbackCheckIn() async {
    await Future.delayed(const Duration(seconds: 1));
    _manager.doCheckIn();
    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Tuyệt vời!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Bạn vừa xem xong quảng cáo và nhận được +100 Xu.\nTích xu để đổi gói VIP nhé!",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {}); // Cập nhật lại số xu trên màn hình
            },
            child: const Text(
              "ĐÓNG",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCheckedIn =
        _manager.user.lastCheckIn ==
        DateFormat("yyyy-MM-dd").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm xu mỗi ngày"), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            if (!isCheckedIn)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.play_circle_fill, color: Colors.white),
                label: const Text(
                  "XEM QUẢNG CÁO (+100 XU)",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    Text(
                      "Hôm nay bạn đã nhận xu rồi",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 50),
            const Text(
              "Tổng xu tích lũy của bạn:",
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              "${_manager.user.coins}",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
