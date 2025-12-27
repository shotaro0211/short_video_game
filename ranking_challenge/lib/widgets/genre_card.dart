import 'package:flutter/material.dart';
import '../models/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;
  final VoidCallback onTap;

  const GenreCard({
    super.key,
    required this.genre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              genre.color,
              genre.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: genre.color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              genre.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              genre.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                genre.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
