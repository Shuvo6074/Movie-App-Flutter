import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late WebViewController _webCtrl;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _blockAds(),
        onNavigationRequest: (req) {
          final url = req.url;
          if (url.contains('doubleclick') ||
              url.contains('googlesyndication') ||
              url.contains('popunder') ||
              url.contains('1xbet') ||
              url.contains('casino')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(_getVideoUrl()));
  }

  void _blockAds() {
    _webCtrl.runJavaScript('''
      (function() {
        var style = document.createElement('style');
        style.innerHTML = `.overlay,.popup,[class*="popup"],[class*="overlay"],[id*="popup"],[id*="overlay"],.ads,[class*="ads"],[id*="ads"],.banner,[class*="banner"],div[style*="z-index: 9999"],div[style*="z-index:9999"]{display:none!important;pointer-events:none!important;}`;
        document.head.appendChild(style);
        window.open=function(){return null;};
        window.alert=function(){};
        window.confirm=function(){return false;};
      })();
    ''');
  }

  String _getVideoUrl() {
    final m = widget.movie;
    if (m.videoUrl != null && m.videoUrl!.isNotEmpty) {
      return _buildVideoUrl(m.videoUrl!);
    }
    return 'about:blank';
  }

  String _buildVideoUrl(String url) {
    final yt = RegExp(r'(?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/))([^&\n?#]+)')
        .firstMatch(url);
    if (yt != null) return 'https://www.youtube.com/embed/${yt.group(1)}?autoplay=1';

    final gd = RegExp(r'/d/([^/]+)|[?&]id=([^&]+)').firstMatch(url);
    if (gd != null) {
      final id = gd.group(1) ?? gd.group(2);
      return 'https://drive.google.com/file/d/$id/preview';
    }
    return url;
  }

  void _toggleOrientation() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    setState(() => _isLandscape = !_isLandscape);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPlayer(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF141414),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.movie.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: Icon(_isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white),
            onPressed: _toggleOrientation,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: WebViewWidget(controller: _webCtrl),
      ),
    );
  }

  Widget _buildInfo() {
    final m = widget.movie;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          if (m.rating.isNotEmpty)
            Text('⭐ ${m.rating}',
              style: const TextStyle(color: Color(0xFFffd700), fontSize: 13)),
          if (m.year.isNotEmpty || m.category.isNotEmpty)
            Text('${m.year}  ${m.category}',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          if (m.overview != null && m.overview!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(m.overview!,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF444444)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.share, size: 18, color: Colors.white),
            label: const Text('Share', style: TextStyle(color: Colors.white)),
            onPressed: () => Share.share('Watch ${widget.movie.title} on Movie App!'),
          ),
        ],
      ),
    );
  }
}
