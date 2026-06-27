import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Onboarding page data ──────────────────────────────────────────────────────
class _OnboardingData {
  final String title;
  final String description;
  final String badge;
  final IconData icon;
  final List<Color> gradient;
  final List<Color> iconGradient;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.badge,
    required this.icon,
    required this.gradient,
    required this.iconGradient,
  });
}

const _pages = [
  _OnboardingData(
    badge: 'ONE TAP ALERT',
    title: 'Emergency at\nyour fingertips',
    description:
        'Tap once to instantly alert your trusted\ncontacts about any emergency.',
    icon: Icons.touch_app_rounded,
    gradient: [Color(0xFF6B0F0F), Color(0xFFCC2222)],
    iconGradient: [Color(0xFFFF6B6B), Color(0xFFFF3B3B)],
  ),
  _OnboardingData(
    badge: 'REAL-TIME',
    title: 'Fast &\nReliable',
    description:
        'Get help quickly with live location sharing\nso responders find you instantly.',
    icon: Icons.location_on_rounded,
    gradient: [Color(0xFF0D1B4B), Color(0xFF2C5FD4)],
    iconGradient: [Color(0xFF6B9FFF), Color(0xFF2C5FD4)],
  ),
  _OnboardingData(
    badge: 'YOUR NETWORK',
    title: 'Your personal\nsafety network',
    description:
        'Add trusted contacts for every situation\nand notify them all at once.',
    icon: Icons.people_rounded,
    gradient: [Color(0xFF1A3A1A), Color(0xFF1A9E5C)],
    iconGradient: [Color(0xFF5BE8A0), Color(0xFF1A9E5C)],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _iconBounceCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _iconBounceAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _iconBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _iconBounceAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _iconBounceCtrl, curve: Curves.elasticOut),
    );

    _playEntrance();
  }

  void _playEntrance() {
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
    _iconBounceCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _iconBounceCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _playEntrance();
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _skip();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _skip() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.hasSeenOnboarding, true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background circles ─────────────────────────
            Positioned(
              top: -size.height * 0.08,
              right: -size.width * 0.2,
              child: _Circle(size: size.width * 0.7, opacity: 0.07),
            ),
            Positioned(
              top: size.height * 0.12,
              left: -size.width * 0.25,
              child: _Circle(size: size.width * 0.55, opacity: 0.05),
            ),
            Positioned(
              bottom: size.height * 0.28,
              right: -size.width * 0.15,
              child: _Circle(size: size.width * 0.4, opacity: 0.06),
            ),

            // ── Safe area content ─────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Skip button row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip
                        if (_currentPage < _pages.length - 1)
                          GestureDetector(
                            onTap: _skip,
                            child: Container(
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 64),
                      ],
                    ),
                  ),

                  // ── PageView (icon + text content) ─────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final p = _pages[index];
                        return _PageContent(
                          data: p,
                          fadeAnim: _fadeAnim,
                          slideAnim: _slideAnim,
                          iconBounceAnim: _iconBounceAnim,
                        );
                      },
                    ),
                  ),

                  // ── Bottom controls ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                    child: Column(
                      children: [
                        // Dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => _Dot(
                              isActive: index == _currentPage,
                              color: page.iconGradient[0],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Main CTA button
                        _CTAButton(
                          label: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          isLast: _currentPage == _pages.length - 1,
                          iconGradient: page.iconGradient,
                          onTap: _next,
                        ),

                        const SizedBox(height: 16),
                      ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Content
// ─────────────────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> iconBounceAnim;

  const _PageContent({
    required this.data,
    required this.fadeAnim,
    required this.slideAnim,
    required this.iconBounceAnim,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon Display ───────────────────────────────────────
                ScaleTransition(
                  scale: iconBounceAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: size.width * 0.52,
                        height: size.width * 0.52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Mid ring
                      Container(
                        width: size.width * 0.40,
                        height: size.width * 0.40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      // Icon container
                      Container(
                        width: size.width * 0.28,
                        height: size.width * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: data.iconGradient[0].withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          data.icon,
                          size: size.width * 0.12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.055),

                // ── Badge label ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.025),

                // ── Title ──────────────────────────────────────────────
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.082,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),

                SizedBox(height: size.height * 0.022),

                // ── Description ────────────────────────────────────────
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15.5,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Dot Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final bool isActive;
  final Color color;
  const _Dot({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.25),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Button
// ─────────────────────────────────────────────────────────────────────────────

class _CTAButton extends StatefulWidget {
  final String label;
  final bool isLast;
  final List<Color> iconGradient;
  final VoidCallback onTap;

  const _CTAButton({
    required this.label,
    required this.isLast,
    required this.iconGradient,
    required this.onTap,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.iconGradient[1],
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isLast
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Circle
// ─────────────────────────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}
