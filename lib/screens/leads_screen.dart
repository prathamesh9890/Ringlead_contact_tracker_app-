import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/call_log_repository.dart';
import '../services/notes_repository.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart' show CallDetailScreen, leadStatusColor, reminderLabel;

/// Shows every call the owner has tagged with a lead status, so follow-ups live
/// in one place instead of being buried in the full call log.
class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final _calls = CallLogRepository.instance;
  final _notes = NotesRepository.instance;
  final _reminders = ReminderService.instance;
  LeadStatus? _filter; // null = all leads

  static const _filters = [null, LeadStatus.newLead, LeadStatus.interested, LeadStatus.followup, LeadStatus.won, LeadStatus.lost];

  @override
  void initState() {
    super.initState();
    _notes.addListener(_onChanged);
    _calls.addListener(_onChanged);
    _reminders.addListener(_onChanged);
    _notes.load();
  }

  @override
  void dispose() {
    _notes.removeListener(_onChanged);
    _calls.removeListener(_onChanged);
    _reminders.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // One lead per call that has a status; newest first.
    final leads = _calls.calls.where((c) => _notes.hasStatus(c.timestamp)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final shown = _filter == null ? leads : leads.where((c) => _notes.statusFor(c.timestamp) == _filter).toList();

    return RefreshIndicator(
      onRefresh: () => _notes.load(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Leads', style: AppText.screenTitle),
              Text('${leads.length} tagged', style: AppText.tiny),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final active = f == _filter;
                final label = f == null ? 'All' : leadStatusLabel(f);
                final color = f == null ? AppColors.blue : leadStatusColor(f);
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: active
                        ? BoxDecoration(color: color, borderRadius: BorderRadius.circular(kRadiusPill))
                        : neuRaisedSm(radius: kRadiusPill),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.inkSoft),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (shown.isEmpty)
            EmptyStateNote(
              icon: Icons.flag_outlined,
              message: leads.isEmpty
                  ? 'No leads yet.\nOpen a call and set its status (Interested, Follow-up…) to track it here.'
                  : 'No leads with this status.',
            )
          else
            ...shown.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _LeadRow(call: c))),
        ],
      ),
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.call});

  final CallEntry call;

  @override
  Widget build(BuildContext context) {
    final status = NotesRepository.instance.statusFor(call.timestamp);
    final note = NotesRepository.instance.noteFor(call.timestamp);
    final reminder = ReminderService.instance.reminderFor(call.timestamp);

    return NeuCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallDetailScreen(call: call))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(initials: call.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(call.name, style: AppText.cardTitle, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${call.day} · ${call.time}', style: AppText.mono(12, color: AppColors.inkSoft)),
                  ],
                ),
              ),
              StatusPill(label: leadStatusLabel(status), color: leadStatusColor(status)),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 10),
            Text(note, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body),
          ],
          if (reminder != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.alarm_rounded, size: 13, color: AppColors.amberInk),
                const SizedBox(width: 5),
                Text(reminderLabel(reminder), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.amberInk)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
