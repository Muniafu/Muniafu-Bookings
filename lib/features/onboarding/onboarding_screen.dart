import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Combined and enhanced onboarding data
  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding.png",
      "title": "Welcome to HotelEase",
      "description": "Find the best hotels at the best prices around the world."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Easy Booking",
      "description": "Book your stay in just a few clicks with real-time availability."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Your Travel Companion",
      "description": "Manage your trips, check-in online, and get local tips."
    },
  ];

  Future<void> _completeOnboarding() async {
    // Save that onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    
    // Navigate to the next screen (either WelcomeScreen or Signup)
    if (!mounted) return;
    
    Navigator.pushReplacementNamed(context, '/welcomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top right
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text("Skip"),
              ),
            ),
            
            // Main content area with PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) => _buildOnboardingPage(
                  onboardingData[index]["title"]!,
                  onboardingData[index]["description"]!,
                  onboardingData[index]["image"]!,
                ),
              ),
            ),
            
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => _buildDot(index),
              ),
            ),
            
            // Bottom navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == onboardingData.length - 1
                      ? _completeOnboarding
                      : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                  child: Text(
                    _currentPage == onboardingData.length - 1 
                        ? "Get Started" 
                        : "Next",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(String title, String description, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
          ? Theme.of(context).primaryColor 
          : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }


}