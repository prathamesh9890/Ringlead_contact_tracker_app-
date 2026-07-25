/// Thrown for any non-2xx API response. [message] is already the best
/// human-readable string available (first validation error, or the server's
/// top-level message).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thrown when a request needed a valid session but the refresh token was
/// missing, expired, or revoked. Callers should route to the login screen.
class SessionExpiredException extends ApiException {
  SessionExpiredException() : super('Your session has expired. Please sign in again.', statusCode: 401);
}
