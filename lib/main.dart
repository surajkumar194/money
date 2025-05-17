import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money/firebase_optional.dart';
import 'package:money/screen/SettingsPage.dart';
import 'package:money/screen/SignInPage.dart';
import 'package:money/screen/SignUpPage.dart';
import 'package:money/screen/TasksPage.dart';
import 'package:money/screen/WithdrawPage.dart';
import 'package:money/screen/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'captcha money',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const RootPage(),
          routes: {
            '/signup': (context) => const SignUpPage(),
            '/sign': (context) => const SignInPage(),
            '/main': (context) => const MainPage(),
          },
        );
      },
    );
  }
}

// This StatefulWidget checks login status and displays correct page
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      // Loading state
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_isLoggedIn!) {
      return const MainPage();
    } else {
      return const SignInPage();
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  double earnedAmount = 0.0;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();

    // Load interstitial ad on init
    _loadInterstitialAd();

    // Show interstitial ad 10 seconds after entering the main page
    Timer(const Duration(seconds: 10), () {
      if (_isInterstitialAdReady && _interstitialAd != null) {
        _interstitialAd!.show();
      }
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1966206743776147/8983984249', 
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (!mounted) return;
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });
          print('Interstitial Ad loaded');

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              });
              _loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              print('Interstitial Ad failed to show: $error');
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              });
              _loadInterstitialAd(); // Try loading again
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial Ad failed to load: $error');
          // Optionally retry loading here
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      WalletPage(
        onEarningsUpdated: (newAmount) {
          setState(() {
            earnedAmount = newAmount;
          });
        },
      ),
      const TasksPage(),
      WithdrawPage(availableBalance: earnedAmount),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Withdraw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
