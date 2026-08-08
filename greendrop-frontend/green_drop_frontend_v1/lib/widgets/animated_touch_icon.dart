import 'package:flutter/material.dart';

class AnimatedTouchIcon extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const AnimatedTouchIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.activeColor = const Color(0xFF1E5631),
    this.inactiveColor = Colors.grey,
    this.size = 22,
  });

  @override
  State<AnimatedTouchIcon> createState() => _AnimatedTouchIconState();
}

class _AnimatedTouchIconState extends State<AnimatedTouchIcon> {
  bool _isTouched = false;

  void _handleTap() async {
    setState(() => _isTouched = true);
    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      setState(() => _isTouched = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTouched = true),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => setState(() => _isTouched = false),
      child: AnimatedScale(
        scale: _isTouched ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isTouched ? widget.activeColor.withValues(alpha: 0.15) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _isTouched ? widget.activeColor : widget.inactiveColor,
          ),
        ),
      ),
    );
  }
}
