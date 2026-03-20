// lib/presentation/screens/auth/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 30;
    _canResend = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_timerSeconds > 0) {
            _timerSeconds--;
            _startTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is EmailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully')),
          );
          Navigator.pop(context);
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.colorScheme.background, theme.colorScheme.surface],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: theme.cardTheme.color,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Email Verification',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter the 6-digit code sent to ${widget.email}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Pinput(
                          controller: _otpController,
                          length: 6,
                          onCompleted: (value) {
                            context.read<AuthBloc>().add(
                              VerifyEmailOtpRequested(
                                email: widget.email,
                                otp: value,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Resend in $_timerSeconds seconds'),
                            if (_canResend)
                              TextButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    SendEmailOtpRequested(widget.email),
                                  );
                                  _startTimer();
                                },
                                child: const Text('Resend Code'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
