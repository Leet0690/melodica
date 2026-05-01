import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';

class ManualModeScreen extends StatefulWidget {
  const ManualModeScreen({Key? key}) : super(key: key);

  @override
  State<ManualModeScreen> createState() => _ManualModeScreenState();
}

class _ManualModeScreenState extends State<ManualModeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> notes = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveButtonTapped(BuildContext context) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom pour la mélodie')),
      );
      return;
    }

    if (context.read<MelodyProvider>().currentNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une note')),
      );
      return;
    }

    context.read<MelodyProvider>().saveMelody(_nameController.text);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout manuel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<MelodyProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Champ nom
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la mélodie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons des notes
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: notes
                      .map(
                        (note) => ElevatedButton(
                          onPressed: () => provider.addNote(note),
                          child: Text(note),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 30),

                // Liste des notes
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: provider.currentNotes.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune note ajoutée',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.currentNotes
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
                const SizedBox(height: 20),

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.removeLastNote(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Supprimer dernière'),
                    ),
                    ElevatedButton(
                      onPressed: () => provider.clearNotes(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Vider'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bouton sauvegarder
                ElevatedButton(
                  onPressed: () => _saveButtonTapped(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Sauvegarder',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
