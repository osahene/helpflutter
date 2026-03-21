import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/otp_verification/otp_verification_screen.dart';
import 'package:helpflutter/presentation/screens/login/login_screen.dart';
import 'package:helpflutter/core/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _countryCode = '+233';

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
                isRegistration: true,
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
                                Icon(
                                  Icons.person_add_alt_1,
                                  size: 60,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Create Account',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Register to stay prepared for emergencies',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                CustomTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                CustomTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                /// 🔥 IMPROVED PHONE INPUT
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
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
                                        flex: 9,
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

                                /// 🔥 BUTTON WITH DEPTH
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final fullPhone =
                                          '$_countryCode${_phoneController.text}';
                                      context.read<AuthBloc>().add(
                                        RegisterWithPhone(
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                          phoneNumber: fullPhone,
                                        ),
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
                                    'Register',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Already have an account?'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('Sign In'),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
