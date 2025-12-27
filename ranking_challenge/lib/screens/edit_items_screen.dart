import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_genre.dart';
import '../providers/custom_genre_provider.dart';
import 'home_screen.dart';

class EditItemsScreen extends ConsumerStatefulWidget {
  final CustomGenre genre;
  final bool isNew;

  const EditItemsScreen({super.key, required this.genre, required this.isNew});

  @override
  ConsumerState<EditItemsScreen> createState() => _EditItemsScreenState();
}

class _EditItemsScreenState extends ConsumerState<EditItemsScreen> {
  late List<CustomItem> _items;
  final _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.genre.items);
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;

    setState(() {
      _items.add(CustomItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _itemController.text.trim(),
        popularityScore: 50,
      ));
      _itemController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  Future<void> _save() async {
    if (_items.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最低10個のアイテムが必要です（現在: ${_items.length}個）')),
      );
      return;
    }

    // Update popularity scores based on order (first = highest)
    final updatedItems = _items.asMap().entries.map((entry) {
      return CustomItem(
        id: entry.value.id,
        name: entry.value.name,
        popularityScore: 100 - (entry.key * 5),
      );
    }).toList();

    final genre = widget.genre.copyWith(items: updatedItems);

    if (widget.isNew) {
      await ref.read(customGenreProvider.notifier).addGenre(genre);
    } else {
      await ref.read(customGenreProvider.notifier).updateGenre(genre);
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.genre.color;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withOpacity(0.6),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.genre.emoji} ${widget.genre.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _items.length >= 10
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_items.length}/10+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'アイテム名を入力',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '※ 上から順に「1位にふさわしい」順で並べてください',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Items list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            'アイテムを追加してください',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ReorderableListView.builder(
                          itemCount: _items.length,
                          onReorder: _reorderItems,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              key: ValueKey(item.id),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeItem(index),
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _items.length >= 10 ? '保存する' : 'あと${10 - _items.length}個追加してください',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
