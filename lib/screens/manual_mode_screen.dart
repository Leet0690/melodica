import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/melody_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/note_widgets.dart';

class ManualModeScreen extends StatefulWidget {
  const ManualModeScreen({Key? key}) : super(key: key);

  @override
  State<ManualModeScreen> createState() => _ManualModeScreenState();
}

class _ManualModeScreenState extends State<ManualModeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  bool _useABCD = false;
  int? _lastTappedIndex;

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

  List<String> get _activeNotes => _useABCD ? _notesABCD : _notesSolfege;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNoteTap(int index, MelodyProvider provider) {
    setState(() => _lastTappedIndex = index);
    provider.addNote(_activeNotes[index]);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _lastTappedIndex = null);
    });
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
          'Ajout manuel',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildSystemSelector(),
                      const SizedBox(height: 24),
                      _buildNoteKeyboard(provider),
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

  Widget _buildNoteKeyboard(MelodyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appuyez sur une note',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_activeNotes.length, (i) {
            final isActive = _lastTappedIndex == i;
            final color = AppColors.noteColors[i];
            final sub = _useABCD
                ? (_abcdToSolfege[_activeNotes[i]] ?? '')
                : (_solfegeToABCD[_activeNotes[i]] ?? '');
            return Expanded(
              child: NoteKey(
                label: _activeNotes[i],
                sublabel: sub,
                color: color,
                isActive: isActive,
                onTap: () => _onNoteTap(i, provider),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNoteSequence(MelodyProvider provider) {
    final notes = provider.currentNotes;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.piano_rounded,
                          size: 40,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Appuyez sur les touches pour composer',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: notes.asMap().entries.map((e) {
                    final solfegeList = _notesSolfege;
                    final abcdList = _notesABCD;
                    int colorIdx = solfegeList.indexOf(e.value);
                    if (colorIdx == -1) colorIdx = abcdList.indexOf(e.value);
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
