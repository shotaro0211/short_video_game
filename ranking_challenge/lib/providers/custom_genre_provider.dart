import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_genre.dart';
import '../repositories/custom_genre_repository.dart';

class CustomGenreNotifier extends AsyncNotifier<List<CustomGenre>> {
  final _repository = CustomGenreRepository();

  @override
  Future<List<CustomGenre>> build() async {
    return await _repository.loadGenres();
  }

  Future<void> addGenre(CustomGenre genre) async {
    await _repository.addGenre(genre);
    state = AsyncValue.data(await _repository.loadGenres());
  }

  Future<void> updateGenre(CustomGenre genre) async {
    await _repository.updateGenre(genre);
    state = AsyncValue.data(await _repository.loadGenres());
  }

  Future<void> deleteGenre(String id) async {
    await _repository.deleteGenre(id);
    state = AsyncValue.data(await _repository.loadGenres());
  }
}

final customGenreProvider =
    AsyncNotifierProvider<CustomGenreNotifier, List<CustomGenre>>(() {
  return CustomGenreNotifier();
});
