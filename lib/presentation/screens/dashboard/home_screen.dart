import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/utils/size_config.dart';
import 'package:helpflutter/presentation/screens/alert/alert_confirmation_screen.dart';
import 'package:helpflutter/presentation/widgets/emergency_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final situations = AppConstants.situations;
    final icons = [
      Icons.local_fire_department,
      Icons.health_and_safety,
      Icons.security,
      Icons.gavel,
      Icons.water_damage,
      Icons.emergency,
    ];
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.brown,
      Colors.blue,
      Colors.purple,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: SizeConfig.orientation == Orientation.portrait
                ? 2
                : 3,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlertConfirmationScreen(
                      emergencyType: situations[index],
                      icon: icons[index],
                      color: colors[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
