import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/neu.dart';

class CallDetailScreen extends StatefulWidget {
  const CallDetailScreen({super.key, required this.call});

  final CallEntry call;

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final typeLabel = '${call.type[0].toUpperCase()}${call.type.substring(1)} call';
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
                      const SizedBox(height: 2),
                      Text(call.number, style: AppText.mono(13, color: AppColors.inkSoft)),
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
                              Text('22 Jul, ${call.time}', style: AppText.mono(15, weight: FontWeight.w700)),
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
                  if (call.recorded) ...[
                    const Text('RECORDING', style: AppText.sectionLabel),
                    const SizedBox(height: 10),
                    NeuCard(
                      child: AudioPlayerRow(durationSeconds: 200, durationLabel: call.duration.contains('m') ? call.duration : '0:00'),
                    ),
                    const SizedBox(height: 18),
                  ],
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('NOTES', style: AppText.sectionLabel),
                            Icon(Icons.edit_rounded, size: 15, color: AppColors.inkSoft),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Confirmed she'll be available for the site visit tomorrow at 11 AM. Asked for a written quote by email beforehand.",
                          style: AppText.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeuCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.call_rounded, size: 20, color: AppColors.blueInk),
                        SizedBox(width: 10),
                        Text('Call Back', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      ],
                    ),
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

class AudioPlayerRow extends StatefulWidget {
  const AudioPlayerRow({super.key, required this.durationSeconds, required this.durationLabel});

  final int durationSeconds;
  final String durationLabel;

  @override
  State<AudioPlayerRow> createState() => _AudioPlayerRowState();
}

class _AudioPlayerRowState extends State<AudioPlayerRow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: widget.durationSeconds))
      ..value = 0.14
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      if (_controller.value >= 1) _controller.value = 0;
      _controller.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final playing = _controller.isAnimating;
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
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 15,
              onPressed: _toggle,
              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.blueInk),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _controller.value,
                minHeight: 6,
                backgroundColor: AppColors.shDark.withAlpha(140),
                valueColor: const AlwaysStoppedAnimation(AppColors.blue),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(widget.durationLabel, textAlign: TextAlign.right, style: AppText.mono(11, color: AppColors.inkFaint)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.ios_share_rounded, size: 15, color: AppColors.inkSoft),
        ],
      ),
    );
  }
}
