import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/core/utils/size_config.dart';
// import 'package:helpflutter/core/widgets/bottom_nav_bar.dart';
import 'package:helpflutter/core/widgets/emergency_tile.dart';
import 'package:helpflutter/core/widgets/top_nav_bar.dart';
import 'package:helpflutter/presentation/screens/profile/profile_screen.dart';
// import 'package:helpflutter/presentation/routes/app_router.dart';

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
      Icons.local_fire_department, // fire
      Icons.water_damage, // flood
      Icons.car_crash, // accident
      Icons.gavel, // violence
    ];
    final colors = [
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.brown,
    ];

    return Scaffold(
      appBar: TopNavBar(
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                // TODO: Trigger alert flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${situations[index]} tapped')),
                );
              },
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: currentIndex,
      //   onTap: onTabTapped,
      // ),
    );
  }
}
