import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/subscription_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _repo = SubscriptionRepository.instance;
  SubscriptionInfo? _subscription;
  bool _loading = true;
  bool _changingPlan = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await _repo.getMine();
      setState(() => _subscription = info);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _switchPlan(String plan) async {
    if (_subscription == null || _subscription!.plan == plan) return;
    setState(() => _changingPlan = true);
    try {
      final confirmedPlan = await _repo.updateMine(plan);
      setState(() => _subscription = SubscriptionInfo(plan: confirmedPlan, isActive: _subscription!.isActive));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(confirmedPlan == 'pro' ? 'Upgraded to Pro' : 'Switched to Free')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _changingPlan = false);
    }
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
                    child: Text('Subscription', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blue));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.redInk)),
              const SizedBox(height: 14),
              NeuPrimaryButton(label: 'Retry', onPressed: _load),
            ],
          ),
        ),
      );
    }

    final isPro = _subscription?.isPro ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Choose the plan that fits how many leads you close.',
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
        const SizedBox(height: 18),
        _PlanCard(
          name: 'Free',
          price: '₹0',
          features: const [
            _Feature('Up to 50 calls / month', true),
            _Feature('Manual call logging', true),
            _Feature('Basic lead cards', true),
            _Feature('Automatic call recording', false),
            _Feature('WhatsApp template broadcast', false),
          ],
          isCurrent: !isPro,
          highlighted: false,
          busy: _changingPlan,
          onSelect: () => _switchPlan('free'),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          name: 'Pro',
          price: '₹499',
          features: const [
            _Feature('Unlimited calls', true),
            _Feature('Automatic call recording', true),
            _Feature('Advanced lead management', true),
            _Feature('WhatsApp template broadcast', true),
            _Feature('Priority support', true),
          ],
          isCurrent: isPro,
          highlighted: true,
          busy: _changingPlan,
          onSelect: () => _switchPlan('pro'),
        ),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.text, this.included);
  final String text;
  final bool included;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    required this.isCurrent,
    required this.highlighted,
    required this.busy,
    required this.onSelect,
  });

  final String name;
  final String price;
  final List<_Feature> features;
  final bool isCurrent;
  final bool highlighted;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final card = NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
              Text.rich(
                TextSpan(
                  text: price,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                  children: const [TextSpan(text: '/month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkFaint))],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final f in features) _FeatureLine(text: f.text, included: f.included),
          const SizedBox(height: 14),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text('Current Plan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkFaint)),
            )
          else
            GestureDetector(
              onTap: busy ? null : onSelect,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: neuRaisedSm(radius: 14),
                child: busy
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blueInk))
                    : Text(name == 'Pro' ? 'Upgrade' : 'Downgrade', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
              ),
            ),
        ],
      ),
    );

    if (!highlighted) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(color: AppColors.blue.withAlpha(115), width: 2),
          ),
          child: card,
        ),
        if (isCurrent)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(kRadiusPill)),
              child: const Text(
                'CURRENT PLAN',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.text, required this.included});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    final color = included ? AppColors.greenInk : AppColors.inkFaint;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Icon(included ? Icons.check_rounded : Icons.close_rounded, size: 16, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: included ? AppColors.ink : AppColors.inkFaint),
            ),
          ),
        ],
      ),
    );
  }
}
