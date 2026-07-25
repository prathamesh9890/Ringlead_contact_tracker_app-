import 'package:flutter/material.dart';
import '../services/call_log_repository.dart';
import '../theme.dart';
import 'neu.dart';

/// Shown in place of the call list when the device call log isn't readable yet —
/// permission not granted, platform doesn't support it (iOS/desktop), or a fetch error.
class CallLogStatusBanner extends StatelessWidget {
  const CallLogStatusBanner({super.key, required this.status, required this.onRetry, this.errorMessage});

  final CallLogStatus status;
  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String body;
    bool showRetry = true;
    String retryLabel = 'Grant Access';

    switch (status) {
      case CallLogStatus.permissionDenied:
        icon = Icons.lock_outline_rounded;
        color = AppColors.amberInk;
        title = 'Call log access needed';
        body = 'Ringlead reads your call history to log calls automatically. Grant access to continue.';
      case CallLogStatus.unsupported:
        icon = Icons.info_outline_rounded;
        color = AppColors.inkSoft;
        title = 'Not available on this device';
        body = 'Automatic call logging only works on Android — the OS blocks this on iOS entirely.';
        showRetry = false;
      case CallLogStatus.error:
        icon = Icons.error_outline_rounded;
        color = AppColors.redInk;
        title = "Couldn't load calls";
        body = errorMessage ?? 'Something went wrong while reading the call log.';
        retryLabel = 'Retry';
      default:
        icon = Icons.info_outline_rounded;
        color = AppColors.inkSoft;
        title = 'No data yet';
        body = '';
    }

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: neuRaisedSm(radius: 22),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(body, textAlign: TextAlign.center, style: AppText.caption),
          ],
          if (showRetry) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: NeuPrimaryButton(label: retryLabel, onPressed: onRetry),
            ),
          ],
        ],
      ),
    );
  }
}
