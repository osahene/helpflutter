import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/core/utils/size_config.dart';
import 'package:helpflutter/core/widgets/emergency_tile.dart';
import 'package:helpflutter/core/widgets/top_nav_bar.dart';
import 'package:helpflutter/presentation/screens/alert_confirmation/alert_confirmation_screen.dart';
import 'package:helpflutter/presentation/screens/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final VoidCallback? onMenuTap; //

  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final situations = AppConstants.situations;
    final icons = [
      Icons.security,
      Icons.health_and_safety,
      Icons.fire_truck,
      Icons.flood,
      Icons.car_crash,
      Icons.back_hand,
    ];
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFB347),
      const Color(0xFF5D9BEC),
      const Color(0xFF9B6B9B),
      const Color(0xFFCC8E65),
    ];

    return Column(
      children: [
        TopNavBar(
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          onMenuTap: onMenuTap, // pass the drawer opener
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    'What’s the emergency?',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select the situation to alert your trusted contacts',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom:
                            80, // extra padding to prevent content behind bottom nav
                      ), // avoid content behind bottom nav
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              SizeConfig.orientation == Orientation.portrait
                              ? 2
                              : 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: situations.length,
                        itemBuilder: (context, index) {
                          return EmergencyTile(
                            title: situations[index],
                            icon: icons[index],
                            color: colors[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlertConfirmationScreen(
                                    situation: situations[index],
                                    situationIcon: icons[index],
                                    situationColor: colors[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
