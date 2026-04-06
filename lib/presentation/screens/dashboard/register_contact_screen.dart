import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';

// ── Brand palette ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF2C5FD4); // cobalt blue
const _kAccent = Color(0xFF5B3FE8); // electric indigo
const _kSurface = Color(0xFFF0F4FF); // ice-blue background
const _kCard = Colors.white;
const _kBorder = Color(0xFFDDE3F5);
const _kText = Color(0xFF0F1B3E);
const _kMuted = Color(0xFF8B94B2);

class RegisterContactScreen extends StatefulWidget {
  const RegisterContactScreen({super.key});

  @override
  State<RegisterContactScreen> createState() => _RegisterContactScreenState();
}

class _RegisterContactScreenState extends State<RegisterContactScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRelation;
  List<String> _selectedSituations = [];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _relations = ['Father', 'Mother', 'Son', 'Daughter', 'Relative'];

  static const _relationIcons = {
    'Father': Icons.man_rounded,
    'Mother': Icons.woman_rounded,
    'Son': Icons.male,
    'Daughter': Icons.female,
    'Relative': Icons.family_restroom_rounded,
  };

  static const _relationColors = {
    'Father': Color(0xFF2C5FD4),
    'Mother': Color(0xFFD4368A),
    'Son': Color(0xFF1AAE87),
    'Daughter': Color(0xFFE07A1A),
    'Relative': Color(0xFF5B3FE8),
  };

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedRelation != null) {
      HapticFeedback.mediumImpact();
      context.read<ContactsBloc>().add(
        AddContact(
          _firstNameController.text,
          _lastNameController.text,
          _phoneController.text,
          _emailController.text,
          _selectedRelation!,
          _selectedSituations.isEmpty
              ? null
              : {'situations': _selectedSituations},
        ),
      );
    } else if (_selectedRelation == null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Please select a relation'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return BlocListener<ContactsBloc, ContactsState>(
      listener: (context, state) {
        if (state is ContactsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text('Contact added successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF1A9E5C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        } else if (state is ContactsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _kSurface,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero SliverAppBar ──────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                backgroundColor: _kPrimary,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,

                // 1. Set centerTitle to true
                centerTitle: true,

                // 2. Replace the old title with your custom Row
                title: Row(
                  mainAxisSize: MainAxisSize.min, // Essential for centering
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
                        Icons.person_add_alt_1_rounded,
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
                          'Add Contact',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Who should we notify?',
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
                      // Blue → indigo gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kPrimary, _kAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Decorative bubbles
                      Positioned(
                        top: -28,
                        right: -28,
                        child: _Bubble(size: 140, opacity: 0.10),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 60,
                        child: _Bubble(size: 60, opacity: 0.12),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: _Bubble(size: 100, opacity: 0.08),
                      ),
                      // Bottom white curve
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
                      // 3. Removed the SafeArea/Header content from here!
                    ],
                  ),
                ),
              ),

              // ── Form Body ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Info
                        _SectionLabel(
                          icon: Icons.badge_rounded,
                          label: 'Personal Info',
                          color: _kPrimary,
                        ),
                        const SizedBox(height: 12),
                        _LightTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        _LightTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),

                        // Contact Details
                        _SectionLabel(
                          icon: Icons.contact_phone_rounded,
                          label: 'Contact Details',
                          color: _kAccent,
                        ),
                        const SizedBox(height: 12),
                        _LightTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        _LightTextField(
                          controller: _emailController,
                          label: 'Email (optional)',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.isEmpty
                              ? null
                              : (v.contains('@') ? null : 'Invalid email'),
                        ),
                        const SizedBox(height: 24),

                        // Relation
                        _SectionLabel(
                          icon: Icons.people_alt_rounded,
                          label: 'Relation',
                          color: const Color(0xFF1AAE87),
                        ),
                        const SizedBox(height: 12),
                        _RelationPicker(
                          relations: _relations,
                          icons: _relationIcons,
                          colors: _relationColors,
                          selected: _selectedRelation,
                          onSelect: (val) =>
                              setState(() => _selectedRelation = val),
                        ),
                        const SizedBox(height: 24),

                        // Notify For
                        _SectionLabel(
                          icon: Icons.warning_amber_rounded,
                          label: 'Notify For',
                          color: const Color(0xFFE07A1A),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select situations this contact should be alerted for.',
                          style: TextStyle(
                            color: _kMuted,
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SituationChips(
                          situations: AppConstants.situations,
                          selected: _selectedSituations,
                          onToggle: (s, sel) => setState(
                            () => sel
                                ? _selectedSituations.add(s)
                                : _selectedSituations.remove(s),
                          ),
                        ),
                        const SizedBox(height: 36),

                        _SubmitButton(onTap: _submit),
                      ],
                    ),
                  ),
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
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Light Text Field
// ─────────────────────────────────────────────────────────────────────────────

class _LightTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LightTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: _kText,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: _kPrimary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: _kPrimary, fontSize: 12),
        prefixIcon: Icon(icon, color: _kMuted, size: 20),
        filled: true,
        fillColor: _kCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
        errorStyle: TextStyle(color: Colors.red.shade400, fontSize: 11.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Relation Picker
// ─────────────────────────────────────────────────────────────────────────────

class _RelationPicker extends StatelessWidget {
  final List<String> relations;
  final Map<String, IconData> icons;
  final Map<String, Color> colors;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _RelationPicker({
    required this.relations,
    required this.icons,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: relations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final rel = relations[index];
          final isSelected = selected == rel;
          final color = colors[rel] ?? _kPrimary;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(rel);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 82,
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : _kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? color : _kBorder,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : _kSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icons[rel] ?? Icons.person_rounded,
                      color: isSelected ? color : _kMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rel,
                    style: TextStyle(
                      color: isSelected ? color : _kMuted,
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Situation Chips
// ─────────────────────────────────────────────────────────────────────────────

class _SituationChips extends StatelessWidget {
  final List<String> situations;
  final List<String> selected;
  final void Function(String, bool) onToggle;

  const _SituationChips({
    required this.situations,
    required this.selected,
    required this.onToggle,
  });

  static const _chipColors = [
    Color(0xFFE8500A), // Fire
    Color(0xFF1A9E5C), // Medical
    Color(0xFF2C5FD4), // Security
    Color(0xFF8B5C00), // Legal
    Color(0xFF0A72C4), // Flood
    Color(0xFF5B3FE8), // General SOS
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: situations.asMap().entries.map((entry) {
        final index = entry.key;
        final s = entry.value;
        final isSelected = selected.contains(s);
        final color = _chipColors[index % _chipColors.length];

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(s, !isSelected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : _kCard,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? color : _kBorder,
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle_rounded, size: 14, color: color),
                  const SizedBox(width: 5),
                ] else ...[
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: _kMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  s,
                  style: TextStyle(
                    color: isSelected ? color : _kMuted,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SubmitButton({required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPrimary, _kAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Add Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
