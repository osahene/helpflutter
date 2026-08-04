import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';

/// What the banner's button should do when tapped.
enum BannerAction { none, retry, addContact, manageContacts }

/// Which situation the user is in. Exposed so it can be asserted in tests.
enum BannerKey { loading, error, empty, pending, declined, growing, complete }

/// The fully-resolved banner content. Nothing in here touches Flutter, so
/// `deriveBannerState` can be unit-tested without pumping a widget.
class BannerContent {
  final BannerKey key;
  final Color accent;
  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final BannerAction action;
  final bool showMeter;
  final int approved;
  final int pending;
  final int maxContacts;
  final bool spin;

  const BannerContent({
    required this.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.action = BannerAction.none,
    this.showMeter = false,
    this.approved = 0,
    this.pending = 0,
    this.maxContacts = 5,
    this.spin = false,
  });
}

// Accents borrowed from the emergency tiles so the banner stays in family.
const _kEmpty = Color(0xFFCC2222);
const _kPending = Color(0xFFE8500A);
const _kDeclined = Color(0xFF8B5C00);
const _kGrowing = Color(0xFF0A72C4);
const _kComplete = Color(0xFF1A9E5C);

/// Pure function: bloc state in, banner content out.
BannerContent deriveBannerState({
  required ContactsState state,
  required int maxContacts,
}) {
  if (state is ContactsError) {
    return const BannerContent(
      key: BannerKey.error,
      accent: _kPending,
      icon: Icons.cloud_off_rounded,
      title: "We couldn't load your contacts",
      body:
          'Check your connection and try again. You can still send an alert in the meantime.',
      ctaLabel: 'Try again',
      action: BannerAction.retry,
    );
  }

  if (state is! ContactsLoaded) {
    // ContactsInitial and ContactsLoading both land here.
    return const BannerContent(
      key: BannerKey.loading,
      accent: _kGrowing,
      icon: Icons.sync_rounded,
      title: 'Checking your contacts',
      body: 'One moment while we load the people on your list.',
      spin: true,
    );
  }

  final contacts = state.contacts;

  if (contacts.isEmpty) {
    return const BannerContent(
      key: BannerKey.empty,
      accent: _kEmpty,
      icon: Icons.group_add_rounded,
      title: 'No trusted contacts yet',
      body:
          "An alert only helps if someone receives it. Add the people you'd want beside you in an emergency.",
      ctaLabel: 'Add your first contact',
      action: BannerAction.addContact,
    );
  }

  final approved = contacts
      .where((c) => c.status == ContactStatus.approved)
      .length;
  final pending = contacts
      .where((c) => c.status == ContactStatus.pending)
      .length;
  final declined = contacts
      .where((c) => c.status == ContactStatus.rejected)
      .length;

  if (pending > 0) {
    return BannerContent(
      key: BannerKey.pending,
      accent: _kPending,
      icon: Icons.hourglass_top_rounded,
      title: pending == 1
          ? "1 contact hasn't accepted yet"
          : "$pending contacts haven't accepted yet",
      body:
          'They will not receive your alerts until they accept. Send a reminder, '
          'or remove the request and pick someone else.',
      ctaLabel: 'Review contacts',
      action: BannerAction.manageContacts,
      showMeter: true,
      approved: approved,
      pending: pending,
      maxContacts: maxContacts,
    );
  }

  if (declined > 0 && approved < maxContacts) {
    return BannerContent(
      key: BannerKey.declined,
      accent: _kDeclined,
      icon: Icons.person_off_rounded,
      title: declined == 1
          ? '1 person declined your request'
          : '$declined people declined your request',
      body:
          "Replace them so there's always someone ready to answer. You still have room.",
      ctaLabel: 'Add someone else',
      action: BannerAction.addContact,
      showMeter: true,
      approved: approved,
      pending: pending,
      maxContacts: maxContacts,
    );
  }

  if (approved < maxContacts) {
    final room = maxContacts - approved;
    return BannerContent(
      key: BannerKey.growing,
      accent: _kGrowing,
      icon: Icons.person_add_alt_1_rounded,
      title: '$approved of $maxContacts contacts ready',
      body: room == 1
          ? 'Room for one more. The more people on your list, the better the odds '
                'someone is close by when it counts.'
          : 'Room for $room more. The more people on your list, the better the odds '
                'someone is close by when it counts.',
      ctaLabel: 'Add another contact',
      action: BannerAction.addContact,
      showMeter: true,
      approved: approved,
      pending: pending,
      maxContacts: maxContacts,
    );
  }

  return BannerContent(
    key: BannerKey.complete,
    accent: _kComplete,
    icon: Icons.verified_user_rounded,
    title: 'Your circle is complete',
    body:
        'All $approved contacts have accepted. Tap any situation below and every '
        'one of them will know where you are.',
    ctaLabel: 'Manage contacts',
    action: BannerAction.manageContacts,
    showMeter: true,
    approved: approved,
    pending: pending,
    maxContacts: maxContacts,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner
// ─────────────────────────────────────────────────────────────────────────────

class StatusBanner extends StatelessWidget {
  final double paddingH;

  /// Tab index to switch to when the CTA is tapped.
  final ValueChanged<int> onNavigate;

  /// Dashboard tab indices. Defaults match DashboardScreen's `_screens`.
  final int registerTabIndex;
  final int contactsTabIndex;

  /// Mirrors the backend subscription limits (free 5 / pro 10 / advance 15).
  final int maxContacts;

  const StatusBanner({
    super.key,
    required this.paddingH,
    required this.onNavigate,
    this.registerTabIndex = 1,
    this.contactsTabIndex = 2,
    this.maxContacts = 5,
  });

  void _handleTap(BuildContext context, BannerAction action) {
    switch (action) {
      case BannerAction.retry:
        context.read<ContactsBloc>().add(LoadContacts());
        break;
      case BannerAction.addContact:
        onNavigate(registerTabIndex);
        break;
      case BannerAction.manageContacts:
        onNavigate(contactsTabIndex);
        break;
      case BannerAction.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) {
        final content = deriveBannerState(
          state: state,
          maxContacts: maxContacts,
        );

        return Container(
          margin: EdgeInsets.fromLTRB(paddingH, 10, paddingH, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(content.key),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content.body,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _BannerIcon(
                      icon: content.icon,
                      accent: content.accent,
                      spin: content.spin,
                    ),
                  ],
                ),
                if (content.showMeter) ...[
                  const SizedBox(height: 16),
                  _ReadinessMeter(
                    approved: content.approved,
                    pending: content.pending,
                    maxContacts: content.maxContacts,
                    accent: content.accent,
                  ),
                ],
                if (content.ctaLabel != null) ...[
                  const SizedBox(height: 16),
                  _BannerCta(
                    label: content.ctaLabel!,
                    accent: content.accent,
                    onTap: () => _handleTap(context, content.action),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon badge (spins while loading)
// ─────────────────────────────────────────────────────────────────────────────

class _BannerIcon extends StatefulWidget {
  final IconData icon;
  final Color accent;
  final bool spin;

  const _BannerIcon({
    required this.icon,
    required this.accent,
    required this.spin,
  });

  @override
  State<_BannerIcon> createState() => _BannerIconState();
}

class _BannerIconState extends State<_BannerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spin) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _BannerIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spin && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.spin && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the platform's reduced-motion setting.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final badge = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Icon(widget.icon, color: widget.accent, size: 26),
    );

    if (!widget.spin || reduceMotion) return badge;

    return RotationTransition(turns: _controller, child: badge);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Readiness meter — one segment per available contact slot
// ─────────────────────────────────────────────────────────────────────────────

class _ReadinessMeter extends StatelessWidget {
  final int approved;
  final int pending;
  final int maxContacts;
  final Color accent;

  const _ReadinessMeter({
    required this.approved,
    required this.pending,
    required this.maxContacts,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final slots = maxContacts > approved + pending
        ? maxContacts
        : approved + pending;

    return Semantics(
      label:
          '$approved of $maxContacts contacts accepted, '
          '$pending awaiting a reply',
      child: Row(
        children: List.generate(slots, (i) {
          Color color;
          if (i < approved) {
            color = accent;
          } else if (i < approved + pending) {
            color = accent.withValues(alpha: 0.38);
          } else {
            color = Colors.white.withValues(alpha: 0.12);
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == slots - 1 ? 0 : 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA pill
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCta extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _BannerCta({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
