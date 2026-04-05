import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/dashboard/dashboard_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  // 6 individual controllers + focus nodes for the digit boxes
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Resend countdown
  static const int _resendSeconds = 60;
  int _secondsRemaining = _resendSeconds;
  bool _canResend = false;
  Timer? _timer;

  // Color palette — identical to the rest of the auth flow
  static const Color _accent = Color(0xFF4F8EF7);
  static const Color _accentLight = Color(0xFFEAF1FE);
  static const Color _surface = Color(0xFFF7F9FC);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();

    _startCountdown();

    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _secondsRemaining = _resendSeconds;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _digitControllers.map((c) => c.text).join();

  bool get _otpComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Handle paste — if 6 digits land in one box, distribute them
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        _digitControllers[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
    }
    setState(() {});
    if (_otpComplete) _handleVerify();
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleVerify() {
    if (!_otpComplete) return;
    // context.read<AuthBloc>().add(
    //   AuthVerifyOtpRequested('+233', widget.phoneNumber, _otpValue),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _handleResend() {
    if (!_canResend) return;
    for (final c in _digitControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startCountdown();
    // context.read<AuthBloc>().add(
    //   AuthSendOtpRequested('+233', widget.phoneNumber),
    // );
  }

  String _formatPhone(String raw) {
    // Mask everything except last 4 digits, e.g. +233 *** **** 3456
    if (raw.length <= 4) return raw;
    final visible = raw.substring(raw.length - 4);
    final masked = raw
        .substring(0, raw.length - 4)
        .replaceAll(RegExp(r'\d'), '*');
    return '$masked$visible';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: _errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _white,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surface,
                border: Border.all(color: _border, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: _textPrimary,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: SafeArea(
          top: false,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Icon badge ──────────────────────────────────────
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _accentLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: _accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Heading ─────────────────────────────────────────
                    const Text(
                      'Enter OTP Code',
                      style: TextStyle(
                        // fontFamily: 'Georgia',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          color: _textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'A 6-digit code was sent to '),
                          TextSpan(
                            text: _formatPhone(widget.phoneNumber),
                            style: const TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── OTP digit boxes ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (i) => _DigitBox(
                          controller: _digitControllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (v) => _onDigitChanged(i, v),
                          onKeyEvent: (e) => _onKeyEvent(i, e),
                          isFilled: _digitControllers[i].text.isNotEmpty,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Progress indicator strip ────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _otpValue.length / 6,
                        minHeight: 4,
                        backgroundColor: _border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_otpValue.length} of 6 digits entered',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Divider ─────────────────────────────────────────
                    Container(height: 1, color: _border),
                    const SizedBox(height: 28),

                    // ── Verify button ───────────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (!_otpComplete || isLoading)
                                ? null
                                : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _white,
                              disabledBackgroundColor: _accent.withValues(
                                alpha: 0.4,
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
                                      Text(
                                        'Verify Code',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Resend row ──────────────────────────────────────
                    Center(
                      child: _canResend
                          ? GestureDetector(
                              onTap: _handleResend,
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Resend code in ',
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${_secondsRemaining}s',
                                  style: const TextStyle(
                                    color: _accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 32),

                    // ── Info card ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _accentLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: _accent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'The OTP expires in 10 minutes. Do not share it with anyone.',
                              style: TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Individual digit box ─────────────────────────────────────────────────────
class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final bool isFilled;

  static const Color _accent = Color(0xFF4F8EF7);
  static const Color _accentLight = Color(0xFFEAF1FE);
  static const Color _surface = Color(0xFFF7F9FC);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _textPrimary = Color(0xFF0F172A);

  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6, // allow paste of full code
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isFilled ? _accentLight : _surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isFilled ? _accent : _border,
                width: isFilled ? 2 : 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isFilled ? _accent : _border,
                width: isFilled ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
