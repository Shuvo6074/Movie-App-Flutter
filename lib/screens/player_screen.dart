import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {

  @override
  void initState() {
    super.initState();
    _openVideo();
  }

  Future<void> _openVideo() async {
    final url = _getVideoUrl();
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _getVideoUrl() {
    final m = widget.movie;
    if (m.videoUrl != null && m.videoUrl!.isNotEmpty) {
      return m.videoUrl!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: Text(m.title,
          style: const TextStyle(fontSize: 15),
          overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.poster.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(m.poster, width: double.infinity,
                  height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 15),
            Text(m.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (m.rating.isNotEmpty)
              Text('⭐ ${m.rating}',
                style: const TextStyle(color: Color(0xFFffd700))),
            if (m.year.isNotEmpty)
              Text('${m.year} • ${m.category}',
                style: const TextStyle(color: Colors.grey)),
            if (m.overview != null && m.overview!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(m.overview!,
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe50914),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text('Play',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _openVideo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
