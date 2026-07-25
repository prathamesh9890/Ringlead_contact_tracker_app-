import 'package:call_log/call_log.dart' as device;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';

enum CallLogStatus { idle, loading, loaded, permissionDenied, unsupported, error }

/// Reads the device's real call log (Android only) and exposes it as [CallEntry]s
/// so Home/Calls/Call Details render actual phone activity instead of mock data.
class CallLogRepository extends ChangeNotifier {
  CallLogRepository._();
  static final CallLogRepository instance = CallLogRepository._();

  List<CallEntry> _calls = const [];
  CallLogStatus _status = CallLogStatus.idle;
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  List<CallEntry> get calls => _calls;
  CallLogStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CallLogStatus.loading;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Friendly relative label like "Synced just now" / "Synced 5 min ago", or null before the first sync.
  String? get lastSyncedLabel {
    final syncedAt = _lastSyncedAt;
    if (syncedAt == null) return null;
    final minutes = DateTime.now().difference(syncedAt).inMinutes;
    if (minutes < 1) return 'Synced just now';
    if (minutes == 1) return 'Synced 1 min ago';
    if (minutes < 60) return 'Synced $minutes min ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return 'Synced ${hours}h ago';
    return 'Synced ${hours ~/ 24}d ago';
  }

  Future<void> refresh() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _status = CallLogStatus.unsupported;
      notifyListeners();
      return;
    }

    _status = CallLogStatus.loading;
    notifyListeners();

    try {
      final entries = await device.CallLog.get();
      final mapped = entries.map(_toCallEntry).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _calls = mapped;
      _status = CallLogStatus.loaded;
      _lastSyncedAt = DateTime.now();
    } on PlatformException catch (e) {
      _status = (e.code == 'PERMISSION_NOT_GRANTED' || e.code == 'MISSING_PERMISSIONS')
          ? CallLogStatus.permissionDenied
          : CallLogStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = CallLogStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  CallEntry _toCallEntry(device.CallLogEntry e) {
    final timestamp = e.timestamp ?? 0;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final rawName = e.name?.trim();
    final hasContactName = rawName != null && rawName.isNotEmpty;
    final displayName = hasContactName ? rawName : (e.formattedNumber ?? e.number ?? 'Unknown');

    return CallEntry(
      initials: _initialsFor(hasContactName ? rawName : null),
      name: displayName,
      number: e.formattedNumber ?? e.number ?? '',
      type: _typeFor(e.callType),
      time: _formatTime(dateTime),
      duration: _formatDuration(e.duration),
      recorded: false,
      day: _dayLabelFor(dateTime),
      timestamp: timestamp,
    );
  }

  String _initialsFor(String? name) {
    if (name == null || name.isEmpty) return '#';
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    return letters.isEmpty ? '#' : letters;
  }

  String _typeFor(device.CallType? type) {
    switch (type) {
      case device.CallType.incoming:
      case device.CallType.wifiIncoming:
      case device.CallType.answeredExternally:
        return 'incoming';
      case device.CallType.outgoing:
      case device.CallType.wifiOutgoing:
        return 'outgoing';
      case device.CallType.missed:
      case device.CallType.rejected:
      case device.CallType.blocked:
      case device.CallType.voiceMail:
        return 'missed';
      default:
        return 'incoming';
    }
  }

  String _formatTime(DateTime dt) {
    final hour24 = dt.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '—';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes == 0) return '${secs}s';
    return '${minutes}m ${secs.toString().padLeft(2, '0')}s';
  }

  String _dayLabelFor(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
