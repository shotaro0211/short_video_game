import 'item.dart';

class GameState {
  final String genreId;
  final List<Item> remainingItems;
  final Map<int, Item?> rankings; // 1-10 ranking slots
  final Item? currentItem;
  final bool isCompleted;

  const GameState({
    required this.genreId,
    required this.remainingItems,
    required this.rankings,
    this.currentItem,
    this.isCompleted = false,
  });

  factory GameState.initial(String genreId, List<Item> items) {
    final shuffled = List<Item>.from(items)..shuffle();
    final selected = shuffled.take(10).toList();

    return GameState(
      genreId: genreId,
      remainingItems: selected.skip(1).toList(),
      rankings: {for (var i = 1; i <= 10; i++) i: null},
      currentItem: selected.first,
      isCompleted: false,
    );
  }

  GameState placeItem(int rank) {
    if (currentItem == null || rankings[rank] != null) {
      return this;
    }

    final newRankings = Map<int, Item?>.from(rankings);
    newRankings[rank] = currentItem;

    final newRemaining = List<Item>.from(remainingItems);
    final nextItem = newRemaining.isNotEmpty ? newRemaining.removeAt(0) : null;
    final completed = nextItem == null;

    return GameState(
      genreId: genreId,
      remainingItems: newRemaining,
      rankings: newRankings,
      currentItem: nextItem,
      isCompleted: completed,
    );
  }

  int get placedCount => rankings.values.where((item) => item != null).length;

  List<int> get availableSlots =>
      rankings.entries.where((e) => e.value == null).map((e) => e.key).toList();

  int calculateScore() {
    // Score based on how well items are ordered by popularity
    int score = 0;
    final placedItems = rankings.entries
        .where((e) => e.value != null)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (placedItems.length < 2) return 100;

    // Check ordering consistency
    for (int i = 0; i < placedItems.length - 1; i++) {
      final currentScore = placedItems[i].value?.popularityScore ?? 0;
      final nextScore = placedItems[i + 1].value?.popularityScore ?? 0;
      if (currentScore >= nextScore) {
        score += 10;
      }
    }

    return score;
  }
}
