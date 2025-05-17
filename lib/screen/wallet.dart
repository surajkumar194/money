import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money/screen/WithdrawPage.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Add this
import 'package:sizer/sizer.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required Null Function(dynamic newAmount) onEarningsUpdated});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String captcha = '';
  final TextEditingController _controller = TextEditingController();
  int solvedCount = 0;
  double earnedAmount = 0.0;
  int attempts = 0;
  String message = '';
  bool showCoins = false;
  int coinsToShow = 0;
  Timer? _coinTimer;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  // Added variables for Native Ad
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _generateCaptcha();
    _loadInterstitialAd();
    _loadNativeAd();  // <-- Load native ad here
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      earnedAmount = prefs.getDouble('earnedAmount') ?? 0.0;
      solvedCount = prefs.getInt('solvedCount') ?? 0;
      coinsToShow = prefs.getInt('coinsToShow') ?? 0;
      showCoins = coinsToShow > 0;
    });

    if (showCoins) {
      _startCoinAnimation();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('earnedAmount', earnedAmount);
    await prefs.setInt('solvedCount', solvedCount);
    await prefs.setInt('coinsToShow', coinsToShow);
  }

  @override
  void dispose() {
    _controller.dispose();
    _coinTimer?.cancel();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();  // <-- Dispose native ad here
    super.dispose();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-1966206743776147/9530779152', // Test Native Ad ID
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('NativeAd failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
          textColor: Colors.white,
          backgroundColor: Colors.blueAccent,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          size: 1.0,
          textColor: Colors.white,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          size: 1.0,
          textColor: Colors.white,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          size: 1.0,
          textColor: Colors.white,
        ),
      ),
    )..load();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    setState(() {
      captcha = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
      _controller.clear();
      message = '';
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1966206743776147/8983984249',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAdIfNeeded() {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdReady = false;
    }
  }

  void _onSubmit() {
    final input = _controller.text.trim().toUpperCase();
    attempts++;

    if (input == captcha) {
      setState(() {
        solvedCount++;
        earnedAmount += 0.001;
        coinsToShow += 10;   // add 10 coins per correct captcha
        showCoins = true;
        message = 'Correct! You earned ₹0.001';
      });
      _saveData();
      _startCoinAnimation();

      if (attempts % 5 == 0) {
        _showInterstitialAdIfNeeded();
      }

      _generateCaptcha();
    } else {
      setState(() {
        message = 'Wrong captcha, try again!';
      });
    }
  }

  void _startCoinAnimation() {
    int coinsLeft = coinsToShow;
    _coinTimer?.cancel();

    _coinTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (coinsLeft <= 0) {
        timer.cancel();
        setState(() {
          showCoins = false;
        });
        _saveData();
      } else {
        setState(() {
          coinsToShow = coinsLeft - 1;
        });
        coinsLeft--;
      }
    });
  }

  // Call this method after withdrawal to reset coins and earnings locally
  Future<void> _onWithdrawComplete() async {
    setState(() {
      earnedAmount = 0.0;
      coinsToShow = 0;
      showCoins = false;
      solvedCount = 0;
    });
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B5BFF), Color(0xFFAB5BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Captcha Wallet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Solved: $solvedCount',
                              style: TextStyle(color: Colors.white, fontSize: 17.sp),
                            ),
                            Text(
                              'Earned: ₹${earnedAmount.toStringAsFixed(4)}',
                              style: TextStyle(color: Colors.white, fontSize: 17.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5B7B), Color(0xFFFF8BB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    captcha,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 3.h),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter captcha text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                SizedBox(height: 3.h),
                Text(
                  message,
                  style: TextStyle(
                    color: message.contains('Correct') ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit & Earn ₹0.001',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WithdrawPage(
                          availableBalance: earnedAmount,
                        ),
                      ),
                    );
                    // After coming back from WithdrawPage, reset coins and earnings
                    await _onWithdrawComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (showCoins)
                  Center(
                    child: Text(
                      '💰' * (10 - coinsToShow),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),

                if (_isAdLoaded && _nativeAd != null)
                  Container(
                    height: 25.h,
                    width: 90.w,
                    child: AdWidget(ad: _nativeAd!),
                  )
                else
                  Container(
                    height: 20.h,
                    width: 90.w,
                    color: Colors.grey[300],
                    child: const Center(child: Text("Loading Ad...")),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
