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

  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final situations = AppConstants.situations;
    final icons = [
      Icons.security, // robbery
      Icons.health_and_safety, // health
      Icons.fire_truck, // fire
      Icons.flood, // flood
      Icons.car_crash, // accident
      Icons.back_hand, // violence
    ];
    final colors = [
      const Color(0xFFFF6B6B), // softer red
      const Color(0xFF4ECDC4), // mint
      const Color(0xFFFFB347), // orange
      const Color(0xFF5D9BEC), // blue
      const Color(0xFF9B6B9B), // purple
      const Color(0xFFCC8E65), // brown
    ];

    return Scaffold(
      extendBody: true, // for transparent bottom nav
      appBar: TopNavBar(
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'What’s the emergency?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the situation to alert your trusted contacts',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        SizeConfig.orientation == Orientation.portrait ? 2 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: situations.length,
                  itemBuilder: (context, index) {
                    return EmergencyTile(
                      title: situations[index],
                      icon: icons[index],
                      color: colors[index],
                      onTap: () {
                        // Navigate to alert confirmation with selected situation
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
            ],
          ),
        ),
      ),
    );
  }
}
