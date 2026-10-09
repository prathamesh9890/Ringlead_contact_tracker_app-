import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/mock_data.dart';
import '../models/api_exception.dart';
import '../services/contact_actions.dart';
import '../services/notes_repository.dart';
import '../services/recording_repository.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import '../widgets/neu.dart';

class CallDetailScreen extends StatefulWidget {
  const CallDetailScreen({super.key, required this.call});

  final CallEntry call;

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  final _recordings = RecordingRepository.instance;
  final _notes = NotesRepository.instance;
  final _reminders = ReminderService.instance;
  bool _savingNote = false;

  @override
  void initState() {
    super.initState();
    _recordings.addListener(_onRepoChanged);
    _notes.addListener(_onRepoChanged);
    _reminders.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _recordings.removeListener(_onRepoChanged);
    _notes.removeListener(_onRepoChanged);
    _reminders.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _editNote() async {
    final call = widget.call;
    final controller = TextEditingController(text: _notes.noteFor(call.timestamp) ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteSheet(controller: controller),
    );
    if (saved != true || !mounted) return;
    await _save(note: controller.text, status: _notes.statusFor(call.timestamp));
  }

  Future<void> _setStatus(LeadStatus status) async {
    final call = widget.call;
    // Tapping the current status again clears it.
    final next = _notes.statusFor(call.timestamp) == status ? LeadStatus.none : status;
    await _save(note: _notes.noteFor(call.timestamp) ?? '', status: next);
  }

  Future<void> _save({required String note, required LeadStatus status}) async {
    final call = widget.call;
    setState(() => _savingNote = true);
    try {
      await _notes.save(call.timestamp, note: note, status: status, number: call.number, name: call.name);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save — check your connection.')));
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  Future<void> _setReminder() async {
    final call = widget.call;
    final now = DateTime.now();
    final choice = await showModalBottomSheet<DateTime?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ReminderSheet(
        hasExisting: _reminders.reminderFor(call.timestamp) != null,
        onPick: (value) => Navigator.of(sheetContext).pop(value),
      ),
    );
    if (choice == null || !mounted) return;

    // _ReminderSheet returns epoch 0 to mean "remove".
    if (choice.millisecondsSinceEpoch == 0) {
      await _reminders.cancel(call.timestamp);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder removed')));
      }
      return;
    }

    DateTime when = choice;
    if (when == _customMarker) {
      final picked = await _pickCustom(now);
      if (picked == null || !mounted) return;
      when = picked;
    }
    if (when.isBefore(now)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a time in the future.')));
      return;
    }

    final granted = await _reminders.requestPermission();
    if (!granted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Allow notifications to get reminders.')));
      return;
    }
    await _reminders.schedule(
      timestamp: call.timestamp,
      when: when,
      title: 'Call back ${call.name}',
      body: call.number.isEmpty ? 'Follow up on this lead' : 'Ring ${call.number} back',
    );
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder set for ${reminderLabel(when)}')));
    }
  }

  Future<DateTime?> _pickCustom(DateTime now) async {
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _dial() async {
    final ok = await ContactActions.dial(widget.call.number);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone app found to dial this number.')));
    }
  }

