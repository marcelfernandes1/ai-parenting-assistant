/// Reusable animation widgets for micro-interactions and celebrations.
/// Provides button feedback, confetti, pulsing indicators, and transition animations.
/// Respects system accessibility settings like Reduce Motion.
library;

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';

/// Animated button wrapper that provides press feedback
/// Scales down slightly when pressed for tactile feel
class AnimatedButton extends StatefulWidget {
  /// Child widget (typically a button)
  final Widget child;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Scale factor when pressed (default: 0.95)
  final double scaleOnPress;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleOnPress = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  /// Whether button is currently pressed
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Respect reduce motion setting - disable animation if reduce motion is enabled
    final animationDuration = context.animationDuration(
      const Duration(milliseconds: 100),
    );

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleOnPress : 1.0,
        duration: animationDuration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Confetti overlay for celebrations (milestone completion, achievements)
/// Shows confetti burst animation from the center or top
class ConfettiOverlay extends StatefulWidget {
  /// Controller for triggering confetti
  final ConfettiController controller;

  /// Direction of confetti (default: from top)
  final double blastDirection;

  /// Colors for confetti particles
  final List<Color>? colors;

  const ConfettiOverlay({
    super.key,
    required this.controller,
    this.blastDirection = -pi / 2, // Upwards
    this.colors,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: widget.controller,
        blastDirection: widget.blastDirection,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        maxBlastForce: 20,
        minBlastForce: 10,
        gravity: 0.3,
        colors: widget.colors ?? [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
          Colors.pink,
          Colors.orange,
        ],
        createParticlePath: _drawStar,
      ),
    );
  }

  /// Draws a star-shaped confetti particle
  Path _drawStar(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    for (int i = 0; i < 5; i++) {
      final double angle = (pi / 2) + (2 * pi * i / 5);
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final double innerAngle = angle + (pi / 5);
      final double innerX = centerX + (radius / 2.5) * cos(innerAngle);
      final double innerY = centerY + (radius / 2.5) * sin(innerAngle);
      path.lineTo(innerX, innerY);
    }

    path.close();
    return path;
  }
}

/// Helper function to trigger confetti celebration
/// Creates a controller, shows confetti, and disposes
Future<void> showConfetti(BuildContext context) async {
  final controller = ConfettiController(duration: const Duration(seconds: 3));
  
  // Show confetti overlay
  final overlay = OverlayEntry(
    builder: (context) => ConfettiOverlay(controller: controller),
  );
  
  Overlay.of(context).insert(overlay);
  controller.play();
  
  // Remove overlay after animation completes
  await Future.delayed(const Duration(seconds: 4));
  overlay.remove();
  controller.dispose();
}

/// Pulsing dot indicator (for voice recording, loading states)
/// Animated circle that scales and fades in and out
class PulsingDot extends StatefulWidget {
  /// Size of the dot
  final double size;

  /// Color of the dot
  final Color? color;

  /// Duration of one pulse cycle
  final Duration duration;

  const PulsingDot({
    super.key,
    this.size = 12,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create infinite animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    // Scale from 1.0 to 1.3
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Opacity from 1.0 to 0.5
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = widget.color ?? theme.colorScheme.error;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Voice recording indicator with pulsing animation
/// Shows a pulsing red dot with "Recording..." text
class RecordingIndicator extends StatelessWidget {
  const RecordingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PulsingDot(
          size: 12,
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          'Recording...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Success checkmark animation
/// Animated checkmark that scales in with bounce effect
class SuccessCheckmark extends StatefulWidget {
  /// Size of the checkmark
  final double size;

  const SuccessCheckmark({
    super.key,
    this.size = 60,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Respect reduce motion setting
    final duration = context.animationDuration(
      const Duration(milliseconds: 600),
    );

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    // Scale with bounce effect (or instant if reduce motion is enabled)
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    // Controller will be initialized in didChangeDependencies where we have context
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: theme.colorScheme.onPrimary,
              size: widget.size * 0.6,
            ),
          ),
        );
      },
    );
  }
}

/// Fade and slide transition for page changes
/// Slides content in from right while fading in
class FadeSlideTransition extends StatelessWidget {
  /// Child widget to animate
  final Widget child;

  /// Animation controller
  final Animation<double> animation;

  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }
}
