import 'api_client.dart';
import 'auth_repository.dart';

class SubscriptionInfo {
  const SubscriptionInfo({required this.plan, required this.isActive});

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(plan: json['plan'] as String, isActive: json['isActive'] as bool);
  }

  final String plan; // 'free' | 'pro'
  final bool isActive;

  bool get isPro => plan == 'pro';
}

/// GET/PATCH /subscription/me. Stateless — callers hold the returned
/// [SubscriptionInfo] themselves (see SubscriptionScreen).
class SubscriptionRepository {
  SubscriptionRepository._();
  static final SubscriptionRepository instance = SubscriptionRepository._();

  final _api = ApiClient.instance;

  Future<SubscriptionInfo> getMine() async {
    final data = await _api.get('/subscription/me');
    return SubscriptionInfo.fromJson(data);
  }

  /// Returns just the confirmed plan — the endpoint doesn't echo `isActive`,
  /// so callers should merge this into their existing [SubscriptionInfo].
  Future<String> updateMine(String plan) async {
    final data = await _api.patch('/subscription/me', body: {'plan': plan});
    final confirmedPlan = data['plan'] as String;
    // Keep the cached user profile (Profile screen banner) in sync.
    AuthRepository.instance.applyLocalSubscriptionPlan(confirmedPlan);
    return confirmedPlan;
  }
}
