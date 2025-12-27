import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/custom_genre.dart';
import '../data/sample_data.dart';

class GameNotifier extends Notifier<GameState?> {
  @override
  GameState? build() => null;

  void startGame(String genreId) {
    final items = itemsByGenre[genreId] ?? [];
    if (items.length >= 10) {
      state = GameState.initial(genreId, items);
    }
  }

  void startCustomGame(CustomGenre genre) {
    final items = genre.items
        .map((e) => Item(
              id: e.id,
              name: e.name,
              genreId: genre.id,
              popularityScore: e.popularityScore,
            ))
        .toList();

    if (items.length >= 10) {
      state = GameState.initial(genre.id, items);
    }
  }

  void placeItem(int rank) {
    if (state != null) {
      state = state!.placeItem(rank);
    }
  }

  void resetGame() {
    state = null;
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState?>(() {
  return GameNotifier();
});
