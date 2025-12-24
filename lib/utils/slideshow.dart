import 'dart:async';
import 'package:flutter/material.dart';

class Slide {
  final String imagePath;
  final String title;

  const Slide({required this.imagePath, required this.title});
}

final List<Slide> slides = [
  const Slide(
    imagePath: 'assets/slides/cyber-monday-celebration.jpg',
    title: 'Cyber Monday Sale',
  ),
  const Slide(
    imagePath: 'assets/slides/black_friday_facebook_banner_22.png',
    title: 'Black Friday Discount',
  ),
  const Slide(
    imagePath: 'assets/slides/WEB_BANNER_41.png',
    title: 'Deep Tech Deals',
  ),
  const Slide(
    imagePath: 'assets/slides/Electronics_store.png',
    title: 'Electronics Store',
  ),
  const Slide(
    imagePath: 'assets/slides/133771699_10279844.png',
    title: 'Dive into Tech',
  ),
];

class SlideshowWidget extends StatefulWidget {
  final double height;
  final Duration autoScrollDuration;

  const SlideshowWidget({
    super.key,
    this.height = 200.0,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<SlideshowWidget> createState() => _SlideshowWidgetState();
}

class _SlideshowWidgetState extends State<SlideshowWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (Timer timer) {
      if (!_pageController.hasClients) return;

      int nextPageIndex = (_currentPage + 1) % slides.length;

      _pageController.animateToPage(
        nextPageIndex,
        duration: const Duration(milliseconds: 600),
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

  void _goToSlide(int index) {
    _resetAutoScrollTimer();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextSlide() {
    _resetAutoScrollTimer();
    int nextIndex = (_currentPage + 1) % slides.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevSlide() {
    _resetAutoScrollTimer();
    int prevIndex = (_currentPage - 1 + slides.length) % slides.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
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
              itemCount: slides.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _SlideContent(slide: slides[index]);
              },
            ),
          ),

          _buildNavigationButton(
            context,
            icon: Icons.arrow_back_ios,
            alignment: Alignment.centerLeft,
            onPressed: _prevSlide,
          ),
          _buildNavigationButton(
            context,
            icon: Icons.arrow_forward_ios,
            alignment: Alignment.centerRight,
            onPressed: _nextSlide,
          ),

          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => _buildDot(index, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required Alignment alignment,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, BuildContext context) {
    bool isActive = index == _currentPage;
    return GestureDetector(
      onTap: () => _goToSlide(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 8,
        width: isActive ? 20 : 8,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.white70,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final Slide slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          slide.imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Text(
                slide.title,
                style: const TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
