import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
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
