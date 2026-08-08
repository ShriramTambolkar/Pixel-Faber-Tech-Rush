import 'package:flutter/material.dart';

class GreenDropNativeLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showText;
  final Color textColor;

  const GreenDropNativeLogo({
    super.key,
    this.size = 64,
    this.animate = true,
    this.showText = false,
    this.textColor = Colors.white,
  });

  @override
  State<GreenDropNativeLogo> createState() => _GreenDropNativeLogoState();
}

class _GreenDropNativeLogoState extends State<GreenDropNativeLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = ScaleTransition(
      scale: widget.animate ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * 0.22),
          child: Image.asset(
            'assets/images/greendrop_logo.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.green.shade800,
                child: Icon(
                  Icons.eco,
                  size: widget.size * 0.5,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (!widget.showText) return logoWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        const SizedBox(height: 8),
        Text(
          'GreenDrop',
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.size * 0.32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
