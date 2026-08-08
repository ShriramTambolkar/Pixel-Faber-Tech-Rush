import 'package:flutter/material.dart';

class AnimatedDustbinIcon extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final String tooltip;

  const AnimatedDustbinIcon({
    super.key,
    required this.onPressed,
    this.color = Colors.red,
    this.size = 24.0,
    this.tooltip = 'Delete',
  });

  @override
  State<AnimatedDustbinIcon> createState() => _AnimatedDustbinIconState();
}

class _AnimatedDustbinIconState extends State<AnimatedDustbinIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lidJumpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _lidJumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 60),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClick() {
    _controller.forward(from: 0.0).then((_) {
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: _handleClick,
      icon: SizedBox(
        width: widget.size,
        height: widget.size + 10,
        child: AnimatedBuilder(
          animation: _lidJumpAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Dustbin Lid (Animated Jumping up)
                Transform.translate(
                  offset: Offset(0, _lidJumpAnimation.value - 4),
                  child: Icon(
                    Icons.horizontal_rule,
                    size: widget.size * 0.75,
                    color: widget.color,
                  ),
                ),
                // Dustbin Base
                Icon(
                  Icons.delete_outline,
                  size: widget.size,
                  color: widget.color,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
