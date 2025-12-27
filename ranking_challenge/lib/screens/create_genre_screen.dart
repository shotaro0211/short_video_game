import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_genre.dart';
import '../providers/custom_genre_provider.dart';
import 'edit_items_screen.dart';

class CreateGenreScreen extends ConsumerStatefulWidget {
  final CustomGenre? existingGenre;

  const CreateGenreScreen({super.key, this.existingGenre});

  @override
  ConsumerState<CreateGenreScreen> createState() => _CreateGenreScreenState();
}

class _CreateGenreScreenState extends ConsumerState<CreateGenreScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '⭐';
  Color _selectedColor = const Color(0xFF6366F1);

  final List<String> _emojis = [
    '⭐', '🎮', '🎬', '🎵', '📚', '🍔', '🏀', '🎯',
    '💼', '🌍', '🚗', '✈️', '🏠', '👔', '💎', '🎨',
  ];

  final List<Color> _colors = [
    const Color(0xFF6366F1),
    const Color(0xFFEC4899),
    const Color(0xFF14B8A6),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFF84CC16),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGenre != null) {
      _nameController.text = widget.existingGenre!.name;
      _selectedEmoji = widget.existingGenre!.emoji;
      _selectedColor = widget.existingGenre!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ジャンル名を入力してください')),
      );
      return;
    }

    final genre = CustomGenre(
      id: widget.existingGenre?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      emoji: _selectedEmoji,
      colorValue: _selectedColor.value,
      items: widget.existingGenre?.items ?? [],
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EditItemsScreen(genre: genre, isNew: widget.existingGenre == null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _selectedColor,
              _selectedColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'ジャンルを作成',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _selectedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _selectedColor, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Genre name
                        const Text(
                          'ジャンル名',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '例: 好きな映画',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _selectedColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Emoji selection
                        const Text(
                          'アイコン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _emojis.map((emoji) {
                            final isSelected = emoji == _selectedEmoji;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedEmoji = emoji),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _selectedColor.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: _selectedColor, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Color selection
                        const Text(
                          'カラー',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _colors.map((color) {
                            final isSelected = color.value == _selectedColor.value;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _selectedColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '次へ：アイテムを追加',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
