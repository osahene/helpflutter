import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/registration/register_screen.dart';
import 'package:helpflutter/presentation/screens/login/login_screen.dart';
import 'package:helpflutter/presentation/screens/home/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isRegistration,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();

  int _timerSeconds = 30;
  bool _canResend = false;
  Timer? _timer;

  int _currentIndex = 0;
  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                currentIndex: _currentIndex,
                onTabTapped: _onTabTapped,
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundGlow(theme),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildAnimatedHeader(theme),
                        const SizedBox(height: 24),

                        /// GLASS CARD
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.7,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Enter Verification Code',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Text(
                                    widget.phoneNumber,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  /// 🔥 PIN INPUT
                                  Pinput(
                                    controller: _otpController,
                                    length: 6,
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: defaultPinTheme.copyWith(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onCompleted: (value) {
                                      context.read<AuthBloc>().add(
                                        VerifyOtp(
                                          phoneNumber: widget.phoneNumber,
                                          otp: value,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 30),

                                  /// 🔥 TIMER + RESEND
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _canResend
                                        ? TextButton(
                                            key: const ValueKey('resend'),
                                            onPressed: () {
                                              context.read<AuthBloc>().add(
                                                SendLoginOtp(
                                                  widget.phoneNumber,
                                                ),
                                              );
                                              _startTimer();
                                            },
                                            child: const Text('Resend Code'),
                                          )
                                        : Text(
                                            'Resend in $_timerSeconds s',
                                            key: const ValueKey('timer'),
                                          ),
                                  ),

                                  const SizedBox(height: 10),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => widget.isRegistration
                                              ? const RegisterScreen()
                                              : const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('Back'),
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

  Widget _buildAnimatedHeader(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 0.9 + (_pulseController.value * 0.2);
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 50,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGlow(ThemeData theme) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -50,
          child: _glowCircle(
            theme.colorScheme.primary.withValues(alpha: 0.15),
            250,
          ),
        ),
        Positioned(
          bottom: -120,
          right: -50,
          child: _glowCircle(
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            300,
          ),
        ),
      ],
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
