class Melody {
  final String id;
  final String name;
  final String mode; // 'manual' ou 'validation'
  final List<String> notes; // Do, Ré, Mi, Fa, Sol, La, Si
  final DateTime createdAt;

  Melody({
    required this.id,
    required this.name,
    required this.mode,
    required this.notes,
    required this.createdAt,
  });

  // Convertir en JSON pour stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Créer depuis JSON
  factory Melody.fromJson(Map<String, dynamic> json) {
    return Melody(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: json['mode'] as String,
      notes: List<String>.from(json['notes'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Copie avec modifications
  Melody copyWith({
    String? id,
    String? name,
    String? mode,
    List<String>? notes,
    DateTime? createdAt,
  }) {
    return Melody(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
