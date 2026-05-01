import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/note_widgets.dart';

class ValidationModeScreen extends StatefulWidget {
  const ValidationModeScreen({Key? key}) : super(key: key);

  @override
  State<ValidationModeScreen> createState() => _ValidationModeScreenState();
}

class _ValidationModeScreenState extends State<ValidationModeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  bool _isListening = false;
  bool _useABCD = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _notesSolfege = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];
  static const _notesABCD = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const _solfegeToABCD = {
    'Do': 'C', 'Ré': 'D', 'Mi': 'E',
    'Fa': 'F', 'Sol': 'G', 'La': 'A', 'Si': 'B',
  };
  static const _abcdToSolfege = {
    'C': 'Do', 'D': 'Ré', 'E': 'Mi',
    'F': 'Fa', 'G': 'Sol', 'A': 'La', 'B': 'Si',
  };

  static const _accidentalsSolfege = [
    ['Do#', 'Réb'], ['Ré#', 'Mib'], ['Fa#', 'Solb'], ['Sol#', 'Lab'], ['La#', 'Sib'],
  ];
  static const _accidentalsABCD = [
    ['C#', 'Db'], ['D#', 'Eb'], ['F#', 'Gb'], ['G#', 'Ab'], ['A#', 'Bb'],
  ];

  List<String> get _activeNotes => _useABCD ? _notesABCD : _notesSolfege;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _saveButtonTapped(BuildContext context) {
    if (_nameController.text.trim().isEmpty) {
      _showSnack(context, 'Veuillez entrer un nom pour la mélodie');
      return;
    }
    if (context.read<MelodyProvider>().currentNotes.isEmpty) {
      _showSnack(context, 'Veuillez ajouter au moins une note');
      return;
    }
    context.read<MelodyProvider>().saveMelody(_nameController.text.trim());
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _showNoteSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotePickerSheet(
        notes: _activeNotes,
        accidentals: _useABCD ? _accidentalsABCD : _accidentalsSolfege,
        onNoteSelected: (note) {
          context.read<MelodyProvider>().addNote(note);
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(msg),
        ]),
        backgroundColor: AppColors.primary,
      ),
    );
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
          'Détection & validation',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<MelodyProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildSystemSelector(),
                      const SizedBox(height: 24),
                      _buildMicSection(context),
                      const SizedBox(height: 24),
                      _buildNoteSequence(provider),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: const InputDecoration(
        labelText: 'Nom de la mélodie',
        prefixIcon: Icon(Icons.music_note_rounded, color: AppColors.primary),
        hintText: 'Ex: Ma première mélodie',
      ),
    );
  }

  Widget _buildSystemSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SysTab(
            label: '🎵 Do-Ré-Mi',
            active: !_useABCD,
            onTap: () => setState(() => _useABCD = false),
          ),
          SysTab(
            label: '🎹 A-B-C',
            active: _useABCD,
            onTap: () => setState(() => _useABCD = true),
          ),
        ],
      ),
    );
  }

  Widget _buildMicSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _isListening ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [AppColors.secondary, const Color(0xFFFF9F9F)]
                      : [const Color(0xFFE0E0E0), const Color(0xFFF5F5F5)],
                ),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                color: _isListening ? Colors.white : Colors.grey,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? '🎤 En écoute...' : '🎙️ Microphone éteint',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isListening ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ActionPill(
                  icon: Icons.play_arrow_rounded,
                  label: 'Démarrer',
                  color: AppColors.success,
                  active: !_isListening,
                  onTap: () => setState(() => _isListening = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionPill(
                  icon: Icons.stop_rounded,
                  label: 'Arrêter',
                  color: AppColors.secondary,
                  active: _isListening,
                  onTap: () => setState(() => _isListening = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isListening ? () => _showNoteSelectionDialog(context) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _isListening
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade200, Colors.grey.shade200],
                      ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: _isListening ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Valider une note détectée',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _isListening ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSequence(MelodyProvider provider) {
    final notes = provider.currentNotes;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.queue_music_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                notes.isEmpty
                    ? 'Séquence vide'
                    : '${notes.length} note${notes.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (notes.isNotEmpty) ...[
                ActionBtn(
                  icon: Icons.backspace_outlined,
                  color: const Color(0xFFFF9240),
                  tooltip: 'Supprimer la dernière',
                  onTap: () => provider.removeLastNote(),
                ),
                const SizedBox(width: 8),
                ActionBtn(
                  icon: Icons.delete_sweep_rounded,
                  color: AppColors.secondary,
                  tooltip: 'Tout effacer',
                  onTap: () => provider.clearNotes(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          notes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Démarrez l\'écoute et validez des notes',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: notes.asMap().entries.map((e) {
                    int colorIdx = _notesSolfege.indexOf(e.value);
                    if (colorIdx == -1) colorIdx = _notesABCD.indexOf(e.value);
                    colorIdx = colorIdx.clamp(0, AppColors.noteColors.length - 1);
                    final color = AppColors.noteColors[colorIdx];
                    final displayNote = _useABCD
                        ? (_solfegeToABCD[e.value] ?? e.value)
                        : (_abcdToSolfege[e.value] ?? e.value);
                    return NoteChip(
                      index: e.key + 1,
                      note: e.value,
                      converted: displayNote == e.value ? null : displayNote,
                      color: color,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MelodyProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _saveButtonTapped(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Sauvegarder la mélodie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color.withOpacity(0.4) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? color : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotePickerSheet extends StatelessWidget {
  final List<String> notes;
  final List<List<String>> accidentals;
  final void Function(String) onNoteSelected;

  const _NotePickerSheet({
    required this.notes,
    required this.accidentals,
    required this.onNoteSelected,
  });

  static const _notesSolfege = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quelle note avez-vous joué ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: notes.asMap().entries.map((e) {
              final idx = _notesSolfege.indexOf(e.value) == -1
                  ? e.key
                  : _notesSolfege.indexOf(e.value);
              final color = AppColors.noteColors[idx.clamp(0, AppColors.noteColors.length - 1)];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    onNoteSelected(e.value);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                    ),
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Notes altérées',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accidentals.map((pair) {
              return InkWell(
                onTap: () {
                  onNoteSelected(pair[0]);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${pair[0]} / ${pair[1]}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
