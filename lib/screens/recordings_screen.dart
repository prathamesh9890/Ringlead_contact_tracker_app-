import 'package:flutter/material.dart';
import '../services/recording_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart' show AudioPlayerRow, formatSeconds;

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  String _query = '';
  final _repo = RecordingRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    // Only scans if access was granted before; the user asks for it via the button below.
    if (_repo.status == RecordingStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final all = _repo.recordings;
    final q = _query.trim().toLowerCase();
    final matches = all.where((r) {
      return q.isEmpty || r.title.toLowerCase().contains(q) || r.number.contains(q) || r.fileName.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => _repo.refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Recordings', style: AppText.screenTitle),
              if (_repo.status == RecordingStatus.loaded) Text('${all.length} found', style: AppText.tiny),
            ],
          ),
          const SizedBox(height: 16),
          SearchField(hint: 'Search recordings…', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 16),
          if (_repo.status == RecordingStatus.loading && all.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue)),
            )
          else if (_repo.status == RecordingStatus.permissionDenied)
            _PermissionCard(onAllow: () => _repo.refresh(requestPermission: true), onOpenSettings: _repo.openSettings)
          else if (_repo.status == RecordingStatus.unsupported)
            const EmptyStateNote(icon: Icons.phone_android_rounded, message: 'Call recordings are available on Android phones only.')
          else if (_repo.status == RecordingStatus.error)
            EmptyStateNote(icon: Icons.error_outline_rounded, message: "Couldn't read recordings.\n${_repo.errorMessage ?? ''}")
          else if (all.isEmpty)
            const _NoRecordingsHelp()
          else if (matches.isEmpty)
            const EmptyStateNote(icon: Icons.search_off_rounded, message: 'No recordings match your search.')
          else
            ...matches.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(initials: rec.initials),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rec.title, style: AppText.cardTitle, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  rec.number.isEmpty ? rec.whenLabel : '${rec.number} · ${rec.whenLabel}',
                                  style: AppText.mono(12, color: AppColors.inkSoft),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AudioPlayerRow(
                        key: ValueKey(rec.path),
                        path: rec.path,
                        durationHint: (rec.call?.durationSeconds ?? 0) > 0 ? formatSeconds(rec.call!.durationSeconds) : null,
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

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onAllow, required this.onOpenSettings});

  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Column(
        children: [
          const Icon(Icons.mic_rounded, size: 30, color: AppColors.blueInk),
          const SizedBox(height: 10),
          const Text('Show your call recordings', style: AppText.cardTitle),
          const SizedBox(height: 6),
          const Text(
            "Ringlead finds the recordings your phone's dialer saves and links each one to its call. "
            'Allow access to audio files to continue.',
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 16),
          NeuPrimaryButton(label: 'Allow access', onPressed: onAllow),
          TextButton(
            onPressed: onOpenSettings,
            child: const Text('Open app settings', style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _NoRecordingsHelp extends StatelessWidget {
  const _NoRecordingsHelp();

  @override
  Widget build(BuildContext context) {
    return const NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No call recordings found yet', style: AppText.cardTitle),
          SizedBox(height: 8),
          Text(
            "Android doesn't let apps record calls directly, so Ringlead uses the recordings your phone makes:\n\n"
            '1. Open your Phone app → Settings → Call recording.\n'
            '2. Turn on "Auto record calls" (all numbers).\n'
            '3. Make or receive a call, then pull down here to refresh.\n\n'
            "Recordings from the Google Phone app are kept private by Google and can't be shown here.",
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
