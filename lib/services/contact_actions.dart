import 'package:url_launcher/url_launcher.dart';

/// Opens the dialer / WhatsApp for a phone number. Returns false if nothing
/// could handle it, so the UI can show a message.
class ContactActions {
  ContactActions._();

  /// Opens the phone dialer with [number] pre-filled (does not auto-call).
  static Future<bool> dial(String number) {
    final cleaned = _clean(number);
    if (cleaned.isEmpty) return Future.value(false);
    return _launch(Uri(scheme: 'tel', path: cleaned));
  }

  /// Opens WhatsApp chat for [number] with an optional pre-filled [message].
  /// Indian numbers without a country code get +91 so wa.me resolves them.
  static Future<bool> whatsApp(String number, {String message = ''}) {
    var digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return Future.value(false);
    if (digits.length == 10) digits = '91$digits';
    final uri = Uri.parse('https://wa.me/$digits${message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}'}');
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String _clean(String number) => number.replaceAll(RegExp(r'[^0-9+]'), '');
}
