import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import 'api_client.dart';

/// Per-call notes, stored on the server (GET/PUT/DELETE /notes) so they survive
/// a phone change and can be seen from the admin panel. Keyed by `callKey`,
/// which is the call's timestamp (millisecondsSinceEpoch) as a string.
class NotesRepository extends ChangeNotifier {
  NotesRepository._();
  static final NotesRepository instance = NotesRepository._();

  final _api = ApiClient.instance;

  final Map<String, String> _notesByCall = {};
  bool _loaded = false;

  /// The saved note for a call, or null if none. 0-timestamp (mock) calls never have one.
  String? noteFor(int timestamp) => timestamp == 0 ? null : _notesByCall['$timestamp'];

  bool hasNote(int timestamp) => (noteFor(timestamp) ?? '').isNotEmpty;

  /// Loads every note once per session; call again with [force] to refresh.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final list = await _api.getList('/notes');
      _notesByCall
        ..clear()
        ..addEntries(
          list.whereType<Map<String, dynamic>>().map(
            (n) => MapEntry('${n['callKey']}', (n['note'] as String?) ?? ''),
          ),
        );
      _loaded = true;
      notifyListeners();
    } on ApiException {
      // Offline or server asleep — keep whatever is cached; the UI still works.
    }
  }

  /// Saves (or, for an empty note, clears) the note for a call and updates the cache.
  Future<void> save(int timestamp, String note, {String number = '', String name = ''}) async {
    final key = '$timestamp';
    final trimmed = note.trim();
    await _api.put('/notes/$key', body: {'note': trimmed, 'number': number, 'name': name});
    if (trimmed.isEmpty) {
      _notesByCall.remove(key);
    } else {
      _notesByCall[key] = trimmed;
    }
    notifyListeners();
  }

  void clearCache() {
    _notesByCall.clear();
    _loaded = false;
  }
}