  Future<void> _whatsApp() async {
    final ok = await ContactActions.whatsApp(widget.call.number, message: 'Hi! Sorry we missed your call. How can we help you?');
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed, or the number is invalid.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final typeLabel = '${call.type[0].toUpperCase()}${call.type.substring(1)} call';
    final recording = _recordings.recordingFor(call);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeuCircleIcon(icon: Icons.arrow_back_ios_new_rounded, color: AppColors.inkSoft, size: 38, iconSize: 15, onTap: () => Navigator.of(context).pop()),
                  const NeuCircleIcon(icon: Icons.more_horiz_rounded, color: AppColors.inkSoft, size: 38),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Column(
                    children: [
                      Avatar(initials: call.initials, size: 76, fontSize: 24),
                      const SizedBox(height: 10),
                      Text(call.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      if (call.number.isNotEmpty && call.number != call.name) ...[
                        const SizedBox(height: 2),
                        Text(call.number, style: AppText.mono(13, color: AppColors.inkSoft)),
                      ],
                      const SizedBox(height: 10),
                      StatusPill(label: typeLabel, color: callTypeColor(call.type)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: NeuCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DATE & TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.inkFaint)),
                              const SizedBox(height: 6),
                              Text('${call.day}, ${call.time}', style: AppText.mono(15, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: NeuCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DURATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.inkFaint)),
                              const SizedBox(height: 6),
                              Text(call.duration, style: AppText.mono(15, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (call.timestamp != 0) ...[
                    const Text('LEAD STATUS', style: AppText.sectionLabel),
                    const SizedBox(height: 10),
                    _LeadStatusChips(
                      selected: _notes.statusFor(call.timestamp),
                      onSelect: _savingNote ? null : _setStatus,
                    ),
                    const SizedBox(height: 18),
                    Builder(
                      builder: (context) {
                        final when = _reminders.reminderFor(call.timestamp);
                        return NeuCard(
                          onTap: _setReminder,
                          child: Row(
                            children: [
                              Icon(when != null ? Icons.alarm_on_rounded : Icons.alarm_add_rounded, size: 20, color: AppColors.amberInk),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(when != null ? 'Callback reminder' : 'Set callback reminder', style: AppText.cardTitle),
                                    const SizedBox(height: 2),
                                    Text(
                                      when != null ? reminderLabel(when) : 'Get a nudge to call this lead back',
                                      style: AppText.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(when != null ? Icons.edit_rounded : Icons.add_rounded, size: 16, color: AppColors.amberInk),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (recording != null) ...[
                    const Text('RECORDING', style: AppText.sectionLabel),
                    const SizedBox(height: 10),
                    NeuCard(
                      child: AudioPlayerRow(path: recording.path, durationHint: call.durationSeconds > 0 ? formatSeconds(call.durationSeconds) : null),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Builder(
                    builder: (context) {
                      final note = _notes.noteFor(call.timestamp);
                      final hasNote = (note ?? '').isNotEmpty;
                      return NeuCard(
                        onTap: call.timestamp == 0 ? null : _editNote,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('NOTES', style: AppText.sectionLabel),
                                if (_savingNote)
                                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue))
                                else
                                  Icon(hasNote ? Icons.edit_rounded : Icons.add_rounded, size: 16, color: AppColors.blueInk),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasNote ? note! : 'Tap to add a note for this call.',
                              style: hasNote ? AppText.body : AppText.caption,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  if (call.number.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: NeuCard(
                            onTap: _dial,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call_rounded, size: 20, color: AppColors.greenInk),
                                SizedBox(width: 10),
                                Text('Call Back', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: NeuCard(
                            onTap: _whatsApp,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_rounded, size: 20, color: AppColors.greenInk),
                                SizedBox(width: 10),
                                Text('WhatsApp', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plays a local audio file with play/pause, a tap-to-seek progress bar and
/// elapsed/total time. Only one row plays at a time across the app.
class AudioPlayerRow extends StatefulWidget {
  const AudioPlayerRow({super.key, required this.path, this.durationHint});

  final String path;

  /// Shown until the file is opened on first play, e.g. the call's duration.
  final String? durationHint;

  @override
  State<AudioPlayerRow> createState() => _AudioPlayerRowState();
}

class _AudioPlayerRowState extends State<AudioPlayerRow> {
  static _AudioPlayerRowState? _active;

  AudioPlayer? _player;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _playing = false;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _player?.dispose();
    if (_active == this) _active = null;
    super.dispose();
  }

  /// Players are created on first tap so long lists don't open dozens of files.
  Future<AudioPlayer> _ensurePlayer() async {
    final existing = _player;
    if (existing != null) return existing;
    final player = AudioPlayer();
    _player = player;
    _subscriptions
      ..add(player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      }))
      ..add(player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.pause();
          player.seek(Duration.zero);
        }
        if (mounted) setState(() => _playing = state.playing && state.processingState != ProcessingState.completed);
      }));
    _duration = await player.setFilePath(widget.path);
    return player;
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player?.pause();
      return;
    }
    setState(() => _loading = true);
    try {
      final player = await _ensurePlayer();
      if (_active != this) {
        await _active?._player?.pause();
        _active = this;
      }
      if (mounted) setState(() => _loading = false);
      unawaited(player.play());
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _seekTo(double fraction) {
    final duration = _duration;
    if (_player == null || duration == null) return;
    _player!.seek(duration * fraction.clamp(0.0, 1.0));
  }

  String _format(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final duration = _duration;
    final progress = (duration == null || duration.inMilliseconds == 0)
        ? 0.0
        : (_position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    final label = duration == null
        ? (widget.durationHint ?? '--:--')
        : (_playing || _position > Duration.zero) ? _format(_position) : _format(duration);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: neuPressed(radius: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: neuRaisedSm(radius: 18),
            child: _loading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue))
                : IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 15,
                    onPressed: _failed ? null : _toggle,
                    icon: Icon(
                      _failed ? Icons.error_outline_rounded : (_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      color: _failed ? AppColors.inkFaint : AppColors.blueInk,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _failed
                ? const Text("Can't play this file", style: AppText.caption)
                : LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _seekTo(d.localPosition.dx / constraints.maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.shDark.withAlpha(140),
                            valueColor: const AlwaysStoppedAnimation(AppColors.blue),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(label, textAlign: TextAlign.right, style: AppText.mono(11, color: AppColors.inkFaint)),
          ),
        ],
      ),
    );
  }
}

/// m:ss, e.g. 252 -> 4:12.
String formatSeconds(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Bottom sheet for writing/editing a call's note. Returns true if the user
/// tapped Save (an empty field clears the note on the server).
class _NoteSheet extends StatelessWidget {
  const _NoteSheet({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Call note', style: AppText.screenTitle),
            const SizedBox(height: 6),
            const Text('Saved to your account — visible on any device and in the admin panel.', style: AppText.caption),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: neuPressed(),
              child: TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. Wants 2BHK, budget 50L. Call back tomorrow 11 AM.',
                  hintStyle: TextStyle(color: AppColors.inkFaint),
                ),
              ),
            ),
            const SizedBox(height: 8),
            NeuPrimaryButton(label: 'Save note', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );
  }
}

/// Brand colour for each lead status, used for chips and list badges.
Color leadStatusColor(LeadStatus s) => switch (s) {
      LeadStatus.none => AppColors.inkFaint,
      LeadStatus.newLead => AppColors.blueInk,
      LeadStatus.interested => AppColors.violetInk,
      LeadStatus.followup => AppColors.amberInk,
      LeadStatus.won => AppColors.greenInk,
      LeadStatus.lost => AppColors.redInk,
    };

/// Row of tappable chips for picking a call's lead status. Tapping the selected
/// one again clears it (handled by the parent).
class _LeadStatusChips extends StatelessWidget {
  const _LeadStatusChips({required this.selected, required this.onSelect});

  final LeadStatus selected;
  final ValueChanged<LeadStatus>? onSelect;

  static const _options = [
    LeadStatus.newLead,
    LeadStatus.interested,
    LeadStatus.followup,
    LeadStatus.won,
    LeadStatus.lost,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((s) {
        final active = s == selected;
        final color = leadStatusColor(s);
        return GestureDetector(
          onTap: onSelect == null ? null : () => onSelect!(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: active
                ? BoxDecoration(color: color, borderRadius: BorderRadius.circular(kRadiusPill))
                : neuRaisedSm(radius: kRadiusPill),
            child: Text(
              leadStatusLabel(s),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Sentinel returned by the reminder sheet to mean "let me pick a date & time".
final DateTime _customMarker = DateTime.fromMillisecondsSinceEpoch(1);

String reminderLabel(DateTime when) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final period = when.hour >= 12 ? 'PM' : 'AM';
  final time = '$h:${when.minute.toString().padLeft(2, '0')} $period';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Tomorrow, $time';
  return '${when.day} ${months[when.month - 1]}, $time';
}

/// Quick reminder options. Returns the chosen DateTime, `_customMarker` for a
/// custom pick, epoch-0 to remove an existing reminder, or null on cancel.
class _ReminderSheet extends StatelessWidget {
  const _ReminderSheet({required this.hasExisting, required this.onPick});

  final bool hasExisting;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final evening = DateTime(now.year, now.month, now.day, 18);
    final tomorrow10 = DateTime(now.year, now.month, now.day).add(const Duration(days: 1, hours: 10));

    final options = <(String, IconData, DateTime)>[
      ('In 1 hour', Icons.timelapse_rounded, now.add(const Duration(hours: 1))),
      ('In 3 hours', Icons.timelapse_rounded, now.add(const Duration(hours: 3))),
      if (evening.isAfter(now.add(const Duration(minutes: 30)))) ('This evening, 6 PM', Icons.wb_twilight_rounded, evening),
      ('Tomorrow, 10 AM', Icons.wb_sunny_rounded, tomorrow10),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Remind me to call back', style: AppText.screenTitle),
          const SizedBox(height: 16),
          ...options.map((o) => _row(o.$1, o.$2, () => onPick(o.$3))),
          _row('Pick date & time', Icons.event_rounded, () => onPick(_customMarker)),
          if (hasExisting) _row('Remove reminder', Icons.delete_outline_rounded, () => onPick(DateTime.fromMillisecondsSinceEpoch(0)), danger: true),
        ],
      ),
    );
  }

  Widget _row(String label, IconData icon, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppColors.redInk : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeuCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 19, color: danger ? AppColors.redInk : AppColors.amberInk),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
