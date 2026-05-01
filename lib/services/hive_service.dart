import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/melody.dart';

class HiveService {
  static const String _melodiesBoxName = 'melodies';

  // Initialiser Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_melodiesBoxName);
  }

  // Sauvegarder une mélodie
  static Future<void> saveMelody(Melody melody) async {
    final box = Hive.box<String>(_melodiesBoxName);
    await box.put(melody.id, jsonEncode(melody.toJson()));
  }

  // Récupérer une mélodie
  static Future<Melody?> getMelody(String id) async {
    final box = Hive.box<String>(_melodiesBoxName);
    final jsonString = box.get(id);
    if (jsonString == null) return null;
    return Melody.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Récupérer toutes les mélodies
  static Future<List<Melody>> getAllMelodies() async {
    final box = Hive.box<String>(_melodiesBoxName);
    final melodies = <Melody>[];
    for (final jsonString in box.values) {
      melodies.add(Melody.fromJson(jsonDecode(jsonString) as Map<String, dynamic>));
    }
    // Trier par date décroissante
    melodies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return melodies;
  }

  // Supprimer une mélodie
  static Future<void> deleteMelody(String id) async {
    final box = Hive.box<String>(_melodiesBoxName);
    await box.delete(id);
  }

  // Nettoyer toutes les données
  static Future<void> clearAll() async {
    final box = Hive.box<String>(_melodiesBoxName);
    await box.clear();
  }
}
