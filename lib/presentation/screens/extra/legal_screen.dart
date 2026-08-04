import 'package:flutter/material.dart';

enum LegalPageType { termsOfService, privacyPolicy, dataDeletion }

void openLegalPage(BuildContext context, LegalPageType type) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LegalScreen(type: type)),
  );
}

const Color _kText = Color(0xFF0F1B3E);
const Color _kMuted = Color(0xFF8B94B2);
const Color _kSurface = Color(0xFFF0F4FF);
const Color _kBorder = Color(0xFFDDE3F5);
const Color _kPrimary = Color(0xFF2C5FD4);
const Color _kAccent = Color(0xFF5B3FE8);

// ─────────────────────────────────────────────────────────────────────────────
// LegalScreen — shell that renders one of the three pages
// ─────────────────────────────────────────────────────────────────────────────

class LegalScreen extends StatelessWidget {
  final LegalPageType type;
  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LegalPageType.termsOfService:
        return const _TermsOfServicePage();
      case LegalPageType.privacyPolicy:
        return const _PrivacyPolicyPage();
      case LegalPageType.dataDeletion:
        return const _DataDeletionPage();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared hero header — mirrors RegisterScreen's Stack + decorative circles +
// bottom-rounded gradient + icon-avatar/title pairing.
// ─────────────────────────────────────────────────────────────────────────────

class _LegalHeroHeader extends StatelessWidget {
  final String badge;
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final EdgeInsetsGeometry padding;

