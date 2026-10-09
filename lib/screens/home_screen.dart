import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../services/call_log_repository.dart';
import '../theme.dart';
import '../widgets/call_log_status_banner.dart';
import '../widgets/neu.dart';
import 'app_shell.dart';
import 'call_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = CallLogRepository.instance;
  final _auth = AuthRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _auth.addListener(_onRepoChanged);
    if (_repo.status == CallLogStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _auth.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  ({String greeting, String date}) _greetingAndDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final greeting = now.hour < 12 ? 'Good morning' : (now.hour < 17 ? 'Good afternoon' : 'Good evening');
    final date = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
    return (greeting: greeting, date: date);
  }

  @override
  Widget build(BuildContext context) {
    final greetingAndDate = _greetingAndDate();
    final calls = _repo.calls;
    final hasData = _repo.status == CallLogStatus.loaded;
    final todaysCalls = hasData ? calls.where((c) => c.day == 'Today').length : null;
    final missedToday = hasData ? calls.where((c) => c.day == 'Today' && c.type == 'missed').length : null;
    final incomingToday = hasData ? calls.where((c) => c.day == 'Today' && c.type == 'incoming').length : null;
    final outgoingToday = hasData ? calls.where((c) => c.day == 'Today' && c.type == 'outgoing').length : null;
    final recent = calls.take(3).toList();
    final needsStatusBanner = _repo.status == CallLogStatus.permissionDenied ||
        _repo.status == CallLogStatus.unsupported ||
        _repo.status == CallLogStatus.error;

    return RefreshIndicator(
      onRefresh: _repo.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetingAndDate.greeting.toUpperCase(), style: AppText.greeting),
                    const SizedBox(height: 2),
                    Text(_auth.currentUser?.businessName ?? '', style: AppText.h1),
                    const SizedBox(height: 2),
                    Text(greetingAndDate.date, style: AppText.caption),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  NeuCircleIcon(
                    icon: Icons.notifications_rounded,
                    color: AppColors.inkSoft,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications yet.')),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SearchField(
            hint: 'Search customers, numbers…',
            readOnly: true,
            onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.call_rounded,
                  color: AppColors.violetInk,
                  value: todaysCalls?.toString() ?? '—',
                  label: "Today's calls",
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatTile(
                  icon: Icons.call_missed_rounded,
                  color: AppColors.redInk,
                  value: missedToday?.toString() ?? '—',
                  label: 'Missed calls',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('missed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.call_received_rounded,
                  color: AppColors.greenInk,
                  value: incomingToday?.toString() ?? '—',
                  label: 'Incoming',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('incoming'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatTile(
                  icon: Icons.call_made_rounded,
                  color: AppColors.blueInk,
                  value: outgoingToday?.toString() ?? '—',
                  label: 'Outgoing',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('outgoing'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.call_rounded,
                  color: AppColors.greenInk,
                  label: 'Log Call',
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.folder_rounded,
                  color: AppColors.blueInk,
                  label: 'Recordings',
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(3),
                ),
              ),
              const Expanded(
                child: _QuickAction(icon: Icons.campaign_rounded, color: AppColors.amberInk, label: 'WhatsApp Blast'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT CALLS', style: AppText.sectionLabel),
              GestureDetector(
                onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
                child: const Text('See all', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_repo.status == CallLogStatus.loading && calls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue)),
            )
          else if (needsStatusBanner)
            CallLogStatusBanner(status: _repo.status, errorMessage: _repo.errorMessage, onRetry: _repo.refresh)
          else if (recent.isEmpty)
            const EmptyStateNote(
              icon: Icons.history_rounded,
              message: 'No calls logged yet — make or receive a call and it will show up here.',
            )
          else
            ...recent.map(
              (call) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeuCard(
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
                                Expanded(
                                  child: Text(
                                    '${call.type[0].toUpperCase()}${call.type.substring(1)} · ${call.number}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                                  ),
                                ),
                              ],
                            ),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.color, required this.value, required this.label, this.onTap});

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: neuRaisedSm(radius: 11),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppText.statNum),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.color, required this.label, this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            NeuCircleIcon(icon: icon, color: color, size: 46, iconSize: 19),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
