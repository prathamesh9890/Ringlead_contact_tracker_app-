import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/call_log_repository.dart';
import '../theme.dart';
import '../widgets/call_log_status_banner.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => CallsScreenState();
}

class CallsScreenState extends State<CallsScreen> {
  int _filter = 0;
  String _query = '';
  final _repo = CallLogRepository.instance;

  static const _filterLabels = ['All', 'Incoming', 'Outgoing', 'Missed'];
  static const _filterValues = ['all', 'incoming', 'outgoing', 'missed'];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    if (_repo.status == CallLogStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void setFilterByValue(String value) {
    final i = _filterValues.indexOf(value);
    if (i != -1) setState(() => _filter = i);
  }

  @override
  Widget build(BuildContext context) {
    final allCalls = _repo.calls;
    final matches = allCalls.where((c) {
      final matchesType = _filter == 0 || c.type == _filterValues[_filter];
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty || c.name.toLowerCase().contains(q) || c.number.contains(q);
      return matchesType && matchesQuery;
    }).toList();

    final grouped = <String, List<CallEntry>>{};
    for (final c in matches) {
      grouped.putIfAbsent(c.day, () => []).add(c);
    }

    return RefreshIndicator(
      onRefresh: _repo.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Calls', style: AppText.screenTitle),
              if (_repo.lastSyncedLabel != null)
                Text(_repo.lastSyncedLabel!, style: AppText.tiny),
            ],
          ),
          const SizedBox(height: 16),
          SearchField(hint: 'Search name or number…', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 14),
          SegmentedTabs(labels: _filterLabels, selected: _filter, onSelect: (i) => setState(() => _filter = i)),
          const SizedBox(height: 16),
          if (_repo.status == CallLogStatus.loading && allCalls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue)),
            )
          else if (_repo.status == CallLogStatus.permissionDenied ||
              _repo.status == CallLogStatus.unsupported ||
              _repo.status == CallLogStatus.error)
            CallLogStatusBanner(status: _repo.status, errorMessage: _repo.errorMessage, onRetry: _repo.refresh)
          else if (matches.isEmpty)
            EmptyStateNote(
              icon: allCalls.isEmpty ? Icons.history_rounded : Icons.filter_alt_off_rounded,
              message: allCalls.isEmpty
                  ? 'No calls logged yet — make or receive a call and it will show up here.'
                  : 'No calls match this filter.',
            )
          else
            for (final day in grouped.keys) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(day.toUpperCase(), style: AppText.sectionLabel),
              ),
              ...grouped[day]!.map(
                (call) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CallRow(call: call),
                ),
              ),
              const SizedBox(height: 6),
            ],
        ],
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.call});

  final CallEntry call;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallDetailScreen(call: call))),
      child: Row(
        children: [
          Avatar(initials: call.initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(call.name, style: AppText.cardTitle, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(callTypeIcon(call.type), size: 12, color: callTypeColor(call.type)),
                    const SizedBox(width: 5),
                    Text(call.number, style: AppText.mono(12, color: AppColors.inkSoft)),
                  ],
                ),
                if (call.recorded) ...[
                  const SizedBox(height: 3),
                  const Row(
                    children: [
                      Icon(Icons.mic_rounded, size: 10, color: AppColors.blueInk),
                      SizedBox(width: 3),
                      Text('Recorded', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(call.time, style: AppText.mono(12, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(call.duration, style: AppText.mono(11, color: AppColors.inkFaint)),
            ],
          ),
        ],
      ),
    );
  }
}
