import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sample_data.dart';
import '../widgets/genre_card.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'ランキング',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'チャレンジ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ジャンルを選んでランキングを作ろう！',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      return GenreCard(
                        genre: genre,
                        onTap: () {
                          ref.read(gameProvider.notifier).startGame(genre.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GameScreen(genre: genre),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '遊び方: 出題されるアイテムを\n1位〜10位のどこに配置するか決めよう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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
