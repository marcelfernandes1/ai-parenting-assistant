/// Animated voice waveform widget similar to ChatGPT's recording UI
/// Shows animated sound wave bars while recording
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget that displays an animated waveform during voice recording
class VoiceWaveform extends StatefulWidget {
  /// Whether the waveform should be animating
  final bool isAnimating;

  /// Color of the waveform bars
  final Color color;

  /// Number of bars in the waveform
  final int barCount;

  const VoiceWaveform({
    super.key,
    required this.isAnimating,
    this.color = Colors.black,
    this.barCount = 40,
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
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
          painter: _WaveformPainter(
            animation: _controller.value,
            color: widget.color,
            barCount: widget.barCount,
          ),
          size: const Size(double.infinity, 60),
        );
      },
    );
  }
}

/// Custom painter for the waveform animation
class _WaveformPainter extends CustomPainter {
  final double animation;
  final Color color;
  final int barCount;

  _WaveformPainter({
    required this.animation,
    required this.color,
    required this.barCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = 3.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);

      // Create varied heights with smooth animation
      final phase = (animation * 2 * math.pi) + (i * 0.3);
      final baseHeight = _getBarHeight(i, barCount);
      final animatedHeight = baseHeight * (0.3 + 0.7 * (0.5 + 0.5 * math.sin(phase)));

      final height = animatedHeight * size.height * 0.8;

      // Draw bar centered vertically
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, centerY),
            width: barWidth,
            height: height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  /// Get the base height for a bar based on its position
  /// Creates a natural wave pattern
  double _getBarHeight(int index, int total) {
    final normalized = index / total;
    // Create a wave pattern that's higher in the middle
    final wave = math.sin(normalized * math.pi);
    // Add some randomness
    final random = math.sin(index * 2.5);
    return (wave * 0.7 + random * 0.3).abs();
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
