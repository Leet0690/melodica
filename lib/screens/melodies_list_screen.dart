import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';
import 'melody_detail_screen.dart';

class MelodiesListScreen extends StatefulWidget {
  const MelodiesListScreen({Key? key}) : super(key: key);

  @override
  State<MelodiesListScreen> createState() => _MelodiesListScreenState();
}

class _MelodiesListScreenState extends State<MelodiesListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les mélodies au démarrage
    Future.microtask(() => context.read<MelodyProvider>().loadMelodies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes mélodies'),
      ),
      body: Consumer<MelodyProvider>(
        builder: (context, provider, child) {
          if (provider.melodies.isEmpty) {
            return const Center(
              child: Text(
                'Aucune mélodie enregistrée',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.melodies.length,
            itemBuilder: (context, index) {
              final melody = provider.melodies[index];
              final modeLabel =
                  melody.mode == 'manual' ? 'Manuel' : 'Validation';
              final date =
                  '${melody.createdAt.day}/${melody.createdAt.month}/${melody.createdAt.year}';

              return ListTile(
                title: Text(melody.name),
                subtitle: Text('Mode: $modeLabel • $date'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Voir'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MelodyDetailScreen(melody: melody),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Supprimer'),
                      onTap: () {
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
                                  provider.deleteMelody(melody.id);
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
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
