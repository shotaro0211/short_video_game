import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_genre.dart';

class CustomGenreRepository {
  static const String _key = 'custom_genres';

  Future<List<CustomGenre>> loadGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CustomGenre.fromJson(e)).toList();
  }

  Future<void> saveGenres(List<CustomGenre> genres) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(genres.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addGenre(CustomGenre genre) async {
    final genres = await loadGenres();
    genres.add(genre);
    await saveGenres(genres);
  }

  Future<void> updateGenre(CustomGenre genre) async {
    final genres = await loadGenres();
    final index = genres.indexWhere((e) => e.id == genre.id);
    if (index != -1) {
      genres[index] = genre;
      await saveGenres(genres);
    }
  }

  Future<void> deleteGenre(String id) async {
    final genres = await loadGenres();
    genres.removeWhere((e) => e.id == id);
    await saveGenres(genres);
  }
}
