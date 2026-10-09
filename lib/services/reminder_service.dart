import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Callback reminders: a local notification scheduled for a call, so the owner
/// is nudged to ring a lead back. Reminders live on the device only. The
/// scheduled time per call is cached (SharedPreferences) so the UI can show it.
class ReminderService extends ChangeNotifier {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _channelId = 'ringlead_callbacks';
  static const _prefsKey = 'ringlead_reminders';

  final _plugin = FlutterLocalNotificationsPlugin();
  final Map<String, DateTime> _byCall = {}; // callKey -> when
  bool _ready = false;

  /// callKey -> scheduled time (future reminders only, after prune).
  DateTime? reminderFor(int timestamp) {
    final when = _byCall['$timestamp'];
    if (when == null) return null;
    return when.isAfter(DateTime.now()) ? when : null;
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      final localName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to a sensible default if the device name can't be read.
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {}
    }

    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          'Callback reminders',
          description: 'Reminders to call a lead back',
          importance: Importance.high,
        ));

    await _loadCache();
    _ready = true;
    notifyListeners();
  }

  /// Asks for notification permission (Android 13+). Returns true if granted.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Schedules (or replaces) a reminder for a call. [timestamp] is the call's
  /// key; [title]/[body] show in the notification.
  Future<void> schedule({
    required int timestamp,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await init();
    final id = _idFor(timestamp);
    final scheduled = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Callback reminders',
          channelDescription: 'Reminders to call a lead back',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '$timestamp',
    );

    _byCall['$timestamp'] = when;
    await _saveCache();
    notifyListeners();
  }

  Future<void> cancel(int timestamp) async {
    await init();
    await _plugin.cancel(id: _idFor(timestamp));
    _byCall.remove('$timestamp');
    await _saveCache();
    notifyListeners();
  }

  // Notification ids are 31-bit; fold the ms timestamp down into that range.
  int _idFor(int timestamp) => timestamp % 2000000000;

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _byCall
        ..clear()
        ..addEntries(map.entries.map((e) => MapEntry(e.key, DateTime.fromMillisecondsSinceEpoch(e.value as int))));
      // Drop reminders that already fired.
      _byCall.removeWhere((_, when) => when.isBefore(DateTime.now()));
    } catch (_) {}
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _byCall.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch));
      await prefs.setString(_prefsKey, jsonEncode(map));
    } catch (_) {}
  }
}
