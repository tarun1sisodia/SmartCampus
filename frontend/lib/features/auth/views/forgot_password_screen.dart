import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../../../common/utils/constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _submit() {
    if (_emailController.text.isEmpty) return;
    context.read<AuthBloc>().add(
          ForgotPasswordRequested(email: _emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: const Text('PASSWORD RECOVERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInfo) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: TColors.error,
              ),
            );
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TColors.blue100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: TColors.executiveNavy, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Iconsax.info_circle, color: TColors.executiveNavy, size: 24),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'ENTER YOUR REGISTERED EMAIL ADDRESS TO RECEIVE A SECURE RESET LINK.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TColors.executiveNavy, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                      prefixIcon: const Icon(Iconsax.sms, size: 20),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'SEND RESET LINK',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
