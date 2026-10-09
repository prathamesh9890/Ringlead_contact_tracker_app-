import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/mock_data.dart';
import 'call_log_repository.dart';

enum RecordingStatus { idle, loading, loaded, permissionDenied, unsupported, error }

/// A call recording file saved by the phone's own dialer, optionally matched
/// to the [CallEntry] it belongs to.
class DeviceRecording {
  const DeviceRecording({
    required this.path,
    required this.fileName,
    required this.modifiedAt,
    this.call,
  });

  final String path;
  final String fileName;
  final DateTime modifiedAt;
  final CallEntry? call;

  String get title => call?.name ?? _stripExtension(fileName);
  String get number => call?.number ?? '';
  String get initials => call?.initials ?? '#';

  String get whenLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = modifiedAt;
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]}, $hour12:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  static String _stripExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}

/// Finds call recordings made by the phone's built-in dialer (Samsung, Xiaomi,
/// OnePlus, Realme, Vivo, Motorola…) and links each one to the call log entry
/// it was recorded during. Android blocks apps from recording call audio
/// themselves, so this reads the dialer's saved files instead. Android only.
class RecordingRepository extends ChangeNotifier {
  RecordingRepository._() {
    CallLogRepository.instance.addListener(_rematch);
  }
  static final RecordingRepository instance = RecordingRepository._();

  static const _storageRoot = '/storage/emulated/0';

  /// Folders where OEM dialers save call recordings. Each is scanned
  /// recursively and only audio files with "call" in their path are kept,
  /// which skips ordinary voice memos living in the same parent folders.
  static const _scanRoots = [
    'Recordings', // Samsung (Recordings/Call), Motorola, OnePlus
    'Music/Recordings', // Realme / Oppo (Call Recordings)
    'Record', // Vivo (Record/Call)
    'MIUI/sound_recorder', // Xiaomi (call_rec)
    'Sounds', // Huawei (CallRecord)
    'Call', // older Samsung
    'CallRecordings',
    'PhoneRecord',
  ];

  static const _audioExtensions = {'m4a', 'mp3', 'amr', 'aac', 'wav', '3gp', 'ogg', 'opus', 'awb'};

  List<_RecordingFile> _files = const [];
  List<DeviceRecording> _recordings = const [];
  Map<int, DeviceRecording> _byCallTimestamp = const {};
  RecordingStatus _status = RecordingStatus.idle;
  String? _errorMessage;

  List<DeviceRecording> get recordings => _recordings;
  RecordingStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// The recording made during [call], if one was found.
  DeviceRecording? recordingFor(CallEntry call) => call.timestamp == 0 ? null : _byCallTimestamp[call.timestamp];

  /// Rescans the recording folders. When [requestPermission] is false, this
  /// only proceeds if audio access was already granted, so opening the app
  /// never fires a surprise permission dialog.
  Future<void> refresh({bool requestPermission = false}) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _status = RecordingStatus.unsupported;
      notifyListeners();
      return;
    }

    _status = RecordingStatus.loading;
    notifyListeners();

    try {
      if (!await _hasPermission(request: requestPermission)) {
        _status = RecordingStatus.permissionDenied;
        notifyListeners();
        return;
      }
      _files = await _scan();
      _status = RecordingStatus.loaded;
      _rematch();
    } catch (e) {
      _status = RecordingStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> openSettings() => openAppSettings();

  /// Android 13+ grants audio files via READ_MEDIA_AUDIO ([Permission.audio]);
  /// older versions use READ_EXTERNAL_STORAGE ([Permission.storage]).
  Future<bool> _hasPermission({required bool request}) async {
    if (await Permission.audio.isGranted || await Permission.storage.isGranted) return true;
    if (!request) return false;
    if ((await Permission.audio.request()).isGranted) return true;
    return (await Permission.storage.request()).isGranted;
  }

  Future<List<_RecordingFile>> _scan() async {
    final found = <String, _RecordingFile>{};
    for (final root in _scanRoots) {
      final dir = Directory('$_storageRoot/$root');
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          final lower = entity.path.toLowerCase();
          final dot = lower.lastIndexOf('.');
          if (dot == -1 || !_audioExtensions.contains(lower.substring(dot + 1))) continue;
          if (!lower.contains('call') && !lower.contains('phonerecord')) continue;
          final stat = await entity.stat();
          if (stat.size == 0) continue;
          found[entity.path] = _RecordingFile(entity.path, stat.modified);
        }
      } on FileSystemException {
        // An unreadable sub-folder shouldn't hide recordings found elsewhere.
      }
    }
    return found.values.toList()..sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
  }

  void _rematch() {
    if (_status != RecordingStatus.loaded) return;
    final calls = CallLogRepository.instance.calls.where((c) => c.type != 'missed' && c.timestamp > 0).toList();

    final byCall = <int, DeviceRecording>{};
    final recordings = <DeviceRecording>[];
    for (final file in _files) {
      final fileName = file.path.substring(file.path.lastIndexOf('/') + 1);
      final call = _matchCall(fileName, file.modifiedAt, calls, byCall);
      final recording = DeviceRecording(path: file.path, fileName: fileName, modifiedAt: file.modifiedAt, call: call);
      if (call != null) byCall[call.timestamp] = recording;
      recordings.add(recording);
    }

    _recordings = recordings.reversed.toList();
    _byCallTimestamp = byCall;
    notifyListeners();
  }

  /// A dialer finishes writing the file when the call ends, so the file's
  /// modified time should fall between the call's start and a few minutes
  /// after its end. A phone number in the file name breaks ties, and also
  /// rescues files whose timestamp shifted (e.g. after being copied).
  CallEntry? _matchCall(String fileName, DateTime modifiedAt, List<CallEntry> calls, Map<int, DeviceRecording> taken) {
    final fileDigits = fileName.replaceAll(RegExp(r'\D'), '');
    final t = modifiedAt.millisecondsSinceEpoch;

    CallEntry? best;
    var bestRank = (2, 1 << 62);
    for (final call in calls) {
      if (taken.containsKey(call.timestamp)) continue;
      final end = call.timestamp + call.durationSeconds * 1000;
      final inWindow = t >= call.timestamp - 60 * 1000 && t <= end + 3 * 60 * 1000;
      final numberMatch = _numberInDigits(call.number, fileDigits);
      final distance = (t - end).abs();

      // Lower rank wins: in-window + number, then in-window, then number within 12h.
      final int tier;
      if (inWindow) {
        tier = numberMatch ? 0 : 1;
      } else if (numberMatch && distance <= 12 * 60 * 60 * 1000) {
        tier = 2;
      } else {
        continue;
      }
      if (tier < bestRank.$1 || (tier == bestRank.$1 && distance < bestRank.$2)) {
        best = call;
        bestRank = (tier, distance);
      }
    }
    return best;
  }

  bool _numberInDigits(String number, String fileDigits) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return false;
    final key = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    return fileDigits.contains(key);
  }
}

class _RecordingFile {
  const _RecordingFile(this.path, this.modifiedAt);

  final String path;
  final DateTime modifiedAt;
}
