import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — coming soon.')));
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = AuthRepository.instance.currentUser;
    if (user == null) return;

    final businessNameController = TextEditingController(text: user.businessName);
    final phoneController = TextEditingController(text: user.phone ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProfileSheet(
        businessNameController: businessNameController,
        phoneController: phoneController,
      ),
    );

    if (saved == true && context.mounted) {
      try {
        await AuthRepository.instance.updateProfile(
          businessName: businessNameController.text.trim(),
          phone: phoneController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthRepository.instance.logout();
    // The root session gate reacts to the signedOut status and swaps to LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthRepository.instance,
      builder: (context, _) {
        final user = AuthRepository.instance.currentUser;
        final initials = _initialsFor(user?.businessName ?? '');
        final isPro = user?.isPro ?? false;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text('Profile', style: AppText.screenTitle),
            const SizedBox(height: 16),
            NeuCard(
              child: Row(
                children: [
                  Avatar(initials: initials, size: 52, fontSize: 16),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.businessName ?? '—', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        const SizedBox(height: 2),
                        Text(
                          [user?.email, user?.phone].where((s) => s != null && s.isNotEmpty).join(' · '),
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _editProfile(context),
                    child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeuCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: neuRaisedSm(radius: 14),
                    child: const Icon(Icons.workspace_premium_rounded, size: 20, color: AppColors.amberInk),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(isPro ? 'Ringlead Pro' : 'Ringlead Free', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                            const SizedBox(width: 8),
                            StatusPill(label: isPro ? 'PRO' : 'FREE', color: isPro ? AppColors.greenInk : AppColors.inkFaint),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Tap to manage your plan', style: AppText.caption),
                      ],
                    ),
                  ),
                  const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREFERENCES', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            NeuCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _SettingsRow(icon: Icons.call_rounded, label: 'Call Settings', onTap: () => _comingSoon(context, 'Call Settings')),
                  const Divider(height: 1, color: AppColors.line),
                  _SettingsRow(icon: Icons.mic_rounded, label: 'Recording Settings', onTap: () => _comingSoon(context, 'Recording Settings')),
                  const Divider(height: 1, color: AppColors.line),
                  _SettingsRow(icon: Icons.description_rounded, label: 'WhatsApp Templates', onTap: () => _comingSoon(context, 'WhatsApp Templates')),
                  const Divider(height: 1, color: AppColors.line),
                  _SettingsRow(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () => _comingSoon(context, 'Notifications')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('DATA', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            NeuCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _SettingsRow(icon: Icons.cloud_rounded, label: 'Backup & Sync', onTap: () => _comingSoon(context, 'Backup & Sync')),
            ),
            const SizedBox(height: 20),
            const Text('SUPPORT', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            NeuCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _SettingsRow(icon: Icons.help_rounded, label: 'Help & Support', onTap: () => _comingSoon(context, 'Help & Support')),
                  const Divider(height: 1, color: AppColors.line),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: AppColors.redInk,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Ringlead v2.4.1', textAlign: TextAlign.center, style: AppText.tiny),
          ],
        );
      },
    );
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    final letters = words.take(2).map((w) => w[0].toUpperCase()).join();
    return letters.isEmpty ? '—' : letters;
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.businessNameController, required this.phoneController});

  final TextEditingController businessNameController;
  final TextEditingController phoneController;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Edit profile', style: AppText.screenTitle),
            const SizedBox(height: 18),
            const Text('BUSINESS NAME', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: neuPressed(),
              child: TextField(
                controller: widget.businessNameController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
              ),
            ),
            const SizedBox(height: 16),
            const Text('PHONE', style: AppText.sectionLabel),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: neuPressed(),
              child: TextField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: '+91 98765 43210'),
              ),
            ),
            const SizedBox(height: 22),
            NeuPrimaryButton(label: 'Save changes', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, this.color = AppColors.blueInk, this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: neuRaisedSm(radius: 10),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color == AppColors.redInk ? color : AppColors.ink))),
            if (color != AppColors.redInk) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
