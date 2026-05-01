import 'package:flutter/material.dart';
import '../models/melody.dart';
import '../services/hive_service.dart';

class MelodyProvider extends ChangeNotifier {
  List<Melody> _melodies = [];
  List<String> _currentNotes = [];
  String? _currentMode;
  bool _isLatinSystem = true;

  List<Melody> get melodies => _melodies;
  List<String> get currentNotes => _currentNotes;
  String? get currentMode => _currentMode;
  bool get isLatinSystem => _isLatinSystem;

  static const Map<String, String> angloToLatinMap = {
    'C': 'Do', 'D': 'Ré', 'E': 'Mi', 'F': 'Fa', 'G': 'Sol', 'A': 'La', 'B': 'Si',
    'C#': 'Do#', 'Db': 'Réb', 'D#': 'Ré#', 'Eb': 'Mib', 'F#': 'Fa#', 'Gb': 'Solb',
    'G#': 'Sol#', 'Ab': 'Lab', 'A#': 'La#', 'Bb': 'Sib'
  };

  static const Map<String, String> latinToAngloMap = {
    'Do': 'C', 'Ré': 'D', 'Mi': 'E', 'Fa': 'F', 'Sol': 'G', 'La': 'A', 'Si': 'B',
    'Do#': 'C#', 'Réb': 'Db', 'Ré#': 'D#', 'Mib': 'Eb', 'Fa#': 'F#', 'Solb': 'Gb',
    'Sol#': 'G#', 'Lab': 'Ab', 'La#': 'A#', 'Sib': 'Bb'
  };

  // Charger toutes les mélodies
  Future<void> loadMelodies() async {
    _melodies = await HiveService.getAllMelodies();
    notifyListeners();
  }

  // Ajouter une note à la séquence actuelle
  void addNote(String note) {
    // Normalisation : on stocke toujours en système Latin
    String normalizedNote = note;
    if (angloToLatinMap.containsKey(note)) {
      normalizedNote = angloToLatinMap[note]!;
    }
    _currentNotes.add(normalizedNote);
    notifyListeners();
  }

  // Changer le système de notation
  void setNotationSystem(bool isLatin) {
    _isLatinSystem = isLatin;
    notifyListeners();
  }

  // Convertir une liste de notes pour l'affichage
  List<String> getDisplayNotes(List<String> latinNotes) {
    if (_isLatinSystem) return latinNotes;
    return latinNotes.map((note) => latinToAngloMap[note] ?? note).toList();
  }

  // Supprimer la dernière note
  void removeLastNote() {
    if (_currentNotes.isNotEmpty) {
      _currentNotes.removeLast();
      notifyListeners();
    }
  }

  // Vider la séquence
  void clearNotes() {
    _currentNotes.clear();
    notifyListeners();
  }

  // Choisir le mode
  void setMode(String mode) {
    _currentMode = mode;
    notifyListeners();
  }

  // Sauvegarder une mélodie
  Future<void> saveMelody(String name) async {
    if (_currentNotes.isEmpty || _currentMode == null) return;

    final melody = Melody(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      mode: _currentMode!,
      notes: List.from(_currentNotes),
      createdAt: DateTime.now(),
    );

    await HiveService.saveMelody(melody);
    _melodies.add(melody);
    _melodies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _currentNotes.clear();
    _currentMode = null;
    notifyListeners();
  }

  // Supprimer une mélodie
  Future<void> deleteMelody(String id) async {
    await HiveService.deleteMelody(id);
    _melodies.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // Réinitialiser l'état
  void reset() {
    _currentNotes.clear();
    _currentMode = null;
    notifyListeners();
  }
}
