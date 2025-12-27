import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sample_data.dart';
import '../models/genre.dart';
import '../models/item.dart';
import '../models/custom_genre.dart';
import '../providers/game_provider.dart';
import '../providers/custom_genre_provider.dart';
import 'game_screen.dart';
import 'create_genre_screen.dart';
import 'edit_items_screen.dart';
import 'video_record_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customGenresAsync = ref.watch(customGenreProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Pop title with app icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative stars left
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  // App icon with shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Decorative stars right
                  const Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 12),
              // Title text with pop style
              Stack(
                children: [
                  // Shadow layer
                  Text(
                    '1位はどれだ？',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = const Color(0xFF4A1A7A),
                    ),
                  ),
                  // Main text with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFE066),
                        Color(0xFFFFB347),
                        Color(0xFFFF6B6B),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      '1位はどれだ？',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Subtitle with sparkle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'ジャンルを選んでランキングを作ろう！',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: customGenresAsync.when(
                    data: (customGenres) =>
                        _buildGenreGrid(context, ref, customGenres),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Error: $e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              // Create button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateGenreScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('自分で出題を作成'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  '出題されるアイテムを1位〜10位に配置しよう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreGrid(
    BuildContext context,
    WidgetRef ref,
    List<CustomGenre> customGenres,
  ) {
    final allGenres = <_GenreItem>[
      // Default genres
      ...genres.map(
        (g) => _GenreItem(
          id: g.id,
          name: g.name,
          emoji: g.emoji,
          color: g.color,
          description: g.description,
          isCustom: false,
        ),
      ),
      // Custom genres
      ...customGenres.map(
        (g) => _GenreItem(
          id: g.id,
          name: g.name,
          emoji: g.emoji,
          color: g.color,
          description: '${g.items.length}個のアイテム',
          isCustom: true,
          customGenre: g,
        ),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: allGenres.length,
      itemBuilder: (context, index) {
        final item = allGenres[index];
        return _buildGenreCard(context, ref, item);
      },
    );
  }

  Widget _buildGenreCard(BuildContext context, WidgetRef ref, _GenreItem item) {
    return GestureDetector(
      onTap: () => _showPlayModeDialog(context, ref, item),
      onLongPress: item.isCustom
          ? () => _showCustomGenreOptions(context, ref, item.customGenre!)
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [item.color, item.color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (item.isCustom)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'カスタム',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayModeDialog(
    BuildContext context,
    WidgetRef ref,
    _GenreItem item,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${item.emoji} ${item.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow, color: item.color),
              title: const Text('通常モード'),
              subtitle: const Text('一人でランキングを作成'),
              onTap: () {
                Navigator.of(context).pop();
                if (item.isCustom && item.customGenre != null) {
                  ref
                      .read(gameProvider.notifier)
                      .startCustomGame(item.customGenre!);
                } else {
                  ref.read(gameProvider.notifier).startGame(item.id);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      genre: Genre(
                        id: item.id,
                        name: item.name,
                        emoji: item.emoji,
                        color: item.color,
                        description: item.description,
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: item.color),
              title: const Text('撮影モード'),
              subtitle: const Text('ショート動画を撮影しながらランキングを作成'),
              onTap: () {
                Navigator.of(context).pop();

                // Get items for this genre
                List<Item> items;
                if (item.isCustom && item.customGenre != null) {
                  items = item.customGenre!.items
                      .map(
                        (e) => Item(
                          id: e.id,
                          name: e.name,
                          genreId: item.customGenre!.id,
                          popularityScore: e.popularityScore,
                        ),
                      )
                      .toList();
                } else {
                  items = itemsByGenre[item.id] ?? [];
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoRecordScreen(
                      genre: Genre(
                        id: item.id,
                        name: item.name,
                        emoji: item.emoji,
                        color: item.color,
                        description: item.description,
                      ),
                      items: items,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCustomGenreOptions(
    BuildContext context,
    WidgetRef ref,
    CustomGenre genre,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EditItemsScreen(genre: genre, isNew: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('削除確認'),
                    content: Text('「${genre.name}」を削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          '削除',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(customGenreProvider.notifier).deleteGenre(genre.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreItem {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final bool isCustom;
  final CustomGenre? customGenre;

  _GenreItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.isCustom,
    this.customGenre,
  });
}
