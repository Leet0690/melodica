import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';
import '../models/melody.dart';
import '../theme/app_theme.dart';
import 'melody_detail_screen.dart';

class MelodiesListScreen extends StatefulWidget {
  const MelodiesListScreen({Key? key}) : super(key: key);

  @override
  State<MelodiesListScreen> createState() => _MelodiesListScreenState();
}

class _MelodiesListScreenState extends State<MelodiesListScreen> {
  static const _solfegeToABCD = {
    'Do': 'C', 'Ré': 'D', 'Mi': 'E',
    'Fa': 'F', 'Sol': 'G', 'La': 'A', 'Si': 'B',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MelodyProvider>().loadMelodies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes mélodies',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<MelodyProvider>(
        builder: (context, provider, _) {
          if (provider.melodies.isEmpty) {
            return _buildEmpty();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: provider.melodies.length,
            itemBuilder: (context, index) {
              return _MelodyCard(
                melody: provider.melodies[index],
                colorIndex: index % AppColors.noteColors.length,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          MelodyDetailScreen(melody: provider.melodies[index]),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, provider, provider.melodies[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_music_rounded,
              size: 56,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune mélodie encore',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première composition !',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MelodyProvider provider, Melody melody) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('Supprimer ?'),
        ]),
        content: Text(
          'Voulez-vous supprimer "${melody.name}" ?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteMelody(melody.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _MelodyCard extends StatelessWidget {
  final Melody melody;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _solfegeToABCD = {
    'Do': 'C', 'Ré': 'D', 'Mi': 'E',
    'Fa': 'F', 'Sol': 'G', 'La': 'A', 'Si': 'B',
  };

  const _MelodyCard({
    required this.melody,
    required this.colorIndex,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.noteColors[colorIndex];
    final date =
        '${melody.createdAt.day}/${melody.createdAt.month.toString().padLeft(2, '0')}/${melody.createdAt.year}';
    final modeLabel = melody.mode == 'manual' ? 'Manuel' : 'Validation';
    final noteCount = melody.notes.length;
    final previewNotes = melody.notes.take(4).join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  melody.name.isNotEmpty ? melody.name[0].toUpperCase() : '♪',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    melody.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Tag(label: modeLabel, color: AppColors.primary),
                      const SizedBox(width: 6),
                      _Tag(label: '$noteCount note${noteCount > 1 ? 's' : ''}', color: color),
                    ],
                  ),
                  if (previewNotes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      previewNotes + (melody.notes.length > 4 ? '...' : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