  const _LegalHeroHeader({
    required this.badge,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 32),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_kPrimary, _kAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
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
              color: const Color.fromARGB(
                255,
                21,
                23,
                194,
              ).withValues(alpha: 0.05),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(heroIcon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                              height: 1.4,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared scaffold for the two section-list pages (Terms / Privacy)
// ─────────────────────────────────────────────────────────────────────────────

class _LegalScaffold extends StatelessWidget {
  final String badge;
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final List<Color> headerGradient;
  final List<_LegalSection> sections;

  const _LegalScaffold({
    required this.badge,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.headerGradient,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: Column(
        children: [
          _LegalHeroHeader(
            badge: badge,
            heroIcon: heroIcon,
            title: title,
            subtitle: subtitle,
            gradient: headerGradient,
          ),

          // Content
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _SectionCard(section: sections[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a section
// ─────────────────────────────────────────────────────────────────────────────

class _LegalSection {
  final String number;
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  const _LegalSection({
    required this.number,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _LegalSection section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 1),
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
                  color: section.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(section.icon, color: section.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.number,
                      style: TextStyle(
                        color: section.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: _kText,
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
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 12),
          Text(
            section.body,
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

// ─────────────────────────────────────────────────────────────────────────────
// 1. Terms of Service
// ─────────────────────────────────────────────────────────────────────────────

class _TermsOfServicePage extends StatelessWidget {
  const _TermsOfServicePage();

  static const _sections = [
    _LegalSection(
      number: '01',
      color: _kPrimary,
      icon: Icons.info_outline_rounded,
      title: 'Acceptance of Terms',
      body:
          'By registering for or using Help OO Help, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, you must not use the app. These Terms constitute a legally binding agreement between you and TeenByte Tech Lab.',
    ),
    _LegalSection(
      number: '02',
      color: Color(0xFFE8500A),
      icon: Icons.apps_rounded,
      title: 'Service Description',
      body:
          'Help OO Help is an emergency notification platform enabling registered users to trigger rapid alerts during six crisis categories: Robbery Attack, Fire Outbreak, Flood Alert, Accident Alert, Health Crisis, and General Call Emergency.\n\nWhen triggered, the Service sends SMS, WhatsApp messages, and automated voice calls to approved emergency contacts — including the user\'s live GPS location and a one-time verification link.',
    ),
    _LegalSection(
      number: '03',
      color: Color(0xFF1A9E5C),
      icon: Icons.warning_amber_rounded,
      title: 'Non-Substitution Disclaimer',
      body:
          'Help OO Help is a supplementary peer-to-peer notification system and is NOT a replacement for primary state emergency services. In any emergency, ALWAYS contact the appropriate authorities directly:\n\n• Ghana Police Service: 191 / 18555\n• Ghana Fire Service: 192\n• National Ambulance Service: 0501614877\n• NADMO: 112\n\nThis app supplements those services — it does not replace them.',
    ),
    _LegalSection(
      number: '04',
      color: Color(0xFF7B22CE),
      icon: Icons.people_outline_rounded,
      title: 'Emergency Contacts & Consent',
      body:
          'For alerts to work:\n1. You must register the contact, specifying the alert types they should receive.\n2. The contact must explicitly approve your request.\n3. Only approved contacts receive alerts when you trigger one.\n\nBy adding a contact, you confirm you have their prior consent to receive emergency alerts on your behalf.',
    ),
    _LegalSection(
      number: '05',
      color: Color(0xFF25D366),
      icon: Icons.chat_bubble_outline_rounded,
      title: 'WhatsApp Communication',
      body:
          'Help OO Help uses the WhatsApp Business API to deliver emergency alerts. Messages contain your name, emergency type, GPS location, and a verification link.\n\nWe do not send promotional messages via WhatsApp — only emergency alerts you actively trigger. Message delivery depends on WhatsApp network availability and Meta\'s infrastructure.',
    ),
    _LegalSection(
      number: '06',
      color: Color(0xFFCC2222),
      icon: Icons.block_rounded,
      title: 'False Alerts & Misuse',
      body:
          'Triggering false, malicious, or negligent emergency alerts is strictly prohibited and will result in immediate account termination. Users may be held liable for damages, legal costs, or harm caused by false alerts. Repeated misuse may be reported to law enforcement authorities.',
    ),
    _LegalSection(
      number: '07',
      color: Color(0xFF0A72C4),
      icon: Icons.cloud_off_rounded,
      title: 'Technical & Delivery Disclaimer',
      body:
          'TeenByte Tech Lab disclaims all liability for failed, delayed, or undelivered alerts caused by telecom outages, network congestion, weak GPS signals, low device battery, or WhatsApp/SMS gateway unavailability. Always contact state emergency services directly in life-threatening situations.',
    ),
    _LegalSection(
      number: '08',
      color: Color(0xFFE07A1A),
      icon: Icons.gavel_rounded,
      title: 'Governing Law',
      body:
          'These Terms are governed by the laws of the Republic of Ghana. Disputes shall first be resolved through good-faith negotiation. If unresolved, disputes shall be submitted to the courts of competent jurisdiction in Ghana.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      badge: 'LEGAL DOCUMENT',
      heroIcon: Icons.description_rounded,
      title: 'Terms of Service',
      subtitle: 'Please read before using Help OO Help',
      headerGradient: [Color(0xFF0D1B4B), _kPrimary],
      sections: _sections,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Privacy Policy
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacyPolicyPage extends StatelessWidget {
  const _PrivacyPolicyPage();

  static const _sections = [
    _LegalSection(
      number: '01',
      color: _kPrimary,
      icon: Icons.info_outline_rounded,
      title: 'Overview',
      body:
          'Help OO Help, operated by TeenByte Tech Lab, is an emergency response platform. This Privacy Policy explains what personal data we collect, why we collect it, how it is used, who it may be shared with, and your rights over your data. By using the app, you agree to the practices described here.',
    ),
    _LegalSection(
      number: '02',
      color: Color(0xFFE8500A),
      icon: Icons.storage_rounded,
      title: 'Data We Collect',
      body:
          '• Account Data: First name, last name, phone number (country code + number).\n\n• Emergency Contact Data: Contact name, phone, email, relationship, and alert types — used exclusively for sending approved alerts.\n\n• Real-Time Location: GPS coordinates captured only when you trigger an alert. Not continuously tracked or stored beyond the alert record.\n\n• Alert History: Type, timestamp, and contacts notified — visible in your profile.\n\n• WhatsApp/SMS Data: Delivery status of messages sent to contacts. Message content is not stored by us.',
    ),
    _LegalSection(
      number: '03',
      color: Color(0xFF1A9E5C),
      icon: Icons.memory_rounded,
      title: 'How We Use Your Data',
      body:
          '• To create and maintain your account\n• To send SMS, WhatsApp, and voice call alerts to approved contacts when you trigger one\n• To share your live GPS location with contacts during an active alert\n• To generate and send a verification link to contacts\n• To display your alert history in your profile\n• To send OTP for account verification\n• To improve app performance',
    ),
    _LegalSection(
      number: '04',
      color: Color(0xFF25D366),
      icon: Icons.chat_bubble_outline_rounded,
      title: 'WhatsApp Business API',
      body:
          'We use the WhatsApp Business API (Meta Platforms, Inc.) solely to deliver emergency alert messages to approved contacts. Messages include: your full name, emergency type, a GPS coordinates link, and a one-time verification link.\n\nWe do not use WhatsApp data for marketing. Meta\'s own Terms of Service apply to message delivery. We fully comply with Meta\'s WhatsApp Business Policy.',
    ),
    _LegalSection(
      number: '05',
      color: Color(0xFF7B22CE),
      icon: Icons.share_rounded,
      title: 'Data Sharing',
      body:
          'We do not sell, rent, or trade your personal data.\n\nWe share data only in these limited cases:\n• Emergency Contacts: Your name, emergency type, location, and verification link are shared with your approved contacts when you trigger an alert.\n• Service Providers: Trusted third parties (SMS/WhatsApp/hosting) process data only as instructed by us.\n• Legal Obligations: If required by law or court order.',
    ),
    _LegalSection(
      number: '06',
      color: Color(0xFF0A72C4),
      icon: Icons.schedule_rounded,
      title: 'Data Retention',
      body:
          'We retain your data while your account is active. Upon account deletion, all personal data is permanently erased within 30 days, except where retention is required by law. Alert logs may be retained in anonymised form for statistical purposes.',
    ),
    _LegalSection(
      number: '07',
      color: Color(0xFFE07A1A),
      icon: Icons.verified_user_rounded,
      title: 'Your Rights',
      body:
          '• Access: Request a copy of your personal data.\n• Rectification: Update or correct inaccurate information in the app.\n• Erasure: Delete your account and data (see Data Deletion).\n• Restriction: Request we limit processing in certain circumstances.\n• Data Portability: Request your data in a structured format.\n• Withdraw Consent: You may withdraw location consent by deleting your account.\n\nContact: privacy@helpoohelp.com',
    ),
    _LegalSection(
      number: '08',
      color: Color(0xFFCC2222),
      icon: Icons.security_rounded,
      title: 'Data Security',
      body:
          'We implement industry-standard measures including HTTPS/TLS encryption, hashed credential storage, and access controls. No online system is 100% secure. We will notify you and the relevant authority in the event of a data breach that poses risk to your rights.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      badge: 'LEGAL DOCUMENT',
      heroIcon: Icons.privacy_tip_rounded,
      title: 'Privacy Policy',
      subtitle: 'How we collect, use, and protect your data',
      headerGradient: [Color(0xFF0D1B4B), _kAccent],
      sections: _sections,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Data Deletion
// ─────────────────────────────────────────────────────────────────────────────

class _DataDeletionPage extends StatelessWidget {
  const _DataDeletionPage();

  static const _steps = [
    _LegalSection(
      number: '01',
      color: _kPrimary,
      icon: Icons.login_rounded,
      title: 'Log In to Your Account',
      body:
          'Open the Help OO Help app and sign in with the phone number you registered with.',
    ),
    _LegalSection(
      number: '02',
      color: Color(0xFFE07A1A),
      icon: Icons.person_outline_rounded,
      title: 'Navigate to Your Profile',
      body:
          'Tap the profile avatar in the top-left corner of the home screen navigation bar, or open the menu and select "Profile".',
    ),
    _LegalSection(
      number: '03',
      color: Color(0xFFCC2222),
      icon: Icons.delete_outline_rounded,
      title: 'Select "Delete Account"',
      body:
          'Scroll to the bottom of your Profile page. Tap the red "Delete Account" button to begin the deletion process.',
    ),
    _LegalSection(
      number: '04',
      color: Color(0xFF7B22CE),
      icon: Icons.sms_rounded,
      title: 'Confirm Your Identity',
      body:
          'A one-time OTP will be sent to your registered phone number. Enter it to verify you are the authorised account owner.',
    ),
    _LegalSection(
      number: '05',
      color: Color(0xFF1A9E5C),
      icon: Icons.check_circle_outline_rounded,
      title: 'Final Confirmation',
      body:
          'A confirmation dialog will summarise what will be permanently deleted. Tap "Confirm & Delete". This action is irreversible.',
    ),
    _LegalSection(
      number: '06',
      color: Color(0xFF8B5C00),
      icon: Icons.hourglass_bottom_rounded,
      title: 'Deletion Completed',
      body:
          'Your account, contacts, dependents, location history, and alert records will be permanently deleted within 30 days. A confirmation will be sent to your registered number.',
    ),
  ];

  static const _deleted = [
    'Account information (name, phone number, login credentials)',
    'All emergency contacts you have registered',
    'All dependent records',
    'GPS location history captured during past alerts',
    'Alert history and delivery logs',
    'All authentication and session tokens',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: Column(
        children: [
          const _LegalHeroHeader(
            badge: 'YOUR DATA RIGHTS',
            heroIcon: Icons.delete_forever_rounded,
            title: 'Data Deletion',
            subtitle: 'How to permanently delete your account and data',
            gradient: [Color(0xFF3D0000), Color(0xFFCC2222)],
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                // Warning notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFCC2222),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Warning',
                              style: TextStyle(
                                color: Color(0xFFCC2222),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Account deletion is permanent and cannot be undone. All your data will be erased and your emergency contacts will no longer receive alerts from you.',
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Steps
                const _StepsSectionHeader(
                  label: 'HOW TO DELETE YOUR ACCOUNT',
                  color: Color(0xFFCC2222),
                ),
                const SizedBox(height: 12),
                ..._steps.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SectionCard(section: s),
                  ),
                ),

                // Manual request
                const SizedBox(height: 8),
                const _StepsSectionHeader(
                  label: "CAN'T ACCESS THE APP?",
                  color: _kPrimary,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _kBorder, width: 1),
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
                      const Text(
                        'Submit a Manual Deletion Request',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: privacy@helpoohelp.com',
                              style: TextStyle(
                                color: _kText,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Subject: Data Deletion Request — [Your Phone Number]',
                              style: TextStyle(
                                color: _kMuted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Include: your full name, registered phone, and confirmation that you wish to permanently delete your data.',
                              style: TextStyle(
                                color: _kMuted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We will acknowledge within 72 hours and complete deletion within 30 days of identity verification.',
                        style: TextStyle(
                          color: _kMuted,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // What gets deleted
                const SizedBox(height: 16),
                const _StepsSectionHeader(
                  label: 'WHAT IS DELETED',
                  color: Color(0xFFCC2222),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _kBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _deleted
                        .map(
                          (d) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFCC2222),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      color: Color(0xFF374151),
                                      fontSize: 13.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsSectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _StepsSectionHeader({required this.label, required this.color});

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
        Text(
          label,
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
