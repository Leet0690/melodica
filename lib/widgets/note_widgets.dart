import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NoteChip extends StatefulWidget {
  final int index;
  final String note;
  final String? converted;
  final Color color;

  const NoteChip({
    Key? key,
    required this.index,
    required this.note,
    this.converted,
    required this.color,
  }) : super(key: key);

  @override
  State<NoteChip> createState() => _NoteChipState();
}

class _NoteChipState extends State<NoteChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.color.withOpacity(0.4), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.index}',
              style: TextStyle(
                fontSize: 9,
                color: widget.color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.note,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            if (widget.converted != null)
              Text(
                widget.converted!,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.color.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const ActionBtn({
    Key? key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class NoteKey extends StatefulWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const NoteKey({
    Key? key,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NoteKey> createState() => _NoteKeyState();
}

class _NoteKeyState extends State<NoteKey> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.color
                : widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(widget.isActive ? 1 : 0.4),
              width: 1.5,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.isActive ? Colors.white : widget.color,
                ),
              ),
              Text(
                widget.sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: widget.isActive
                      ? Colors.white70
                      : widget.color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SysTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const SysTab({
    Key? key,
    required this.label,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
