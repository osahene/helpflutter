import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/app_constants.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;

  const TopNavBar({
    super.key,
    this.profileImageUrl,
    this.onProfileTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: onProfileTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            radius: 18,
          ),
        ),
      ),
      title: Image.asset(
        AppConstants.logoPath,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          AppConstants.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
        ),
      ],
      backgroundColor: const Color.fromARGB(166, 188, 33, 33),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
