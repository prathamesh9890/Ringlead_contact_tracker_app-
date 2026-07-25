class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.businessName,
    required this.phone,
    required this.role,
    required this.subscriptionPlan,
    required this.isActive,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      businessName: json['businessName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      subscriptionPlan: json['subscriptionPlan'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String email;
  final String businessName;
  final String? phone;
  final String role;
  final String subscriptionPlan;
  final bool isActive;
  final DateTime createdAt;

  bool get isPro => subscriptionPlan == 'pro';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'businessName': businessName,
        'phone': phone,
        'role': role,
        'subscriptionPlan': subscriptionPlan,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  AppUser copyWith({String? businessName, String? phone, String? subscriptionPlan}) {
    return AppUser(
      id: id,
      email: email,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      role: role,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
