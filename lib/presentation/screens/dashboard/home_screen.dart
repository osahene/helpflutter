import 'package:flutter/material.dart';
import 'package:helpflutter/presentation/screens/alert/alert_confirmation_screen.dart';
import 'package:helpflutter/presentation/widgets/emergency_tile.dart';
import 'package:helpflutter/presentation/widgets/top_nav_bar.dart';
import 'package:helpflutter/presentation/screens/dashboard/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final Function(int) onTabTapped;

  const HomeScreen({super.key, this.onMenuTap, required this.onTabTapped});

  static const _situations = [
    'Fire',
    'Medical',
    'Security',
    'Legal',
    'Flood',
    'General SOS',
  ];

  static const _icons = [
    Icons.local_fire_department_rounded,
    Icons.health_and_safety_rounded,
    Icons.security_rounded,
    Icons.gavel_rounded,
    Icons.water_damage_rounded,
    Icons.sos_rounded,
  ];

  static const _colors = [
    Color(0xFFE8500A),
    Color(0xFF1A9E5C),
    Color(0xFFCC2222),
    Color(0xFF8B5C00),
    Color(0xFF0A72C4),
    Color(0xFF7B22CE),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: TopNavBar(
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        onMenuTap: onMenuTap,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isTablet = width >= 600;
          final bool isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          // Responsive column count
          final int crossAxisCount = isTablet
              ? (isLandscape ? 4 : 3)
              : (isLandscape ? 3 : 2);

          // Responsive sizing
          final double headerPadH = isTablet ? 32.0 : 20.0;
          final double gridPad = isTablet ? 24.0 : 16.0;
          final double gridSpacing = isTablet ? 20.0 : 14.0;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Header Banner ─────────────────────────────────────────
              SliverToBoxAdapter(child: _HeaderBanner(paddingH: headerPadH)),

              // ─── "Select Emergency" label ───────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(headerPadH, 24, headerPadH, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SELECT EMERGENCY TYPE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Emergency Grid ─────────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gridPad, 0, gridPad, gridPad + 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return EmergencyTile(
                      title: _situations[index],
                      icon: _icons[index],
                      color: _colors[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, __) =>
                                AlertConfirmationScreen(
                                  emergencyType: _situations[index],
                                  icon: _icons[index],
                                  color: _colors[index],
                                ),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.06),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: _situations.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                    childAspectRatio: isTablet ? 0.9 : 0.88,
                  ),
                ),
              ),

              // ─── Footer disclaimer ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(headerPadH, 0, headerPadH, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: Colors.white24,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Alerts include your live location.',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final double paddingH;
  const _HeaderBanner({required this.paddingH});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3D0000), Color(0xFF6B0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What's your emergency?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a situation below to instantly\nalert your emergency contacts.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
