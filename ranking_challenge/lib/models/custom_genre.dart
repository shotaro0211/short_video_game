import 'dart:convert';
import 'package:flutter/material.dart';

class CustomGenre {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;
  final List<CustomItem> items;

  const CustomGenre({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.items,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory CustomGenre.fromJson(Map<String, dynamic> json) => CustomGenre(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        colorValue: json['colorValue'],
        items: (json['items'] as List)
            .map((e) => CustomItem.fromJson(e))
            .toList(),
      );

  CustomGenre copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorValue,
    List<CustomItem>? items,
  }) =>
      CustomGenre(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        colorValue: colorValue ?? this.colorValue,
        items: items ?? this.items,
      );
}

class CustomItem {
  final String id;
  final String name;
  final int popularityScore;

  const CustomItem({
    required this.id,
    required this.name,
    required this.popularityScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'popularityScore': popularityScore,
      };

  factory CustomItem.fromJson(Map<String, dynamic> json) => CustomItem(
        id: json['id'],
        name: json['name'],
        popularityScore: json['popularityScore'],
      );
}
