import 'package:flutter/material.dart';
import '../models/melody.dart';
import '../services/hive_service.dart';

class MelodyProvider extends ChangeNotifier {
  List<Melody> _melodies = [];
  List<String> _currentNotes = [];
  String? _currentMode; // 'manual' ou 'validation'

  List<Melody> get melodies => _melodies;
  List<String> get currentNotes => _currentNotes;
  String? get currentMode => _currentMode;

  // Charger toutes les mélodies
  Future<void> loadMelodies() async {
    _melodies = await HiveService.getAllMelodies();
    notifyListeners();
  }

  // Ajouter une note à la séquence actuelle
  void addNote(String note) {
    _currentNotes.add(note);
    notifyListeners();
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
