import 'package:flutter/material.dart';
import 'package:helpflutter/presentation/screens/auth/terms_agreement_screen.dart';

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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<CountryCode> _countryCodes = [
    CountryCode(name: 'Ghana', flag: '🇬🇭', code: '+233'),
    CountryCode(name: 'Nigeria', flag: '🇳🇬', code: '+234'),
    CountryCode(name: 'Kenya', flag: '🇰🇪', code: '+254'),
    CountryCode(name: 'South Africa', flag: '🇿🇦', code: '+27'),
    CountryCode(name: 'United States', flag: '🇺🇸', code: '+1'),
    CountryCode(name: 'United Kingdom', flag: '🇬🇧', code: '+44'),
    CountryCode(name: 'Canada', flag: '🇨🇦', code: '+1'),
    CountryCode(name: 'India', flag: '🇮🇳', code: '+91'),
    CountryCode(name: 'Germany', flag: '🇩🇪', code: '+49'),
    CountryCode(name: 'France', flag: '🇫🇷', code: '+33'),
    CountryCode(name: 'Australia', flag: '🇦🇺', code: '+61'),
    CountryCode(name: 'Brazil', flag: '🇧🇷', code: '+55'),
    CountryCode(name: 'Senegal', flag: '🇸🇳', code: '+221'),
    CountryCode(name: 'Tanzania', flag: '🇹🇿', code: '+255'),
    CountryCode(name: 'Uganda', flag: '🇺🇬', code: '+256'),
    CountryCode(name: 'Rwanda', flag: '🇷🇼', code: '+250'),
    CountryCode(name: 'Ethiopia', flag: '🇪🇹', code: '+251'),
    CountryCode(name: 'Egypt', flag: '🇪🇬', code: '+20'),
    CountryCode(name: 'Morocco', flag: '🇲🇦', code: '+212'),
    CountryCode(name: 'Cameroon', flag: '🇨🇲', code: '+237'),
    CountryCode(name: 'Zimbabwe', flag: '🇿🇼', code: '+263'),
    CountryCode(name: 'Zambia', flag: '🇿🇲', code: '+260'),
  ];

  CountryCode _selectedCountry = _countryCodes.first;

  static const Color _kPrimary = Color(0xFF2C5FD4);
  static const Color _kAccent = Color(0xFF5B3FE8);
  static const Color _kSurface = Color(0xFFF0F4FF);
  static const Color _kBorder = Color(0xFFDDE3F5);
  static const Color _kText = Color(0xFF0F1B3E);
  static const Color _kMuted = Color(0xFF8B94B2);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validate form then navigate to TermsAgreementScreen.
  // Form data is held in state — NO API call here.
  void _proceedToTerms() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => TermsAgreementScreen(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            countryCode: _selectedCountry.code,
            phoneNumber: _phoneController.text.trim(),
          ),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  InputDecoration _dec(
    String label,
    String hint,
    IconData icon,
  ) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(
      color: _kMuted,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: _kMuted.withValues(alpha: 0.5), fontSize: 14),
    prefixIcon: Icon(icon, color: _kPrimary, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _kBorder, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _kBorder, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _kPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
    errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11.5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_kPrimary, _kAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GestureDetector(
                            //   onTap: () => Navigator.pop(context),
                            //   child: Container(
                            //     width: 40,
                            //     height: 40,
                            //     decoration: BoxDecoration(
                            //       color: Colors.white.withValues(alpha: 0.15),
                            //       borderRadius: BorderRadius.circular(12),
                            //       border: Border.all(
                            //         color: Colors.white.withValues(alpha: 0.25),
                            //         width: 1,
                            //       ),
                            //     ),
                            //     child: const Icon(
                            //       Icons.arrow_back_ios_new_rounded,
                            //       color: Colors.white,
                            //       size: 18,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Join your personal safety network',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.65,
                                        ),
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(
                          icon: Icons.badge_rounded,
                          label: 'Personal Info',
                          color: _kPrimary,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _kText,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dec(
                            'First Name',
                            'e.g. Kwame',
                            Icons.person_outline_rounded,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'First name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _kText,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dec(
                            'Last Name',
                            'e.g. Mensah',
                            Icons.person_outline_rounded,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Last name is required'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _Label(
                          icon: Icons.phone_rounded,
                          label: 'Phone Number',
                          color: const Color(0xFF1A9E5C),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select your country code and enter your number.',
                          style: TextStyle(color: _kMuted, fontSize: 12.5),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _CountrySheet(
                                  countryCodes: _countryCodes,
                                  selectedCountry: _selectedCountry,
                                  onSelected: (c) {
                                    setState(() => _selectedCountry = c);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _kBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCountry.flag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.code,
                                      style: const TextStyle(
                                        color: _kText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
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
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: _kText,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _dec(
                                  'Phone Number',
                                  'e.g. 244123456',
                                  Icons.phone_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (v.trim().length < 6) {
                                    return 'Enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Container(height: 1, color: _kBorder),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _proceedToTerms,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Already have an account?  ',
                                style: TextStyle(color: _kMuted, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      color: _kPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

class _Label extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Label({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Row(
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

class _CountrySheet extends StatefulWidget {
  final List<CountryCode> countryCodes;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onSelected;
  const _CountrySheet({
    required this.countryCodes,
    required this.selectedCountry,
    required this.onSelected,
  });
  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _search = '';
  static const Color _kPrimary = Color(0xFF2C5FD4);
  static const Color _kSurface = Color(0xFFF0F4FF);
  static const Color _kBorder = Color(0xFFDDE3F5);
  static const Color _kText = Color(0xFF0F1B3E);
  static const Color _kMuted = Color(0xFF8B94B2);

  List<CountryCode> get _f => widget.countryCodes
      .where(
        (c) =>
            c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.code.contains(_search),
      )
      .toList();

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.72,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: _kBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Country Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kText,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontSize: 14, color: _kText),
            decoration: InputDecoration(
              hintText: 'Search country or code…',
              hintStyle: TextStyle(
                color: _kMuted.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _kPrimary,
                size: 20,
              ),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: _kBorder),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _f.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: _kBorder.withValues(alpha: 0.5),
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (_, i) {
              final c = _f[i];
              final sel =
                  c.code == widget.selectedCountry.code &&
                  c.name == widget.selectedCountry.name;
              return InkWell(
                onTap: () => widget.onSelected(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  color: sel
                      ? _kPrimary.withValues(alpha: 0.07)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? _kPrimary : _kText,
                          ),
                        ),
                      ),
                      Text(
                        c.code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: sel ? _kPrimary : _kMuted,
                        ),
                      ),
                      if (sel) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: _kPrimary,
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
