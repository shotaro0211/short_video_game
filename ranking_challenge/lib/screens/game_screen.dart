import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/genre.dart';
import '../providers/game_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/ranking_slot.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final Genre genre;

  const GameScreen({super.key, required this.genre});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  int? highlightedSlot;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _placeItem(int rank) {
    final gameState = ref.read(gameProvider);
    if (gameState == null || gameState.rankings[rank] != null) return;

    ref.read(gameProvider.notifier).placeItem(rank);

    _animationController.reset();
    _animationController.forward();

    final newState = ref.read(gameProvider);
    if (newState?.isCompleted == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultScreen(genre: widget.genre),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    if (gameState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.genre.color,
              widget.genre.color.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).resetGame();
                        Navigator.of(context).pop();
                      },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${gameState.placedCount}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Current item card
              if (gameState.currentItem != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Text(
                        'この人をどこに配置する？',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ItemCard(
                          item: gameState.currentItem!,
                          color: widget.genre.color,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Ranking slots
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: List.generate(10, (index) {
                      final rank = index + 1;
                      final isAvailable = gameState.rankings[rank] == null;

                      return Expanded(
                        child: RankingSlot(
                          rank: rank,
                          item: gameState.rankings[rank],
                          isHighlighted: highlightedSlot == rank,
                          themeColor: widget.genre.color,
                          onTap: isAvailable ? () => _placeItem(rank) : null,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Hint text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '残り ${gameState.remainingItems.length + (gameState.currentItem != null ? 1 : 0)} 人',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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
}
