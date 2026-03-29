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
          'Share the most essential situation with your loved ones instantly.',
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundGlow(theme),
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedOnboardingIcon(
                                icon: item.icon,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 50),

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
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              Text(
                                item.message,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow(ThemeData theme) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -50,
          child: _glowCircle(
            theme.colorScheme.primary.withValues(alpha: 0.15),
            250,
          ),
        ),
        Positioned(
          bottom: -120,
          right: -50,
          child: _glowCircle(
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            300,
          ),
        ),
      ],
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
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
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

class AnimatedOnboardingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const AnimatedOnboardingIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  State<AnimatedOnboardingIcon> createState() => _AnimatedOnboardingIconState();
}

class _AnimatedOnboardingIconState extends State<AnimatedOnboardingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(widget.icon, size: 80, color: widget.color),
            ),
          ),
        );
      },
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
