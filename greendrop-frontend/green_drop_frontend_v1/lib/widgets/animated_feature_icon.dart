import 'package:flutter/material.dart';

enum FeatureAnimationType { pulse, rotate, bounce, scale }

class AnimatedFeatureIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final FeatureAnimationType type;

  const AnimatedFeatureIcon({
    super.key,
    required this.icon,
    this.color = Colors.green,
    this.size = 22.0,
    this.type = FeatureAnimationType.pulse,
  });

  @override
  State<AnimatedFeatureIcon> createState() => _AnimatedFeatureIconState();
}

class _AnimatedFeatureIconState extends State<AnimatedFeatureIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FeatureAnimationType.rotate:
        return RotationTransition(
          turns: _controller,
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      case FeatureAnimationType.bounce:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -4 * _controller.value),
              child: child,
            );
          },
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      case FeatureAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.15).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      case FeatureAnimationType.pulse:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.08).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Icon(widget.icon, color: widget.color, size: widget.size),
          ),
        );
    }
  }
}
