import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../common/utils/constants/colors.dart';
import 'biometric_prompt_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.slate50,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), backgroundColor: TColors.error),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: TColors.blue100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: TColors.executiveNavy, width: 2.0),
                          ),
                          child: const Icon(Iconsax.teacher, size: 48, color: TColors.executiveNavy),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'SMARTCAMPUS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: TColors.slate900,
                          letterSpacing: -1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PROFESSOR PORTAL SECURE LOGIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: TColors.slate600,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: TColors.slate400, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Iconsax.user_square, size: 20),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'ENTER YOUR EMAIL';
                                if (!value.contains('@')) return 'ENTER A VALID EMAIL';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              prefixIcon: const Icon(Iconsax.key, size: 20),
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash, size: 20),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'ENTER YOUR PASSWORD';
                                if (value.length < 6) return 'MINIMUM 6 CHARACTERS';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                child: const Text(
                                  'FORGOT PASSWORD?',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: TColors.executiveNavy, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'SIGN IN',
                              onPressed: _onLogin,
                              isLoading: state is AuthLoading,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "USE BIOMETRIC ACCESS",
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: TColors.slate600, letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const BiometricPromptDialog(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TColors.blue100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: TColors.executiveNavy, width: 1.5),
                              ),
                              child: const Icon(Iconsax.finger_scan, size: 24, color: TColors.executiveNavy),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
