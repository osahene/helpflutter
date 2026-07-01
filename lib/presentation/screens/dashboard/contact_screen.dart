import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/dependents/dependent_bloc.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF2C5FD4);
const _kAccent = Color(0xFF5B3FE8);
const _kSurface = Color(0xFFF0F4FF);
const _kCard = Colors.white;
const _kBorder = Color(0xFFDDE3F5);
const _kText = Color(0xFF0F1B3E);
const _kMuted = Color(0xFF8B94B2);

// ─────────────────────────────────────────────────────────────────────────────
// Root Screen
// ─────────────────────────────────────────────────────────────────────────────

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ContactsBloc(repository: context.read<ContactRepository>())
                ..add(LoadContacts()),
        ),
        BlocProvider(
          create: (context) =>
              DependentsBloc(repository: context.read<DependentRepository>())
                ..add(LoadDependents()),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: _kSurface,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                centerTitle: true,
                backgroundColor: _kPrimary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.contacts_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Contacts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Manage your trusted people',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kPrimary, _kAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -28,
                        right: -28,
                        child: _Bubble(size: 140, opacity: 0.10),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 60,
                        child: _Bubble(size: 56, opacity: 0.12),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: _Bubble(size: 90, opacity: 0.08),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Container(
                    color: _kSurface,
                    child: const TabBar(
                      indicatorColor: _kPrimary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: _kPrimary,
                      unselectedLabelColor: _kMuted,
                      tabs: [
                        Tab(text: 'Emergency Contacts'),
                        Tab(text: 'Dependents'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: const TabBarView(
              children: [EmergencyContactsTab(), DependentsTab()],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative Bubble
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Emergency Contacts Tab
// ─────────────────────────────────────────────────────────────────────────────

class EmergencyContactsTab extends StatelessWidget {
  const EmergencyContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _kPrimary,
              strokeWidth: 2.5,
            ),
          );
        } else if (state is ContactsLoaded) {
          if (state.contacts.isEmpty) {
            return const _EmptyState(
              icon: Icons.contact_emergency_rounded,
              title: 'No Contacts in Records',
              subtitle:
                  'Add trusted contacts who will be\nalerted during emergencies.',
              color: _kPrimary,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: state.contacts.length,
            itemBuilder: (context, index) =>
                ContactCard(contact: state.contacts[index]),
          );
        } else if (state is ContactsError) {
          return _ErrorState(message: state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dependents Tab
// ─────────────────────────────────────────────────────────────────────────────

class DependentsTab extends StatelessWidget {
  const DependentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DependentsBloc, DependentsState>(
      builder: (context, state) {
        if (state is DependentsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _kAccent, strokeWidth: 2.5),
          );
        } else if (state is DependentsLoaded) {
          if (state.dependents.isEmpty) {
            return const _EmptyState(
              icon: Icons.family_restroom_rounded,
              title: 'No Dependents in Records',
              subtitle:
                  'Dependents are people who have\nadded you as their emergency contact.',
              color: _kAccent,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: state.dependents.length,
            itemBuilder: (context, index) =>
                DependentCard(dependent: state.dependents[index]),
          );
        } else if (state is DependentsError) {
          return _ErrorState(message: state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error States
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: color.withValues(alpha: 0.6)),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Card
// ─────────────────────────────────────────────────────────────────────────────

class ContactCard extends StatelessWidget {
  final Contact contact;
  const ContactCard({super.key, required this.contact});

  static _StatusStyle _statusStyle(ContactStatus status) {
    switch (status) {
      case ContactStatus.approved:
        return _StatusStyle(
          color: const Color(0xFF1A9E5C),
          bg: const Color(0xFFE8F8F0),
          icon: Icons.check_circle_rounded,
          label: 'Approved',
        );
      case ContactStatus.rejected:
        return _StatusStyle(
          color: Colors.red.shade500,
          bg: Colors.red.shade50,
          icon: Icons.cancel_rounded,
          label: 'Rejected',
        );
      case ContactStatus.pending:
        return _StatusStyle(
          color: const Color(0xFFE07A1A),
          bg: const Color(0xFFFFF3E0),
          icon: Icons.hourglass_top_rounded,
          label: 'Pending',
        );
    }
  }

  Color _avatarColor(String name) {
    final colors = [
      _kPrimary,
      _kAccent,
      const Color(0xFF1A9E5C),
      const Color(0xFFD4368A),
      const Color(0xFFE07A1A),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = '${contact.firstName} ${contact.lastName}';
    final style = _statusStyle(contact.status);
    final avatarColor = _avatarColor(displayName);

    return SwipeActionCell(
      key: ValueKey(contact.id),
      trailingActions: [
        SwipeAction(
          onTap: (CompletionHandler handler) async {
            final confirm = await _showDeleteContactDialog(
              context,
              displayName,
            );
            if (!context.mounted) return;
            if (confirm == true) {
              context.read<ContactsBloc>().add(DeleteContact(contact.id));
            }
            handler(false);
          },
          color: Colors.red.shade600,
          icon: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: avatarColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatarColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  displayName[0].toUpperCase(),
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: _kText,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    contact.relation,
                    style: const TextStyle(fontSize: 12.5, color: _kMuted),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, size: 11, color: style.color),
                        const SizedBox(width: 4),
                        Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: style.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder, width: 1),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.phone_rounded,
                      text: contact.phoneNumber,
                      color: const Color(0xFF1A9E5C),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.warning_amber_rounded,
                      text: 'Situations: ${contact.situation.join(', ')}',
                      color: const Color(0xFFE07A1A),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: _kBorder, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Edit Contact',
                            icon: Icons.edit_rounded,
                            color: const Color(0xFF1A9E5C),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _showEditContactModal(context, contact);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            label: 'Delete Contact',
                            icon: Icons.delete_rounded,
                            color: Colors.red.shade500,
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              final confirm = await _showDeleteContactDialog(
                                context,
                                displayName,
                              );
                              if (!context.mounted) return;
                              if (confirm == true) {
                                context.read<ContactsBloc>().add(
                                  DeleteContact(contact.id),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Contact Modal (Step 1 — form)
// ─────────────────────────────────────────────────────────────────────────────

void _showEditContactModal(BuildContext context, Contact contact) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ContactsBloc>(),
      child: _EditContactSheet(contact: contact),
    ),
  );
}

class _EditContactSheet extends StatefulWidget {
  final Contact contact;
  const _EditContactSheet({required this.contact});

  @override
  State<_EditContactSheet> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends State<_EditContactSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _countryCodeCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _relationCtrl;
  late List<String> _situations;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _firstNameCtrl = TextEditingController(text: c.firstName);
    _lastNameCtrl = TextEditingController(text: c.lastName);
    _countryCodeCtrl = TextEditingController(text: c.countryCode);
    _phoneCtrl = TextEditingController(text: c.phoneNumber);
    _relationCtrl = TextEditingController(text: c.relation);
    _situations = List<String>.from(c.situation);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _countryCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
    filled: true,
    fillColor: _kSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Handle bar ────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: _kPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Update Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _kMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: _kBorder, thickness: 1),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                mq.viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('First Name'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _firstNameCtrl,
                                decoration: _dec('First Name'),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Last Name'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _lastNameCtrl,
                                decoration: _dec('Last Name'),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone number row
                    _FieldLabel('Phone Number'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Country code
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            controller: _countryCodeCtrl,
                            decoration: _dec('Code', hint: '+233'),
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Req.' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            decoration: _dec(
                              'Phone Number',
                              hint: '244 123 456',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Relation
                    _FieldLabel('Relation'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _relationCtrl,
                      decoration: _dec('e.g. Brother, Friend, Colleague'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Situations
                    _FieldLabel('Emergency Situations'),
                    const SizedBox(height: 4),
                    Text(
                      'Select all situations this contact should be notified about.',
                      style: const TextStyle(fontSize: 12, color: _kMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.situations.map((s) {
                        final selected = _situations.contains(s);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              selected
                                  ? _situations.remove(s)
                                  : _situations.add(s);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _kPrimary.withValues(alpha: 0.1)
                                  : _kSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? _kPrimary : _kBorder,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected) ...[
                                  Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: _kPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected ? _kPrimary : _kMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_situations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Please select at least one situation.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // Divider
                    const Divider(color: _kBorder, thickness: 1),
                    const SizedBox(height: 20),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPrimary, _kAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_situations.isEmpty) return;
                              Navigator.pop(context); // close form sheet
                              _showUpdateConfirmDialog(
                                context,
                                contact: widget.contact,
                                firstName: _firstNameCtrl.text.trim(),
                                lastName: _lastNameCtrl.text.trim(),
                                countryCode: _countryCodeCtrl.text.trim(),
                                phoneNumber: _phoneCtrl.text.trim(),
                                relation: _relationCtrl.text.trim(),
                                situation: _situations,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Confirm Dialog (Step 2 — "Are you sure you want to update…?")
// ─────────────────────────────────────────────────────────────────────────────

void _showUpdateConfirmDialog(
  BuildContext context, {
  required Contact contact,
  required String firstName,
  required String lastName,
  required String countryCode,
  required String phoneNumber,
  required String relation,
  required List<String> situation,
}) {
  final displayName = '$firstName $lastName';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_rounded, color: _kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Confirm Update',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: _kMuted, fontSize: 14, height: 1.55),
            children: [
              const TextSpan(text: 'Are you sure you want to update '),
              TextSpan(
                text: displayName,
                style: const TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: "'s information?"),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: _kMuted)),
        ),
        // Yes — dispatch the update
        GestureDetector(
          onTap: () {
            Navigator.pop(ctx);
            context.read<ContactsBloc>().add(
              UpdateContactInfo(
                contact.id,
                firstName,
                lastName,
                countryCode,
                phoneNumber,
                relation,
                situation,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimary, _kAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Yes, Update',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete Contact Dialog  ("from your emergency contact list")
// ─────────────────────────────────────────────────────────────────────────────

Future<bool?> _showDeleteContactDialog(BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade500,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Delete Contact',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: _kMuted, fontSize: 14, height: 1.55),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: name,
                style: const TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' from your emergency contact list?'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: _kMuted)),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(ctx, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dependent Card  (unchanged functionality, kept for completeness)
// ─────────────────────────────────────────────────────────────────────────────

class DependentCard extends StatelessWidget {
  final Dependent dependent;
  const DependentCard({super.key, required this.dependent});

  static _StatusStyle _statusStyle(DependentStatus status) {
    switch (status) {
      case DependentStatus.approved:
        return _StatusStyle(
          color: const Color(0xFF1A9E5C),
          bg: const Color(0xFFE8F8F0),
          icon: Icons.check_circle_rounded,
          label: 'Approved',
        );
      case DependentStatus.rejected:
        return _StatusStyle(
          color: Colors.red.shade500,
          bg: Colors.red.shade50,
          icon: Icons.cancel_rounded,
          label: 'Rejected',
        );
      case DependentStatus.pending:
        return _StatusStyle(
          color: const Color(0xFFE07A1A),
          bg: const Color(0xFFFFF3E0),
          icon: Icons.hourglass_top_rounded,
          label: 'Pending',
        );
    }
  }

  Color _avatarColor(String name) {
    final colors = [
      _kAccent,
      _kPrimary,
      const Color(0xFFD4368A),
      const Color(0xFF1A9E5C),
      const Color(0xFFE07A1A),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(dependent.status);
    final avatarColor = _avatarColor(dependent.fullName);

    return SwipeActionCell(
      key: ValueKey(dependent.id),
      trailingActions: [
        SwipeAction(
          onTap: (CompletionHandler handler) async {
            final confirm = await _showDeleteGenericDialog(
              context,
              dependent.fullName,
              'Remove Dependent',
            );
            if (confirm == true) {
              // context.read<DependentsBloc>().add(DeleteDependent(dependent.id));
            }
            handler(false);
          },
          color: Colors.red.shade600,
          icon: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: avatarColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: avatarColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  dependent.fullName[0].toUpperCase(),
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              dependent.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: _kText,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, size: 11, color: style.color),
                    const SizedBox(width: 4),
                    Text(
                      style.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: style.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder, width: 1),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.family_restroom_rounded,
                      text: dependent.relation,
                      color: _kPrimary,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.phone_rounded,
                      text: dependent.phone,
                      color: const Color(0xFF1A9E5C),
                    ),
                    if (dependent.status == DependentStatus.pending) ...[
                      const SizedBox(height: 12),
                      Divider(color: _kBorder, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Accept',
                              icon: Icons.check_rounded,
                              color: const Color(0xFF1A9E5C),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.read<DependentsBloc>().add(
                                  UpdateDependentsStatus(
                                    dependentId: dependent.id,
                                    status: DependentStatus.approved,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              label: 'Reject',
                              icon: Icons.close_rounded,
                              color: Colors.red.shade500,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.read<DependentsBloc>().add(
                                  UpdateDependentsStatus(
                                    dependentId: dependent.id,
                                    status: DependentStatus.rejected,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic delete dialog (for dependents / swipe actions)
// ─────────────────────────────────────────────────────────────────────────────

Future<bool?> _showDeleteGenericDialog(
  BuildContext context,
  String name,
  String title,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade500,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to remove $name?',
        style: const TextStyle(color: _kMuted, fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: _kMuted)),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(ctx, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _kText,
      letterSpacing: 0.2,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: _kText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status style model
// ─────────────────────────────────────────────────────────────────────────────

class _StatusStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;
  const _StatusStyle({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });
}
