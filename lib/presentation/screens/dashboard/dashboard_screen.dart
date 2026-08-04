import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/presentation/screens/dashboard/home_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/register_contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/emergency_contacts_screen.dart';
import 'package:helpflutter/presentation/screens/extra/legal_screen.dart';
import 'package:helpflutter/presentation/screens/extra/video_tutorials_screen.dart';
import 'package:helpflutter/presentation/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<int> _history = [0];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goToTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _history.remove(index);
      _history.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ContactsBloc(repository: context.read<ContactRepository>())
            ..add(LoadContacts()),
      child: PopScope(
        canPop: _history.length <= 1,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_history.length > 1) {
            setState(() {
              _history.removeLast();
              _currentIndex = _history.last;
            });
          } else {
            Navigator.of(context).maybePop();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildAppDrawer(context),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                onTabTapped: _goToTab,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const RegisterContactScreen(),
              const ContactsScreen(),
              const EmergencyContactsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _goToTab,
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Gradient header ─────────────────────────────
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A0A), Color(0xFF6B0F0F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -14,
                  left: -14,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                // Content
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live dot
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF3B3B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Help OO Help',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Emergency Response App',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Menu items ───────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Tutorial
                _DrawerItem(
                  icon: Icons.school_rounded,
                  label: 'Tutorial',
                  color: const Color(0xFF2C5FD4),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VideoTutorialsScreen(),
                      ),
                    );
                  },
                ),

                const _DrawerDivider(label: 'LEGAL'),

                // Terms of Service
                _DrawerItem(
                  icon: Icons.gavel_rounded,
                  label: 'Terms of Service',
                  color: const Color(0xFF2C5FD4),
                  onTap: () {
                    Navigator.pop(context);
                    openLegalPage(context, LegalPageType.termsOfService);
                  },
                ),

                // Privacy Policy
                _DrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  color: const Color(0xFF5B3FE8),
                  onTap: () {
                    Navigator.pop(context);
                    openLegalPage(context, LegalPageType.privacyPolicy);
                  },
                ),

                // Data Deletion
                _DrawerItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Data Deletion',
                  color: Colors.red.shade700,
                  onTap: () {
                    Navigator.pop(context);
                    openLegalPage(context, LegalPageType.dataDeletion);
                  },
                ),
              ],
            ),
          ),

          // ── Bottom divider + logout ──────────────────────
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          SafeArea(
            top: false,
            child: _DrawerItem(
              icon: Icons.logout_outlined,
              label: 'Logout',
              color: Colors.red.shade600,
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 10),
                        Text('Logged out successfully'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF1A9E5C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Drawer Item ──────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F1B3E),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade300,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

// ─── Section divider with label ───────────────────────────────────────────────

class _DrawerDivider extends StatelessWidget {
  final String label;
  const _DrawerDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF2C5FD4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2C5FD4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
