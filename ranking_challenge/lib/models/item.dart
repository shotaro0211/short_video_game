class Item {
  final String id;
  final String name;
  final String genreId;
  final String? imageUrl;
  final String? description;
  final int? popularityScore; // Used for scoring reference

  const Item({
    required this.id,
    required this.name,
    required this.genreId,
    this.imageUrl,
    this.description,
    this.popularityScore,
  });
}
