import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingContent {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

final List<OnboardingContent> contents = [
  const OnboardingContent(
    imagePath: 'assets/onboarding/shopping.gif',
    title: 'Explore Top Products',
    description:
        'Find thousands of products from the best brands, all in one place.',
  ),
  const OnboardingContent(
    imagePath: 'assets/onboarding/checkout.gif',
    title: 'Fast & Secure Checkout',
    description:
        'Add items to your cart and complete your purchase in just a few taps.',
  ),
  const OnboardingContent(
    imagePath: 'assets/onboarding/delivery.gif',
    title: 'Track Orders Live',
    description:
        'Get real-time updates on your delivery from our warehouse to your door.',
  ),
];

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            content.imagePath,
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.shopping_bag_outlined,
              size: 150,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),

          Text(
            content.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            content.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  final Duration _scrollDuration = const Duration(seconds: 5);
  final Duration _scrollAnimation = const Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(_scrollDuration, (Timer timer) {
      int nextPageIndex = (_currentPage + 1) % contents.length;

      _pageController.animateToPage(
        nextPageIndex,
        duration: _scrollAnimation,
        curve: Curves.easeOut,
      );
    });
  }

  void _resetAutoScrollTimer() {
    _autoScrollTimer?.cancel();

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _finishOnboarding() {
    widget.onComplete();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollStartNotification) {
                    _autoScrollTimer?.cancel();
                  } else if (notification is ScrollEndNotification) {
                    _resetAutoScrollTimer();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPage(content: contents[index]);
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      contents.length,
                      (index) => _buildDot(index, context),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      _autoScrollTimer?.cancel();
                      if (_currentPage == contents.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                        );
                        _resetAutoScrollTimer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == contents.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
