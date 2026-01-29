import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom SplitButton that pairs a leading action with a trailing menu.
class ExpressiveSplitButton extends StatelessWidget {
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final Widget label;
  final Widget icon;

  const ExpressiveSplitButton({
    super.key,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPrimaryPressed,
              icon: icon,
              label: label,
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 56,
            child: FilledButton(
              onPressed: onSecondaryPressed,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom ButtonGroup with "bump and react" physics (mocked via animations).
class ExpressiveButtonGroup extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final Function(int) onSelected;

  const ExpressiveButtonGroup({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<ExpressiveButtonGroup> createState() => _ExpressiveButtonGroupState();
}

class _ExpressiveButtonGroupState extends State<ExpressiveButtonGroup> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(widget.options.length, (index) {
          final isSelected = widget.selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    widget.options[index],
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
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

/// A WavyProgressIndicator using a custom painter.
class WavyProgressIndicator extends StatefulWidget {
  final double value;
  const WavyProgressIndicator({super.key, required this.value});

  @override
  State<WavyProgressIndicator> createState() => _WavyProgressIndicatorState();
}

class _WavyProgressIndicatorState extends State<WavyProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 24),
          painter: _WavyPainter(
            animationValue: _controller.value,
            progress: widget.value,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _WavyPainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color color;

  _WavyPainter({
    required this.animationValue,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final trackPath = Path();

    const amp = 3.0;
    const waveLength = 40.0;
    final midY = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      final y =
          midY +
          amp *
              math.sin(
                (x / waveLength) * 2 * math.pi + animationValue * 2 * math.pi,
              );
      if (x == 0) {
        trackPath.moveTo(x, y);
      } else {
        trackPath.lineTo(x, y);
      }
    }

    canvas.drawPath(trackPath, trackPaint);

    for (double x = 0; x <= size.width * progress; x++) {
      final y =
          midY +
          amp *
              math.sin(
                (x / waveLength) * 2 * math.pi + animationValue * 2 * math.pi,
              );
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _WavyPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress;
  }
}

/// A custom card for format selection in a grid.
class FormatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String info;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasVideo;
  final bool hasAudio;

  const FormatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.info,
    required this.isSelected,
    required this.onTap,
    this.hasVideo = false,
    this.hasAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? colorScheme.onPrimaryContainer : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    info,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasVideo)
                      Icon(
                        Icons.videocam_rounded,
                        size: 14,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    if (hasVideo && hasAudio) const SizedBox(width: 2),
                    if (hasAudio)
                      Icon(
                        Icons.music_note_rounded,
                        size: 14,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
