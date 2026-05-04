import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _sheetId = 'YOUR_GOOGLE_SHEET_ID';
  static const String _sheetUrl =
      'https://docs.google.com/spreadsheets/d/$_sheetId/gviz/tq?tqx=out:json';

  Future<List<Movie>> loadSheetMovies() async {
    try {
      final res = await http.get(Uri.parse(_sheetUrl));
      final text = res.body;
      final json = jsonDecode(text.substring(47, text.length - 2));
      final rows = json['table']['rows'] as List;
      return rows.map((r) {
        final c = r['c'] as List;
        return Movie(
          title: c[0]?['v'] ?? '',
          category: c[1]?['v'] ?? '',
          poster: _posterUrl(c[2]?['v'] ?? ''),
          imdbId: c[3]?['v'],
          videoUrl: c[4]?['v'],
          year: c[5]?['v']?.toString() ?? '',
          type: c[6]?['v'] ?? 'movie',
          rating: c[7]?['v']?.toString() ?? '',
          overview: c[8]?['v'],
          source: 'sheet',
        );
      }).where((m) => m.title.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  String _posterUrl(String url) {
    if (url.isEmpty) return '';
    final m = RegExp(r'[?&]id=([^&]+)|/d/([^/]+)').firstMatch(url);
    if (m != null) {
      final id = m.group(1) ?? m.group(2);
      return 'https://drive.google.com/thumbnail?id=$id&sz=w800';
    }
    if (url.startsWith('http')) return url;
    return '';
  }

  List<Movie> filterByCategory(List<Movie> movies, String category) {
    if (category == 'All') return movies;
    return movies.where((m) =>
      m.category.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }

  List<Movie> search(List<Movie> movies, String query) {
    return movies.where((m) =>
      m.title.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
