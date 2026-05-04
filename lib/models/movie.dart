class Movie {
  final String title;
  final String category;
  final String poster;
  final String? videoUrl;
  final String year;
  final String type;
  final String? imdbId;
  final int? tmdbId;
  final String rating;
  final String? overview;
  final String source;

  Movie({
    required this.title,
    required this.category,
    required this.poster,
    this.videoUrl,
    required this.year,
    required this.type,
    this.imdbId,
    this.tmdbId,
    required this.rating,
    this.overview,
    required this.source,
  });
}
