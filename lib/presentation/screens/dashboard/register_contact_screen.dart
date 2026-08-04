import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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

// ── Country Code Model ────────────────────────────────────────────────────────
class CountryCode {
  final String name;
  final String flag;
  final String code;
  const CountryCode({
    required this.name,
    required this.flag,
    required this.code,
  });
}

// List of available country codes (same as login_screen)
const List<CountryCode> _countryCodes = [
  CountryCode(name: 'Ghana', flag: '🇬🇭', code: '+233'),
  // CountryCode(name: 'Nigeria', flag: '🇳🇬', code: '+234'),
  // CountryCode(name: 'Kenya', flag: '🇰🇪', code: '+254'),
  // CountryCode(name: 'South Africa', flag: '🇿🇦', code: '+27'),
  // CountryCode(name: 'United States', flag: '🇺🇸', code: '+1'),
  // CountryCode(name: 'United Kingdom', flag: '🇬🇧', code: '+44'),
  // CountryCode(name: 'Canada', flag: '🇨🇦', code: '+1'),
  // CountryCode(name: 'India', flag: '🇮🇳', code: '+91'),
  // CountryCode(name: 'Germany', flag: '🇩🇪', code: '+49'),
  // CountryCode(name: 'France', flag: '🇫🇷', code: '+33'),
  // CountryCode(name: 'Australia', flag: '🇦🇺', code: '+61'),
  // CountryCode(name: 'Brazil', flag: '🇧🇷', code: '+55'),
  // CountryCode(name: 'Senegal', flag: '🇸🇳', code: '+221'),
  // CountryCode(name: "Côte d'Ivoire", flag: '🇨🇮', code: '+225'),
  // CountryCode(name: 'Tanzania', flag: '🇹🇿', code: '+255'),
  // CountryCode(name: 'Uganda', flag: '🇺🇬', code: '+256'),
  // CountryCode(name: 'Rwanda', flag: '🇷🇼', code: '+250'),
  // CountryCode(name: 'Ethiopia', flag: '🇪🇹', code: '+251'),
  // CountryCode(name: 'Egypt', flag: '🇪🇬', code: '+20'),
  // CountryCode(name: 'Morocco', flag: '🇲🇦', code: '+212'),
];

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
  final _phoneController = TextEditingController(); // local number only
  final _emailController = TextEditingController();
  final _relationController = TextEditingController();
  List<String> _selectedSituations = [];
  bool _isPicking = false;

  CountryCode _selectedCountry = _countryCodes.first; // country code state

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // ── Add listeners to required fields ──────────────────────────────────
    _firstNameController.addListener(_updateValidity);
    _lastNameController.addListener(_updateValidity);
    _phoneController.addListener(_updateValidity);
    _relationController.addListener(_updateValidity);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _firstNameController.removeListener(_updateValidity);
    _lastNameController.removeListener(_updateValidity);
    _phoneController.removeListener(_updateValidity);
    _relationController.removeListener(_updateValidity);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  // ── Trigger rebuild when any required field changes ──────────────────
  void _updateValidity() {
    setState(() {});
  }

  Future<void> _pickContact() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (status != PermissionStatus.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to read contacts')),
        );
        return;
      }

      final String? contactId = await FlutterContacts.native.showPicker();
      if (contactId == null) return;

      final Contact? fullContact = await FlutterContacts.get(
        contactId,
        properties: ContactProperties.all,
      );
      if (fullContact == null) return;

      if (!mounted) return;

      final firstName = fullContact.name?.first ?? '';
      final lastName = fullContact.name?.last ?? '';

      if (firstName.isNotEmpty) {
        _firstNameController.text = firstName;
      }

      if (lastName.isNotEmpty) {
        _lastNameController.text = lastName;
      } else {
        final displayName = fullContact.displayName ?? '';
        if (displayName.isNotEmpty && _firstNameController.text.isEmpty) {
          _firstNameController.text = displayName;
        }
      }

      String rawNumber = '';
      final phones = fullContact.phones;

      if (phones.isNotEmpty) {
        final mobilePhone = phones.firstWhere(
          (p) => p.label == Label(PhoneLabel.mobile),
          orElse: () => phones.first,
        );
        rawNumber = mobilePhone.number.trim();
      }

      if (rawNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected contact has no phone number')),
        );
        return;
      }

      _parseAndSetPhoneNumber(rawNumber);

      if (fullContact.emails.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = fullContact.emails.first.address;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick contact: $e')));
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _parseAndSetPhoneNumber(String rawNumber) {
    String normalized = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!normalized.startsWith('+')) {
      _phoneController.text = normalized;
      return;
    }

    final sortedCodes = List<CountryCode>.from(_countryCodes)
      ..sort((a, b) => b.code.length.compareTo(a.code.length));

    CountryCode? matchedCode;
    String localPart = '';

    for (final code in sortedCodes) {
      if (normalized.startsWith(code.code)) {
        matchedCode = code;
        localPart = normalized.substring(code.code.length);
        break;
      }
    }

    if (matchedCode != null && localPart.isNotEmpty) {
      setState(() {
        _selectedCountry = matchedCode!;
        _phoneController.text = localPart;
      });
    } else {
      _phoneController.text = normalized;
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerSheet(
        countryCodes: _countryCodes,
        selectedCountry: _selectedCountry,
        onSelected: (c) {
          setState(() => _selectedCountry = c);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _submit() {
    // The button is disabled when invalid, but we keep the check for safety
    if (_formKey.currentState!.validate() &&
        _relationController.text.trim().isNotEmpty &&
        _selectedSituations.isNotEmpty) {
      HapticFeedback.mediumImpact();

      context.read<ContactsBloc>().add(
        AddContact(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _selectedCountry
              .code, // Make sure this provides the value (e.g. "+233")
          _phoneController.text.trim(),
          _emailController.text.trim(),
          _relationController.text.trim(),
          _selectedSituations, // Send the raw array list directly!
        ),
      );
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Please fill all required fields and select a situation'),
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

    // ── Compute validity ────────────────────────────────────────────────
    final bool isFormValid =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _relationController.text.trim().isNotEmpty &&
        _selectedSituations.isNotEmpty;

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
          _firstNameController.clear();
          _lastNameController.clear();
          _phoneController.clear();
          _emailController.clear();
          _relationController.clear();
          setState(() {
            _selectedSituations.clear();
          });
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
              // SliverAppBar (unchanged)
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                backgroundColor: _kPrimary,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
                centerTitle: true,
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
                        child: _Bubble(size: 60, opacity: 0.12),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: _Bubble(size: 100, opacity: 0.08),
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
              ),

              // Form Body
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
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        _LightTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
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
                          controller: _emailController,
                          label: 'Email (optional)',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.isEmpty
                              ? null
                              : (v.contains('@') ? null : 'Invalid email'),
                        ),
                        const SizedBox(height: 10),
                        // ── Phone number row with country code picker ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _kCard,
                                  border: Border.all(color: _kBorder, width: 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCountry.flag,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.code,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _kText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: _kMuted,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  _LightTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number',
                                    icon: Icons.phone_rounded,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    bottom: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.contacts_rounded,
                                        color: _kPrimary,
                                      ),
                                      onPressed: _isPicking
                                          ? null
                                          : _pickContact,
                                      tooltip: 'Pick from contacts',
                                      splashRadius: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Relation
                        _SectionLabel(
                          icon: Icons.people_alt_rounded,
                          label: 'Relation',
                          color: const Color(0xFF1AAE87),
                        ),
                        const SizedBox(height: 12),
                        _LightTextField(
                          controller: _relationController,
                          label: 'Relation',
                          icon: Icons.people_alt_rounded,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
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

                        // ── Submit Button (now receives `enabled`) ────
                        _SubmitButton(onTap: _submit, enabled: isFormValid),
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

// ── Decorative Bubble ────────────────────────────────────────────────────────
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

// ── Section Label ────────────────────────────────────────────────────────────
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

// ── Light Text Field ──────────────────────────────────────────────────────
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

// ── Situation Chips ──────────────────────────────────────────────────────────
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
    Color(0xFFE8500A),
    Color(0xFF1A9E5C),
    Color(0xFF2C5FD4),
    Color(0xFF8B5C00),
    Color(0xFF0A72C4),
    Color(0xFF5B3FE8),
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

// ── Submit Button (updated to support `enabled`) ──────────────────────────
class _SubmitButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled; // <-- new parameter

  const _SubmitButton({required this.onTap, required this.enabled});

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
    final bool isEnabled = widget.enabled;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _ctrl.forward() : null,
        onTapUp: isEnabled
            ? (_) {
                _ctrl.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: isEnabled ? () => _ctrl.reverse() : null,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [_kPrimary, _kAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFB0B8C8), Color(0xFF9AA2B5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isEnabled
                ? [
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
                  ]
                : null, // no shadow when disabled
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: isEnabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Add Contact',
                style: TextStyle(
                  color: isEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
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

// ── Country Picker Bottom Sheet ──────────────────────────────────────────────
// (unchanged – keep your existing implementation)
class _CountryPickerSheet extends StatefulWidget {
  final List<CountryCode> countryCodes;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onSelected;
  const _CountryPickerSheet({
    required this.countryCodes,
    required this.selectedCountry,
    required this.onSelected,
  });
  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _search = '';
  static const Color _accent = Color(0xFF4F8EF7);
  static const Color _accentLight = Color(0xFFEAF1FE);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _surface = Color(0xFFF7F9FC);
  List<CountryCode> get _filtered => widget.countryCodes
      .where(
        (c) =>
            c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.code.contains(_search),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Country Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 14, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search country or code...',
                hintStyle: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _accent,
                  size: 20,
                ),
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _border),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: _border.withValues(alpha: 0.6),
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (ctx, i) {
                final country = _filtered[i];
                final isSelected =
                    country.code == widget.selectedCountry.code &&
                    country.name == widget.selectedCountry.name;
                return InkWell(
                  onTap: () => widget.onSelected(country),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    color: isSelected ? _accentLight : Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? _accent : _textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          country.code,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? _accent : _textSecondary,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _accent,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
