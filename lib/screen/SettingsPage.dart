
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money/screen/ContactUsScreen.dart';
import 'package:money/screen/PrivacyPolicyScreen.dart';
import 'package:money/screen/termscondtion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  InterstitialAd? _interstitialAd;
 bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1966206743776147/8983984249', // Test ad unit ID
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
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              print('Interstitial Ad failed to show: $error');
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              });
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial Ad failed to load: $error');
          if (!mounted) return;
          setState(() {
            _isInterstitialAdReady = false;
            _interstitialAd = null;
          });
          // Optional: retry loading after delay here
        },
      ),
    );
  }

  void _showInterstitialAdAndNavigate(Widget screen) {
    if (_interstitialAd == null) {
      // If ad not ready, just navigate directly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
      _loadInterstitialAd(); // try loading next ad
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _loadInterstitialAd(); // Load next ad

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _loadInterstitialAd();

        // If ad fails to show, navigate anyway
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // Prevent reuse
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD6A5), Color(0xFFFF8BB5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildSettingsTile(
                  context,
                  'Privacy Policy',
                  Colors.white,
                  false,
                  () => _showInterstitialAdAndNavigate(const PrivacyPolicyScreen()),
                ),
                SizedBox(height: 1.5.h),
                _buildSettingsTile(
                  context,
                  'Terms & Conditions',
                  Colors.white,
                  false,
                  () => _showInterstitialAdAndNavigate(const TermsConditionsScreen()),
                ),
                SizedBox(height: 1.5.h),
                _buildSettingsTile(
                  context,
                  'Contact Us',
                  Colors.white,
                  false,
                  () => _showInterstitialAdAndNavigate(const ContactUsScreen()),
                ),
                SizedBox(height: 1.5.h),
              _buildSettingsTil(
  context,
  'Logout',
  Colors.red[100]!,
  true,
  () async {
    if (_interstitialAd != null && _isInterstitialAdReady) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          _loadInterstitialAd();

          // Clear login state on logout
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);

          await FirebaseAuth.instance.signOut();

          Navigator.pushNamedAndRemoveUntil(context, '/sign', (route) => false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
          _loadInterstitialAd();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);

          await FirebaseAuth.instance.signOut();

          Navigator.pushNamedAndRemoveUntil(context, '/sign', (route) => false);
        },
      );
      _interstitialAd!.show();
    } else {
      // If ad not ready, logout directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      await FirebaseAuth.instance.signOut();

      Navigator.pushNamedAndRemoveUntil(context, '/sign', (route) => false);
    }
  },
),
                const Spacer(),
                Center(
                  child: Text(
                    'App Version 1.0.0',
                    style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
Widget _buildSettingsTil(
  BuildContext context,
  String title,
  Color color,
  bool isLogout,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red : Colors.black,
              fontSize: 16.sp,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    Color color,
    bool isLogout,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isLogout ? Colors.red : Colors.black,
                fontSize: 16.sp,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: isLogout ? Colors.red : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
