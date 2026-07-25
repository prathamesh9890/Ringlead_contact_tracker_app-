import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart' show AudioPlayerRow;

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = recordings.where((r) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty || r.name.toLowerCase().contains(q) || r.number.contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const Text('Recordings', style: AppText.screenTitle),
        const SizedBox(height: 16),
        SearchField(hint: 'Search recordings…', onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: 16),
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
                            Text(rec.name, style: AppText.cardTitle),
                            const SizedBox(height: 2),
                            Text('${rec.number} · ${rec.when}', style: AppText.mono(12, color: AppColors.inkSoft), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AudioPlayerRow(durationSeconds: rec.durationSeconds, durationLabel: rec.durationLabel),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
