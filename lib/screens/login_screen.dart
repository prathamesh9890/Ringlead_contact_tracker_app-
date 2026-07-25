import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _emailValid => _emailPattern.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.length >= 6;
  bool get _formValid => _emailValid && _passwordValid && !_submitting;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.login(_emailController.text.trim(), _passwordController.text);
      // AuthRepository flips to signedIn — the root session gate swaps to AppShell.
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: neuRaised(radius: 22),
                child: const Icon(Icons.call_rounded, size: 30, color: AppColors.blueInk),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ringlead',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage every call and lead in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 32),
              NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('EMAIL', style: AppText.sectionLabel),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: neuPressed(),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'you@business.com',
                          hintStyle: TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('PASSWORD', style: AppText.sectionLabel),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: neuPressed(),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) {
                                if (_formValid) _login();
                              },
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 18,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.redInk)),
                    ],
                    const SizedBox(height: 16),
                    _submitting
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.4)),
                          )
                        : NeuPrimaryButton(label: 'Sign In', onPressed: _formValid ? _login : null),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _submitting ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: AppText.caption,
                          children: [TextSpan(text: 'Create one', style: TextStyle(color: AppColors.blueInk, fontWeight: FontWeight.w700))],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "By continuing, you agree to Ringlead's Terms and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: AppText.tiny,
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
