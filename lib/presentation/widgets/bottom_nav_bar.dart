import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.person_add_alt_1_rounded, label: 'Register'),
    _NavItem(icon: Icons.contacts_rounded, label: 'Contacts'),
    _NavItem(icon: Icons.phone_in_talk, label: 'Emergency'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final bool isSelected = currentIndex == index;
              return _NavTile(
                item: _items[index],
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Data class ──────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─── Individual animated tile ─────────────────────────────────────────────────

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Emergency tab gets a red pill treatment; others use a neutral glow
    const Color activeColor = Color.fromARGB(255, 250, 250, 250);
    const Color activeBg = Color.fromARGB(
      255,
      47,
      79,
      118,
    ); // Neutral dark gray
    const Color inactiveTextColor = Color.fromARGB(255, 177, 175, 175);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: widget.isSelected
              ? BoxDecoration(
                  color: activeBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : null,
          child: widget.isSelected
              // ── Active: icon + label in a pill ──────────────────────────
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.item.icon, color: activeColor, size: 22),
                    const SizedBox(width: 7),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                )
              // ── Inactive: icon only with dot indicator if near-active ───
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.item.icon, color: inactiveTextColor, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.label,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 177, 175, 175),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
