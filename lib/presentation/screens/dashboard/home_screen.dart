// lib/presentation/screens/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/repositories/titbit_repository.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/presentation/screens/alert/alert_confirmation_screen.dart';
import 'package:helpflutter/presentation/screens/extra/titbits_screen.dart';
import 'package:helpflutter/presentation/widgets/emergency_tile.dart';
import 'package:helpflutter/presentation/widgets/status_banner.dart';
import 'package:helpflutter/presentation/widgets/top_nav_bar.dart';
import 'package:helpflutter/presentation/screens/dashboard/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final Function(int) onTabTapped;

  const HomeScreen({super.key, this.onMenuTap, required this.onTabTapped});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unreadCount = 0;

  static const _situations = [
    'Robbery Attack',
    'Health Crisis',
    'Fire Outbreak',
    'Flood Alert',
    'Accident Alert',
    'Call Emergency',
  ];

  static const _icons = [
    Icons.security_outlined,
    Icons.health_and_safety_rounded,
    Icons.fire_truck_rounded,
    Icons.flood_rounded,
    Icons.car_crash_rounded,
    Icons.sos_rounded,
  ];

  static const _colors = [
    Color(0xFFE8500A),
    Color(0xFF1A9E5C),
    Color(0xFFCC2222),
    Color(0xFF0A72C4),
    Color(0xFF8B5C00),
    Color(0xFF7B22CE),
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await context.read<TitbitRepository>().getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Non-fatal: badge just stays at its last known value.
    }
  }

  Future<void> _openTitbits() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TitbitsScreen()),
    );
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 244),
      appBar: TopNavBar(
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        onMenuTap: widget.onMenuTap,
        onNotificationsTap: _openTitbits,
        unreadCount: _unreadCount,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isTablet = width >= 600;
          final bool isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          final int crossAxisCount = isTablet
              ? (isLandscape ? 4 : 3)
              : (isLandscape ? 3 : 2);

          final double headerPadH = isTablet ? 32.0 : 20.0;
          final double gridPad = isTablet ? 24.0 : 16.0;
          final double gridSpacing = isTablet ? 20.0 : 14.0;

          return RefreshIndicator(
            color: const Color(0xFF6B0F0F),
            onRefresh: () async {
              context.read<ContactsBloc>().add(LoadContacts());
              // Give the bloc a beat to emit before dismissing the spinner.
              await context.read<ContactsBloc>().stream.firstWhere(
                (s) => s is! ContactsLoading,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ─── Status banner ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: StatusBanner(
                    paddingH: headerPadH,
                    onNavigate: widget.onTabTapped,
                    // maxContacts: read from the signed-in user's plan when
                    // AuthBloc exposes it — 5 (free) is the backend default.
                    maxContacts: 5,
                  ),
                ),

                // ─── Emergency grid ────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    gridPad,
                    4,
                    gridPad,
                    gridPad + 20,
                  ),
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
                              pageBuilder: (context, animation, _) =>
                                  AlertConfirmationScreen(
                                    emergencyType: _situations[index],
                                    icon: _icons[index],
                                    color: _colors[index],
                                  ),
                              transitionsBuilder: (_, anim, _, child) {
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

                // ─── Footer disclaimer ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(headerPadH, 0, headerPadH, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // FIX: this row was Colors.white24 on a near-white
                        // background — effectively invisible on device.
                        Icon(
                          Icons.my_location_rounded,
                          size: 15,
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Every alert includes your live location.',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
