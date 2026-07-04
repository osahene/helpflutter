import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/logic/alert/alert_bloc.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';

class AlertConfirmationScreen extends StatefulWidget {
  final String emergencyType;
  final IconData icon;
  final Color color;

  const AlertConfirmationScreen({
    super.key,
    required this.emergencyType,
    required this.icon,
    required this.color,
  });

  @override
  State<AlertConfirmationScreen> createState() =>
      _AlertConfirmationScreenState();
}

class _AlertConfirmationScreenState extends State<AlertConfirmationScreen>
    with SingleTickerProviderStateMixin {
  bool _isSending = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load contacts when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsBloc>().add(LoadContacts());
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Returns contacts that are [approved] AND whose situation map
  /// contains a key matching [widget.emergencyType] (case-insensitive)
  /// with a truthy value (true / 1 / "true").

  List<Contact> _filterEligibleContacts(List<Contact> contacts) {
    final String targetKey = widget.emergencyType.toLowerCase().trim();

    return contacts.where((contact) {
      if (contact.status != ContactStatus.approved) return false;

      // FIX: Safely parse a dynamic iterable instead of strict typecasting
      final dynamic rawSituation = contact.situation;
      if (rawSituation == null || rawSituation is! Iterable) return false;

      final List<String> situation = rawSituation
          .map((e) => e.toString())
          .toList();
      if (situation.isEmpty) return false;

      for (final entry in situation.asMap().entries) {
        final String currentKey = entry.value.toLowerCase();
        final bool keyMatches =
            currentKey == targetKey ||
            currentKey == targetKey.replaceAll(' ', '_') ||
            currentKey == targetKey.replaceAll(' ', '');

        if (keyMatches) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.color.withValues(alpha: 0.12);
    final Color accentColor = widget.color;

    return BlocListener<AlertBloc, AlertState>(
      listener: (context, state) {
        if (state is AlertSuccess) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Alert Sent',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ],
              ),
              content: const Text(
                'Your emergency alert has been sent to your contacts.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is AlertFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          setState(() => _isSending = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: Stack(
          children: [
            // ── Top bleed accent panel ─────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.48,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── Custom AppBar ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _isSending
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Confirm Alert',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ── Scrollable body ────────────────────────────────────
                  Expanded(
                    child: BlocBuilder<ContactsBloc, ContactsState>(
                      builder: (context, contactsState) {
                        // Derive eligible contacts from whatever state we're in
                        List<Contact> eligibleContacts = [];
                        bool isLoadingContacts = false;

                        if (contactsState is ContactsLoading) {
                          isLoadingContacts = true;
                        } else if (contactsState is ContactsLoaded) {
                          eligibleContacts = _filterEligibleContacts(
                            contactsState.contacts,
                          );
                        }

                        final bool hasEligibleContacts =
                            eligibleContacts.isNotEmpty;
                        final bool canSend =
                            !_isSending &&
                            !isLoadingContacts &&
                            hasEligibleContacts;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 24),

                                // ── Pulse icon ───────────────────────────
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 148,
                                    height: 148,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 36,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 104,
                                        height: 104,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: accentColor.withValues(
                                            alpha: 0.18,
                                          ),
                                        ),
                                        child: Icon(
                                          widget.icon,
                                          size: 54,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                Text(
                                  widget.emergencyType,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Your live location will be shared',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'Your emergency contacts will be\nimmediately notified.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    height: 1.55,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ── Contacts section ─────────────────────
                                if (isLoadingContacts)
                                  _ContactsSectionLoading(
                                    accentColor: accentColor,
                                  )
                                else if (!hasEligibleContacts)
                                  _NoContactsWarning(
                                    emergencyType: widget.emergencyType,
                                  )
                                else
                                  _EligibleContactsList(
                                    contacts: eligibleContacts,
                                    accentColor: accentColor,
                                  ),

                                const SizedBox(height: 32),

                                // ── Send button ──────────────────────────
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: canSend
                                        ? () {
                                            setState(() => _isSending = true);
                                            context.read<AlertBloc>().add(
                                              SendAlert(
                                                situation: widget.emergencyType,
                                                includeLocation: true,
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: accentColor
                                          .withValues(alpha: 0.35),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: _isSending
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.send_rounded,
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Send Alert Now',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ── Cancel button ────────────────────────
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _isSending
                                        ? null
                                        : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black54,
                                      side: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading shimmer placeholder ─────────────────────────────────────────────

class _ContactsSectionLoading extends StatelessWidget {
  final Color accentColor;
  const _ContactsSectionLoading({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Checking your contacts…',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── No eligible contacts warning ────────────────────────────────────────────

class _NoContactsWarning extends StatelessWidget {
  final String emergencyType;
  const _NoContactsWarning({required this.emergencyType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.person_off_outlined,
            color: Color(0xFFD32F2F),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB71C1C),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'You don\'t have any contact for the '),
                  TextSpan(
                    text: '"$emergencyType"',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        ' alert. Please ensure you have at least one approved contact with this situation enabled in your contacts list.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Eligible contacts list ───────────────────────────────────────────────────

class _EligibleContactsList extends StatelessWidget {
  final List<Contact> contacts;
  final Color accentColor;

  const _EligibleContactsList({
    required this.contacts,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section heading ───────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.group_rounded, size: 18, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The following ${contacts.length == 1 ? 'personality' : 'personalities'} '
                'would be alerted of this situation',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Contact cards ─────────────────────────────────────────────
        ...contacts.map(
          (contact) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ContactCard(contact: contact, accentColor: accentColor),
          ),
        ),
      ],
    );
  }
}

// ─── Single contact card ──────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final Color accentColor;

  const _ContactCard({required this.contact, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final String initials = _initials(contact.firstName, contact.lastName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name + relation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${contact.firstName} ${contact.lastName}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.relation,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Approved badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 12,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final String f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final String l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}
