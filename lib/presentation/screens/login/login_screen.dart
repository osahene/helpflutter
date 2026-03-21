import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/otp_verification/otp_verification_screen.dart';
import 'package:helpflutter/presentation/screens/home/home_screen.dart';
import 'package:helpflutter/presentation/screens/registration/register_screen.dart';
import 'package:helpflutter/core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _countryCode = '+233';

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: state.phoneNumber,
                isRegistration: false,
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                currentIndex: _currentIndex,
                onTabTapped: _onTabTapped,
              ),
            ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.7,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 10),

                                /// 🔥 ICON HEADER
                                Icon(
                                  Icons.lock_outline,
                                  size: 60,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  'Welcome Back',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  'Login to continue and stay protected',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withValues(alpha: 0.6),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// 🔥 IMPROVED PHONE INPUT
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CountryCodePicker(
                                        padding: EdgeInsets.zero,
                                        onChanged: (code) =>
                                            _countryCode = code.dialCode!,
                                        initialSelection: 'GH',
                                        showFlag: true,
                                        showDropDownButton: true,
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: CustomTextField(
                                          controller: _phoneController,
                                          label: 'Phone Number',
                                          keyboardType: TextInputType.phone,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Required'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// 🔥 CTA BUTTON
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final fullPhone =
                                          '$_countryCode${_phoneController.text}';
                                      context.read<AuthBloc>().add(
                                        SendLoginOtp(fullPhone),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 8,
                                    shadowColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Send OTP',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?"),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('Register'),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
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
    _phoneController.dispose();
    super.dispose();
  }
}
