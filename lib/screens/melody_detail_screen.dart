import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/melody.dart';
import '../services/melody_provider.dart';

class MelodyDetailScreen extends StatelessWidget {
  final Melody melody;

  const MelodyDetailScreen({Key? key, required this.melody}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modeLabel = melody.mode == 'manual' ? 'Manuel' : 'Validation';
    final date =
        '${melody.createdAt.day}/${melody.createdAt.month}/${melody.createdAt.year} ${melody.createdAt.hour}:${melody.createdAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la mélodie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom
            const Text(
              'Nom',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              melody.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Mode
            const Text(
              'Mode',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              modeLabel,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Date
            const Text(
              'Date de création',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              date,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Notes enregistrées',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: melody.notes
                      .asMap()
                      .entries
                      .map(
                        (entry) => Chip(
                          label: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton supprimer
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer la suppression'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir supprimer cette mélodie ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<MelodyProvider>().deleteMelody(melody.id);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Supprimer cette mélodie'),
            ),
          ],
        ),
      ),
    );
  }
}
