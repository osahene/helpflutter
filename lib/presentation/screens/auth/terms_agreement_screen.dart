import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/auth/verify_otp_screen.dart';

class TermsAgreementScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;

  const TermsAgreementScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.phoneNumber,
  });

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  bool _agreed = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  // ── Palette ───────────────────────────────────────────
  static const Color _kPrimary = Color(0xFF2C5FD4);
  static const Color _kAccent = Color(0xFF5B3FE8);
  static const Color _kSurface = Color(0xFFF0F4FF);
  static const Color _kBorder = Color(0xFFDDE3F5);
  static const Color _kText = Color(0xFF0F1B3E);
  static const Color _kMuted = Color(0xFF8B94B2);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 60 &&
          !_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onAgreeAndRegister() {
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        widget.firstName,
        widget.lastName,
        widget.countryCode,
        widget.phoneNumber,
        agreedToTerms: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullPhone = '${widget.countryCode} ${widget.phoneNumber}';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyOtpScreen(
                countryCode: widget.countryCode,
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
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
      },
      child: Scaffold(
        backgroundColor: _kSurface,
        body: Column(
          children: [
            // ── Enhanced Hero Section ─────────────────────────────
            ClipRect(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    colors: [_kPrimary, _kAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Decorative Ambient Circles
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: -20,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),

                    // Main Header Content
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Navigation Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'STEP 2 OF 2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Row Header: Gavel Icon (Left) + Text (Right)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.gavel_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Terms of Agreement',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Please review carefully before finalizing your account setup',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),

            // ── Registration summary pill ───────────────
            Container(
              color: _kSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _kMuted,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Registering as '),
                      TextSpan(
                        text: '${widget.firstName} ${widget.lastName}',
                        style: const TextStyle(
                          color: _kText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' with '),
                      TextSpan(
                        text: fullPhone,
                        style: const TextStyle(
                          color: _kPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Scrollable terms body ───────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TermsClause(
                      number: '01',
                      color: Colors.red.shade600,
                      icon: Icons.warning_amber_rounded,
                      title: 'Non-Substitution Disclaimer',
                      body:
                          'Help OO Help is designed to notify your trusted circle when you need them. However, it does not replace official emergency services. In life-threatening situations, always prioritize contacting state institutions directly — Ghana Police (191 / 18555), Fire Service (192), Ambulance (112), or NADMO. We are here to support your safety network, not replace the authorities.',
                    ),
                    _TermsClause(
                      number: '02',
                      color: _kPrimary,
                      icon: Icons.info_outline_rounded,
                      title: 'How Alerts Work',
                      body:
                          'For a contact to receive your emergency alert:\n\n'
                          '1. You must register the contact in the app, specifying which types of emergencies they should be notified for.\n\n'
                          '2. The contact must explicitly approve your request before they can receive any alert.\n\n'
                          '3. When you trigger an alert, your approved contacts will receive: a voice call, an SMS, and a WhatsApp message containing your name, the type of emergency, your live GPS location, and a Google Maps link.\n\n'
                          'Inasmuch as they may be in a position to assist, they are strongly advised to get the appropriate authorities involved in so as to avoid potentially dangerous situations from befalling them.',
                    ),
                    _TermsClause(
                      number: '03',
                      color: const Color(0xFFE07A1A),
                      icon: Icons.cloud_off_rounded,
                      title: 'Technical & Delivery Disclaimer',
                      body:
                          'We work hard to make our alerts lightning-fast, but things like weak network coverage, dead batteries, or telecom outages can occasionally delay or block messages. Because we cannot control mobile infrastructure, TeenByte Tech Lab cannot be held legally responsible for failed deliveries. Simple visit the Emergency Contacts tab to access the contacts of all the relevant state emergency response agencies to report the incidents to them.',
                    ),
                    _TermsClause(
                      number: '04',
                      color: const Color(0xFF1A9E5C),
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy & Data Handling',
                      body:
                          'We value your privacy. Your personal information, including your name, phone number, and emergency contacts, is securely stored and used solely for the purpose of sending emergency alerts. We do not share your data with third parties without your explicit consent, except as required by law or to facilitate emergency response.',
                    ),
                    _TermsClause(
                      number: '05',
                      color: Colors.red.shade700,
                      icon: Icons.block_rounded,
                      title: 'False Alerts & Misuse',
                      body:
                          'This app is for genuine emergencies. While we understand that accidental "pocket-dials" happen, deliberately triggering fake or malicious alerts undermines the system and is strictly prohibited. Intentional misuse will result in account termination, and you may be held responsible for any harm caused. Please use this tool responsibly',
                    ),
                    _TermsClause(
                      number: '06',
                      color: const Color(0xFF1A9E5C),
                      icon: Icons.location_on_rounded,
                      title: 'Geolocation Consent',
                      body:
                          'We deeply respect your privacy. We only capture and share your live GPS coordinates with your chosen contacts exactly at the moment you trigger an alert. Your location is never continuously tracked in the background, stored beyond the alert record, or used for anything else. You can revoke this permission anytime by deleting your account.',
                    ),
                    const SizedBox(height: 8),
                    // Scroll nudge
                    if (!_hasScrolledToBottom)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _kMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Scroll to read all terms',
                                style: TextStyle(color: _kMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom action area ──────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _agreed
                            ? _kPrimary.withValues(alpha: 0.06)
                            : _kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _agreed ? _kPrimary : _kBorder,
                          width: _agreed ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _agreed ? _kPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreed ? _kPrimary : _kMuted,
                                width: 1.8,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I have read and I agree to the Terms of Agreement above.',
                              style: TextStyle(
                                color: _agreed ? _kText : _kMuted,
                                fontSize: 13.5,
                                fontWeight: _agreed
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Submit button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: ElevatedButton(
                            onPressed: (_agreed && !isLoading)
                                ? _onAgreeAndRegister
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _agreed ? _kPrimary : _kBorder,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _kBorder,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.how_to_reg_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'I Agree & Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
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

// ─────────────────────────────────────────────────────────────────────────────
// Individual Terms Clause Card
// ─────────────────────────────────────────────────────────────────────────────

class _TermsClause extends StatelessWidget {
  final String number;
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  const _TermsClause({
    required this.number,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F1B3E),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFDDE3F5)),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13.5,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
