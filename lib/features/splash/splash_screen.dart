
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showOnboarding = false;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Easy Hotel Booking',
      'desc': 'Search and book hotels in seconds.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Best Deals',
      'desc': 'Get exclusive discounts and offers.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Real Reviews',
      'desc': 'Read trusted reviews before booking.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_done') ?? false;

    await Future.delayed(const Duration(seconds: 3));

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (seen) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showOnboarding ? _buildOnboarding() : _buildSplash(),
    );
  }

  Widget _buildSplash() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text("Hotel Booking App", style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboarding() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(item['image']!, height: 300, fit: BoxFit.contain),
                  const SizedBox(height: 30),
                  Text(item['title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(item['desc']!, textAlign: TextAlign.center),
                  )
                ],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            onboardingData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? Colors.indigo : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _completeOnboarding,
                child: const Text("Skip"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_currentIndex == onboardingData.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                },
                child: Text(_currentIndex == onboardingData.length - 1 ? "Get Started" : "Next"),
              )
            ],
          ),
        )
      ],
    );
  }
}