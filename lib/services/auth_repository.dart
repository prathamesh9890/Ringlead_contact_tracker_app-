import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/app_user.dart';
import 'api_client.dart';
import 'notes_repository.dart';
import 'token_storage.dart';

enum AuthStatus { initializing, signedOut, signedIn }

/// Session + current-user state for the whole app: POST /auth/register,
/// POST /auth/login, POST /auth/logout, and the cached profile backing
/// GET/PATCH /users/me. Mirrors the singleton ChangeNotifier pattern used by
/// CallLogRepository elsewhere in the app.
class AuthRepository extends ChangeNotifier {
  AuthRepository._() {
    ApiClient.instance.onSessionExpired = _handleSessionExpired;
  }
  static final AuthRepository instance = AuthRepository._();

  final _api = ApiClient.instance;
  final _tokens = TokenStorage.instance;

  AuthStatus _status = AuthStatus.initializing;
  AppUser? _currentUser;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _status == AuthStatus.signedIn;

  /// Restores a cached session on app launch, if one exists.
  Future<void> bootstrap() async {
    final storedUser = await _tokens.readUser();
    final accessToken = await _tokens.readAccessToken();

    if (storedUser != null && accessToken != null) {
      _currentUser = storedUser;
      _status = AuthStatus.signedIn;
    } else {
      _status = AuthStatus.signedOut;
    }
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  }) async {
    final data = await _api.post(
      '/auth/register',
      auth: false,
      body: {
        'email': email,
        'password': password,
        'businessName': businessName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    await _applySession(data);
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login', auth: false, body: {'email': email, 'password': password});
    await _applySession(data);
  }

  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    try {
      await _api.post('/auth/logout', auth: false, body: {'refreshToken': refreshToken});
    } on ApiException {
      // Best-effort — clear local state regardless of server response.
    }
    await _tokens.clear();
    NotesRepository.instance.clearCache();
    _currentUser = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<void> updateProfile({String? businessName, String? phone}) async {
    final data = await _api.patch(
      '/users/me',
      body: {
        if (businessName != null) 'businessName': businessName,
        if (phone != null) 'phone': phone,
      },
    );
    _currentUser = AppUser.fromJson(data);
    await _tokens.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final data = await _api.get('/users/me');
    _currentUser = AppUser.fromJson(data);
    await _tokens.saveUser(_currentUser!);
    notifyListeners();
  }

  /// Keeps the cached profile's plan in sync after SubscriptionRepository
  /// updates it, without a redundant round trip to GET /users/me.
  void applyLocalSubscriptionPlan(String plan) {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = user.copyWith(subscriptionPlan: plan);
    _tokens.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> _applySession(Map<String, dynamic> data) async {
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await _tokens.saveTokens(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
    await _tokens.saveUser(user);
    _currentUser = user;
    _status = AuthStatus.signedIn;
    notifyListeners();
  }

  void _handleSessionExpired() {
    _tokens.clear();
    NotesRepository.instance.clearCache();
    _currentUser = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}
