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
            // ── Header ─────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kPrimary, _kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
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
                      const SizedBox(height: 16),
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 14),
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
                        'Please read carefully before registering',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
                          'Help OO Help is a supplementary peer-to-peer emergency notification system and is NOT a replacement for primary state emergency services. In any emergency situation, you should ALWAYS contact the appropriate state institutions directly — Ghana Police Service (191 / 18555), Ghana Fire Service (192), National Ambulance Service (0501614877), or NADMO (112). This app exists to supplement those services by alerting your trusted contacts, not to replace them.',
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
                          'Upon receiving an alert, contacts are advised to notify the appropriate state institutions (police, fire service, ambulance) rather than putting themselves in danger by physically responding.',
                    ),
                    _TermsClause(
                      number: '03',
                      color: const Color(0xFFE07A1A),
                      icon: Icons.cloud_off_rounded,
                      title: 'Technical & Delivery Disclaimer',
                      body:
                          'Help OO Help and TeenByte Tech Lab disclaim all liability for failed, delayed, or undelivered alerts caused by: third-party telecom outages, network congestion, weak or unavailable GPS signals, low device battery, recipient device issues, or WhatsApp/SMS gateway unavailability. Alert delivery depends on infrastructure beyond our control. Always call state emergency services directly in life-threatening situations.',
                    ),
                    _TermsClause(
                      number: '04',
                      color: const Color(0xFF5B3FE8),
                      icon: Icons.people_outline_rounded,
                      title: 'Recipient Action Disclaimer',
                      body:
                          'TeenByte Tech Lab bears no responsibility for the actions, omissions, decisions, or physical safety of any emergency contact who chooses to respond to an alert. The company is not liable for any harm, injury, loss, or damage suffered by a contact as a result of physically responding to or ignoring an emergency alert.',
                    ),
                    _TermsClause(
                      number: '05',
                      color: Colors.red.shade700,
                      icon: Icons.block_rounded,
                      title: 'False Alerts & Misuse',
                      body:
                          'Triggering false, malicious, or negligently careless emergency alerts is strictly prohibited. Violation of this rule will result in immediate and permanent account termination without prior notice. The account holder may also be held liable for any damages, costs (including legal costs), or harm caused to third parties as a direct or indirect result of a false alert. Repeated misuse may be reported to the relevant law enforcement authorities.',
                    ),
                    _TermsClause(
                      number: '06',
                      color: const Color(0xFF1A9E5C),
                      icon: Icons.location_on_rounded,
                      title: 'Geolocation Consent',
                      body:
                          'By agreeing to these terms, you explicitly consent to Help OO Help capturing, processing, and transmitting your real-time GPS coordinates to your designated emergency contacts at the moment you trigger an emergency alert. Location data is captured only when an alert is actively triggered and is not continuously monitored, stored beyond the alert record, or used for any other purpose. You may revoke this consent at any time by deleting your account.',
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
