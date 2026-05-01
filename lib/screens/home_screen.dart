import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';
import '../theme/app_theme.dart';
import 'mode_selection_screen.dart';
import 'melodies_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  PageRoute _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDE7FF), Color(0xFFF2EEFF), Color(0xFFFFEBF0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  'Melodica',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Composez, notez, jouez 🎵',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _buildNoteDecorations(),
                const Spacer(),
                _MainCard(
                  icon: Icons.music_note_rounded,
                  iconColor: Colors.white,
                  iconBg: AppColors.primary,
                  title: 'Nouvelle mélodie',
                  subtitle: 'Créer et saisir des notes',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFB47CFF)],
                  ),
                  textColor: Colors.white,
                  onTap: () {
                    context.read<MelodyProvider>().reset();
                    Navigator.push(context, _fadeRoute(const ModeSelectionScreen()));
                  },
                ),
                const SizedBox(height: 16),
                _MainCard(
                  icon: Icons.library_music_rounded,
                  iconColor: AppColors.secondary,
                  iconBg: AppColors.secondary.withOpacity(0.15),
                  title: 'Mes mélodies',
                  subtitle: 'Retrouver vos compositions',
                  gradient: LinearGradient(
                    colors: [AppColors.surface, const Color(0xFFF8F5FF)],
                  ),
                  textColor: AppColors.textPrimary,
                  onTap: () {
                    Navigator.push(context, _fadeRoute(const MelodiesListScreen()));
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.piano_rounded, size: 44, color: Colors.white),
    );
  }

  Widget _buildNoteDecorations() {
    const notes = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: notes.asMap().entries.map((e) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.noteColors[e.key].withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.noteColors[e.key].withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.noteColors[e.key],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MainCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color textColor;
  final VoidCallback onTap;

  const _MainCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_MainCard> createState() => _MainCardState();
}

class _MainCardState extends State<_MainCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.iconColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.textColor.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
