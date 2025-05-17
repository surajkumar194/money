import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  final tasks = [
    ['Train AI & Earn', [Color(0xFF00C6FF), Color(0xFF0072FF)], 'Train AI & Earn'],
    ['Translate & Earn', [Color(0xFFFFB6B9), Color(0xFFFED6E3)], 'Translate & Earn'],
    ['Guess & Earn', [Color(0xFFE0C3FC), Color(0xFF8EC5FC)], 'Guess & Earn'],
    ['Refer & Earn', [Color(0xFFFFE0B2), Color(0xFFFFD1DC)], 'Refer & Earn'],
    ['Play & Earn', [Color(0xFFFFA17F), Color(0xFFFF6F61)], 'Play & Earn'],
    ['Read & Earn', [Color(0xFF00F2FE), Color(0xFF4FACFE)], 'Read & Earn'],
    ['Rate & Earn', [Color(0xFFFFD194), Color(0xFFFFC3A0)], 'Rate & Earn'],
    ['Download & Earn', [Color(0xFFA1C4FD), Color(0xFFC2E9FB)], 'Download & Earn'],
    ['Views & Earn', [Color(0xFF9D50BB), Color(0xFF6E48AA)], 'Views & Earn'],
    ['Special Task', [Color(0xFF43C6AC), Color(0xFF191654)], 'Special Task'],
  ];

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      // Use Google's test ad unit ID for testing
      adUnitId: 'ca-app-pub-1966206743776147/8983984249', // Replace with your real ad unit ID in production
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (!mounted) return;
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });
          print('Interstitial Ad loaded successfully');

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('Interstitial Ad shown');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('Interstitial Ad dismissed');
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              });
              _loadInterstitialAd(); // Reload ad for next use
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('Interstitial Ad failed to show: $error');
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _interstitialAd = null;
              });
              _loadInterstitialAd(); // Reload ad for next use
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
          // Retry loading ad after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _showInterstitialThenNavigate(BuildContext context, String title) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show().then((_) {
        // Navigate after ad is shown
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskPage(taskTitle: title)));
      }).catchError((error) {
        print('Error showing interstitial ad: $error');
        // Navigate even if ad fails to show
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskPage(taskTitle: title)));
      });
      setState(() {
        _isInterstitialAdReady = false;
        _interstitialAd = null;
      });
    } else {
      // Navigate directly if ad is not ready
      Navigator.push(context, MaterialPageRoute(builder: (_) => TaskPage(taskTitle: title)));
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Complete Tasks & Earn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.8,
                    children: tasks.map((task) {
                      return _buildGradientButton(
                        context,
                        task[0] as String,
                        task[1] as List<Color>,
                        task[2] as String,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context, String title, List<Color> colors, String taskTitle) {
    return GestureDetector(
      onTap: () => _showInterstitialThenNavigate(context, taskTitle),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TaskPage extends StatefulWidget {
  final String taskTitle;
  const TaskPage({super.key, required this.taskTitle});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  InterstitialAd? _secondAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSecondAd();
  }

  void _loadSecondAd() {
    InterstitialAd.load(
      // Use Google's test ad unit ID for testing
      adUnitId: 'ca-app-pub-1966206743776147/8983984249', // Replace with your real ad unit ID in production
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (!mounted) return;
          setState(() {
            _secondAd = ad;
            _isInterstitialAdReady = true;
          });
          print('Second Interstitial Ad loaded successfully');

          _secondAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('Second Interstitial Ad shown');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('Second Interstitial Ad dismissed');
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _secondAd = null;
              });
              _loadSecondAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('Second Interstitial Ad failed to show: $error');
              ad.dispose();
              if (!mounted) return;
              setState(() {
                _isInterstitialAdReady = false;
                _secondAd = null;
              });
              _loadSecondAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Second Interstitial Ad failed to load: $error');
          if (!mounted) return;
          setState(() {
            _isInterstitialAdReady = false;
            _secondAd = null;
          });
          // Retry loading ad after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadSecondAd();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _secondAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Coming Soon',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_isInterstitialAdReady && _secondAd != null) {
                    _secondAd!.show().then((_) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NoAd()));
                    }).catchError((error) {
                      print('Error showing second interstitial ad: $error');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NoAd()));
                    });
                    setState(() {
                      _isInterstitialAdReady = false;
                      _secondAd = null;
                    });
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NoAd()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Early Access This Feature →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoAd extends StatelessWidget {
  const NoAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7F00FF),
      appBar: AppBar(
        title: const Text("Access Denied"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "⚠ Access Denied",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "You are currently not eligible to access this feature. Access is restricted to selected users at this time.\n\n"
                  "We will notify you once you become eligible.\n\n"
                  "Meanwhile, check other tasks or please complete the captcha to continue earning. 😉",
                  style: TextStyle(color: Colors.white, fontSize: 17.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}