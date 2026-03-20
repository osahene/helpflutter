import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/presentation/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Welcome to',
      title2: AppConstants.appName,
      icon: Icons.emergency,
      message:
          'Use our system to swiftly get in touch with loved ones in serious moments of crisis with just 2 taps.',
    ),
    OnboardingItem(
      title: 'Swift Info Sharing',
      icon: Icons.share,
      message:
          'Share the most essential situation with your loved ones without doing much.',
    ),
    OnboardingItem(
      title: 'Safety Tips',
      icon: Icons.school,
      message: 'Learn how to handle emergencies with our video tutorials.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.background,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (item.title2 != null)
                          Text(
                            item.title!,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        Text(
                          item.title2 ?? item.title!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.message,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          Row(
            children: List.generate(_items.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _items.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class OnboardingItem {
  final String? title;
  final String? title2;
  final IconData icon;
  final String message;

  OnboardingItem({
    this.title,
    this.title2,
    required this.icon,
    required this.message,
  });
}
