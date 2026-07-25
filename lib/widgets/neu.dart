import 'package:flutter/material.dart';
import '../theme.dart';

BoxDecoration neuRaised({double radius = kRadiusCard, Color color = AppColors.bg}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: AppColors.shDark, offset: const Offset(6, 6), blurRadius: 12),
      BoxShadow(color: AppColors.shLight, offset: const Offset(-6, -6), blurRadius: 12),
    ],
  );
}

BoxDecoration neuRaisedSm({double radius = kRadiusIcon, Color color = AppColors.bg}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: AppColors.shDark, offset: const Offset(3, 3), blurRadius: 7),
      BoxShadow(color: AppColors.shLight, offset: const Offset(-3, -3), blurRadius: 7),
    ],
  );
}

BoxDecoration neuPressed({double radius = kRadiusInput, Color color = AppColors.bg}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.shDark.withAlpha(115), color, AppColors.shLight],
      stops: const [0, 0.6, 1],
    ),
  );
}

class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = kRadiusCard,
    this.pressed = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool pressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: pressed ? neuPressed(radius: radius) : neuRaised(radius: radius),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class NeuCircleIcon extends StatelessWidget {
  const NeuCircleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 18,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: neuRaisedSm(radius: size / 2),
      child: Icon(icon, size: iconSize, color: color),
    );
    if (onTap == null) return circle;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: circle),
    );
  }
}

class NeuPrimaryButton extends StatelessWidget {
  const NeuPrimaryButton({super.key, required this.label, this.onPressed, this.color = AppColors.blue});

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? color : color.withAlpha(90),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(35), borderRadius: BorderRadius.circular(kRadiusPill)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: neuPressed(radius: kRadiusPill),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: active
                    ? BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(kRadiusPill))
                    : null,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: active
                  ? BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(kRadiusPill))
                  : neuRaisedSm(radius: kRadiusPill),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.inkSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hint = 'Search…',
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: neuPressed(radius: kRadiusInput),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.inkFaint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              readOnly: readOnly,
              onTap: onTap,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.inkFaint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateNote extends StatelessWidget {
  const EmptyStateNote({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: neuRaisedSm(radius: 22),
            child: Icon(icon, size: 20, color: AppColors.inkFaint),
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: AppText.caption),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.initials, this.size = 42, this.fontSize = 13.5});

  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: neuRaisedSm(radius: size / 2),
      child: Text(
        initials,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
    );
  }
}

Color callTypeColor(String type) {
  switch (type) {
    case 'incoming':
      return AppColors.greenInk;
    case 'outgoing':
      return AppColors.blueInk;
    default:
      return AppColors.redInk;
  }
}

IconData callTypeIcon(String type) {
  switch (type) {
    case 'incoming':
      return Icons.call_received;
    case 'outgoing':
      return Icons.call_made;
    default:
      return Icons.call_missed;
  }
}
