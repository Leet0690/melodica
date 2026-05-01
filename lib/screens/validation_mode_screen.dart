import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';

class ValidationModeScreen extends StatefulWidget {
  const ValidationModeScreen({Key? key}) : super(key: key);

  @override
  State<ValidationModeScreen> createState() => _ValidationModeScreenState();
}

class _ValidationModeScreenState extends State<ValidationModeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> notes = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];
  bool _isListening = false;

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

  void _showNoteSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une note'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notes
              .map(
                (note) => ElevatedButton(
                  onPressed: () {
                    context.read<MelodyProvider>().addNote(note);
                    Navigator.pop(context);
                  },
                  child: Text(note),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection avec validation'),
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

                // Statut d'écoute
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _isListening ? '🎤 En écoute...' : '🎵 Prêt',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Boutons d'écoute
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isListening = true),
                      icon: const Icon(Icons.mic),
                      label: const Text('Démarrer'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isListening = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('Arrêter'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bouton pour valider une note
                ElevatedButton(
                  onPressed: _isListening ? _showNoteSelectionDialog : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Valider une note',
                    style: TextStyle(fontSize: 16),
                  ),
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
                              'Aucune note enregistrée',
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
