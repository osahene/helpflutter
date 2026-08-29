import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/logic/profile/profile_bloc.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final int unreadCount;

  const TopNavBar({
    super.key,
    this.onProfileTap,
    this.onMenuTap,
    this.onNotificationsTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 102, 114, 153), Color(0xFF1A3A8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
        child: GestureDetector(
          onTap: onProfileTap,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String displayInitials = '--';
              ImageProvider? imageProvider;

              // Extract user info only if state is successfully loaded
              if (state is ProfileLoaded) {
                final user = state.user;

                // Dynamically split full name into components for initials
                final nameParts = user.fullName.trim().split(' ');
                final String first = nameParts.isNotEmpty
                    ? nameParts.first
                    : '';
                final String last = nameParts.length > 1 ? nameParts.last : '';
                displayInitials = _initials(first, last);

                if (user.profileImageUrl != null &&
                    user.profileImageUrl!.isNotEmpty) {
                  imageProvider = NetworkImage(user.profileImageUrl!);
                }
              }

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          displayInitials,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors
                                .white, // High contrast text over gradient
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LiveDot(),
          const SizedBox(width: 8),
          Image.asset(
            AppConstants.logoPath,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onNotificationsTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1A3A8F), width: 1.5),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String first, String last) {
    final String f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final String l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ── Live Dot Widget (Keeping your existing implementation intact) ───────────
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade400,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.8),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
