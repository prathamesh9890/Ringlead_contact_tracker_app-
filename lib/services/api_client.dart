import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_exception.dart';
import 'token_storage.dart';

/// Thin wrapper around [http.Client] that talks to the Ringlead backend:
/// attaches the bearer token, unwraps the `{success, message, data}` envelope,
/// and transparently refreshes + retries once on a 401.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();
  final _tokens = TokenStorage.instance;

  /// Called when a request fails with 401 and refreshing the session also
  /// fails — the app should treat this as a hard logout. Set by AuthRepository.
  void Function()? onSessionExpired;

  Future<String>? _refreshing;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    return _asMap(await _request('GET', path, query: query));
  }

  /// For endpoints whose `data` is a JSON array (e.g. GET /notes).
  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    final data = await _request('GET', path, query: query);
    return (data as List<dynamic>?) ?? <dynamic>[];
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    return _asMap(await _request('POST', path, body: body, auth: auth));
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    return _asMap(await _request('PATCH', path, body: body));
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    return _asMap(await _request('PUT', path, body: body));
  }

  Map<String, dynamic> _asMap(dynamic data) => (data as Map<String, dynamic>?) ?? <String, dynamic>{};

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool auth = true,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );

    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final accessToken = await _tokens.readAccessToken();
      if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _send(method, uri, headers, body);

    if (response.statusCode == 401 && auth && !isRetry) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        return _request(method, path, query: query, body: body, auth: auth, isRetry: true);
      }
      onSessionExpired?.call();
      throw SessionExpiredException();
    }

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final errors = decoded['errors'] as List<dynamic>?;
      final firstFieldError = (errors != null && errors.isNotEmpty) ? errors.first['message'] as String? : null;
      throw ApiException(
        firstFieldError ?? decoded['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    return decoded['data'];
  }

  Future<http.Response> _send(String method, Uri uri, Map<String, String> headers, Map<String, dynamic>? body) {
    final encodedBody = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _client.put(uri, headers: headers, body: encodedBody);
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  /// Ensures concurrent 401s only trigger a single refresh call.
  Future<bool> _refreshSession() {
    return (_refreshing ??= _doRefresh().whenComplete(() => _refreshing = null)).then((_) => true).catchError((_) {
      return false;
    });
  }

  Future<String> _doRefresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) {
      throw SessionExpiredException();
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode >= 400) {
      await _tokens.clear();
      throw SessionExpiredException();
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    await _tokens.saveTokens(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
    return data['accessToken'] as String;
  }
}
