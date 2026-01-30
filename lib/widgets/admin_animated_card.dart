import 'package:flutter/material.dart';

class AdminAnimatedCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const AdminAnimatedCard({
    super.key,
    required this.child,
    required this.color,
    required this.onTap,
    this.padding,
  });

  @override
  State<AdminAnimatedCard> createState() => _AdminAnimatedCardState();
}

class _AdminAnimatedCardState extends State<AdminAnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: widget.padding ?? const EdgeInsets.all(15),
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.97))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
