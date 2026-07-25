import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _businessNameValid => _businessNameController.text.trim().isNotEmpty;
  bool get _emailValid => _emailPattern.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.length >= 6;
  bool get _formValid => _businessNameValid && _emailValid && _passwordValid && !_submitting;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        businessName: _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      // Registration signs the user in — pop back so the root session gate
      // (now signedIn) is revealed underneath this pushed route.
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _field({required String label, required TextEditingController controller, required String hint, Widget? child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.sectionLabel),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: neuPressed(),
          child: child ??
              TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w500),
                ),
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  NeuCircleIcon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    color: AppColors.inkSoft,
                    size: 38,
                    iconSize: 15,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text('Create account', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(label: 'BUSINESS NAME', controller: _businessNameController, hint: 'Acme Roofing Co.'),
                      const SizedBox(height: 16),
                      _field(label: 'EMAIL', controller: _emailController, hint: 'you@business.com'),
                      const SizedBox(height: 16),
                      _field(label: 'PHONE (OPTIONAL)', controller: _phoneController, hint: '+91 98765 43210'),
                      const SizedBox(height: 16),
                      _field(
                        label: 'PASSWORD',
                        controller: _passwordController,
                        hint: 'At least 6 characters',
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) {
                                  if (_formValid) _register();
                                },
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  hintText: 'At least 6 characters',
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
                      const SizedBox(height: 18),
                      _submitting
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.4)),
                            )
                          : NeuPrimaryButton(label: 'Create account', onPressed: _formValid ? _register : null),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
