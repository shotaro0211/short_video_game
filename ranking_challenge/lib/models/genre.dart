import 'package:flutter/material.dart';

class Genre {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final String description;

  const Genre({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
  });
}
