import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muniafu/data/models/onboarding.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Sample onboarding data - can be replaced with Firestore data
  final List<Onboarding> onboardingItems = [
    Onboarding(
      title: 'Find Hotels',
      description: 'Discover hotels at best rates with ease.',
      imagePath: 'assets/images/onboarding1.png',
      showSkipButton: true,
      durationSeconds: 5,
    ),
    Onboarding(
      title: 'Book Rooms',
      description: 'Book your stay instantly and securely.',
      imagePath: 'assets/images/onboarding2.png',
      ctaText: 'Next',
      showSkipButton: true,
    ),
    Onboarding(
      title: 'Enjoy Your Stay',
      description: 'Experience comfort and luxury.',
      imagePath: 'assets/images/onboarding3.png',
      ctaText: 'Get Started',
      showSkipButton: false,
      routeName: '/welcome',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAutoAdvance();
  }

  void _setupAutoAdvance() {
    // Auto-advance logic for pages with duration
    for (int i = 0; i < onboardingItems.length; i++) {
      final duration = onboardingItems[i].durationSeconds;
      if (duration != null && duration > 0) {
        Future.delayed(Duration(seconds: duration * (i + 1)), () {
          if (mounted && _currentPage == i) {
            _nextPage();
          }
        });
      }
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    
    final nextRoute = onboardingItems[_currentPage].routeName ?? '/welcome';
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _nextPage() {
    if (_currentPage < onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildPageView(),
            _buildSkipButton(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: onboardingItems.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (_, index) {
        final item = onboardingItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(item),
              const SizedBox(height: 40),
              _buildTitle(item),
              const SizedBox(height: 16),
              _buildDescription(item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(Onboarding item) {
    return item.imagePath.startsWith('http')
        ? Image.network(
            item.imagePath,
            height: 280,
            fit: BoxFit.contain,
          )
        : Image.asset(
            item.imagePath,
            height: 280,
            fit: BoxFit.contain,
          );
  }

  Widget _buildTitle(Onboarding item) {
    return Text(
      item.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(Onboarding item) {
    return Text(
      item.description,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSkipButton() {
    final currentItem = onboardingItems[_currentPage];
    if (currentItem.showSkipButton != true) return const SizedBox();

    return Positioned(
      top: 16,
      right: 16,
      child: TextButton(
        onPressed: _skipOnboarding,
        child: const Text(
          "Skip",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          _buildDotsIndicator(),
          const SizedBox(height: 30),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingItems.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final currentItem = onboardingItems[_currentPage];
    final buttonText = currentItem.ctaText ??
        (_currentPage == onboardingItems.length - 1 ? "Get Started" : "Next");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ButtonWidget.filled(
        text: buttonText,
        onPressed: _isLoading ? null : _nextPage,
        isFullWidth: true,
        isLoading: _isLoading,
      ),
    );
  }
}