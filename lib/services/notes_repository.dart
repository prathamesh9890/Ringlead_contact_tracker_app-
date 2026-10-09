import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import 'api_client.dart';

/// Lead statuses a call can be tagged with. 'none' means untagged.
enum LeadStatus { none, newLead, interested, followup, won, lost }

/// Wire value <-> enum. The backend stores 'new' (our `newLead`).
String leadStatusToApi(LeadStatus s) => switch (s) {
      LeadStatus.none => 'none',
      LeadStatus.newLead => 'new',
      LeadStatus.interested => 'interested',
      LeadStatus.followup => 'followup',
      LeadStatus.won => 'won',
      LeadStatus.lost => 'lost',
    };

LeadStatus leadStatusFromApi(String? s) => switch (s) {
      'new' => LeadStatus.newLead,
      'interested' => LeadStatus.interested,
      'followup' => LeadStatus.followup,
      'won' => LeadStatus.won,
      'lost' => LeadStatus.lost,
      _ => LeadStatus.none,
    };

String leadStatusLabel(LeadStatus s) => switch (s) {
      LeadStatus.none => 'No status',
      LeadStatus.newLead => 'New',
      LeadStatus.interested => 'Interested',
      LeadStatus.followup => 'Follow-up',
      LeadStatus.won => 'Won',
      LeadStatus.lost => 'Lost',
    };

/// The note + lead status saved for one call.
class CallMeta {
  const CallMeta({this.note = '', this.status = LeadStatus.none});

  final String note;
  final LeadStatus status;

  bool get isEmpty => note.isEmpty && status == LeadStatus.none;
}

/// Per-call notes and lead status, stored on the server (GET/PUT/DELETE /notes)
/// so they survive a phone change and show in the admin panel. Keyed by
/// `callKey` — the call's timestamp (millisecondsSinceEpoch) as a string.
class NotesRepository extends ChangeNotifier {
  NotesRepository._();
  static final NotesRepository instance = NotesRepository._();

  final _api = ApiClient.instance;

  final Map<String, CallMeta> _byCall = {};
  bool _loaded = false;

  CallMeta metaFor(int timestamp) => timestamp == 0 ? const CallMeta() : (_byCall['$timestamp'] ?? const CallMeta());

  String? noteFor(int timestamp) {
    final n = metaFor(timestamp).note;
    return n.isEmpty ? null : n;
  }

  LeadStatus statusFor(int timestamp) => metaFor(timestamp).status;

  bool hasNote(int timestamp) => metaFor(timestamp).note.isNotEmpty;

  bool hasStatus(int timestamp) => metaFor(timestamp).status != LeadStatus.none;

  /// Loads every record once per session; call again with [force] to refresh.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final list = await _api.getList('/notes');
      _byCall
        ..clear()
        ..addEntries(
          list.whereType<Map<String, dynamic>>().map(
                (n) => MapEntry(
                  '${n['callKey']}',
                  CallMeta(note: (n['note'] as String?) ?? '', status: leadStatusFromApi(n['status'] as String?)),
                ),
              ),
        );
      _loaded = true;
      notifyListeners();
    } on ApiException {
      // Offline or server asleep — keep whatever is cached; the UI still works.
    }
  }

  /// Saves the note and/or status for a call. Clearing both removes the record.
  Future<void> save(
    int timestamp, {
    required String note,
    required LeadStatus status,
    String number = '',
    String name = '',
  }) async {
    final key = '$timestamp';
    final trimmed = note.trim();
    await _api.put('/notes/$key', body: {
      'note': trimmed,
      'status': leadStatusToApi(status),
      'number': number,
      'name': name,
    });
    final meta = CallMeta(note: trimmed, status: status);
    if (meta.isEmpty) {
      _byCall.remove(key);
    } else {
      _byCall[key] = meta;
    }
    notifyListeners();
  }

  void clearCache() {
    _byCall.clear();
    _loaded = false;
  }
}
