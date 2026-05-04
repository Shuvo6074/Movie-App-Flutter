import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<Movie> _allMovies = [];
  List<Movie> _filtered = [];
  bool _loading = true;
  String _curCat = 'All';
  int _curNav = 0;
  int _bannerIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searching = false;
  late PageController _bannerCtrl;

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'emoji': '🎬'},
    {'name': 'Trending', 'emoji': '🔥'},
    {'name': 'New Release', 'emoji': '🆕'},
    {'name': 'Hollywood', 'emoji': '🎬'},
    {'name': 'Bollywood', 'emoji': '🎪'},
    {'name': 'Bangla', 'emoji': '🎭'},
    {'name': 'South Indian', 'emoji': '🇮🇳'},
    {'name': 'Korean', 'emoji': '🇰🇷'},
    {'name': 'Chinese', 'emoji': '🇨🇳'},
    {'name': 'Japanese', 'emoji': '🇯🇵'},
    {'name': 'Turkish', 'emoji': '🇹🇷'},
    {'name': 'Thai', 'emoji': '🇹🇭'},
    {'name': 'Spanish', 'emoji': '🇪🇸'},
    {'name': 'French', 'emoji': '🇫🇷'},
    {'name': 'Arabic', 'emoji': '🇸🇦'},
    {'name': 'Pakistani', 'emoji': '🇵🇰'},
    {'name': 'Anime', 'emoji': '🎌'},
    {'name': 'Cartoon', 'emoji': '🎨'},
    {'name': 'Web Series', 'emoji': '📺'},
    {'name': 'TV Show', 'emoji': '📡'},
    {'name': 'Action', 'emoji': '💥'},
    {'name': 'Romance', 'emoji': '💕'},
    {'name': 'Comedy', 'emoji': '😂'},
    {'name': 'Horror', 'emoji': '👻'},
    {'name': 'Thriller', 'emoji': '😱'},
    {'name': 'Drama', 'emoji': '🎭'},
    {'name': 'Sci-Fi', 'emoji': '🚀'},
    {'name': 'Fantasy', 'emoji': '🧙'},
    {'name': 'Adventure', 'emoji': '🗺️'},
    {'name': 'Crime', 'emoji': '🔍'},
    {'name': 'Biography', 'emoji': '📖'},
    {'name': 'Documentary', 'emoji': '🎥'},
    {'name': 'Animation', 'emoji': '✨'},
    {'name': 'Family', 'emoji': '👨‍👩‍👧'},
    {'name': 'Kids', 'emoji': '🧒'},
    {'name': 'Sports', 'emoji': '⚽'},
    {'name': 'War', 'emoji': '⚔️'},
    {'name': 'Historical', 'emoji': '🏛️'},
    {'name': 'Short Film', 'emoji': '🎞️'},
    {'name': 'Course', 'emoji': '📚'},
    {'name': 'Viral', 'emoji': '🔥'},
    {'name': '18+', 'emoji': '🔞'},
  ];

  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController();
    _loadMovies();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() => _loading = true);
    final movies = await _api.loadSheetMovies();
    setState(() {
      _allMovies = movies;
      _filtered = movies;
      _loading = false;
    });
  }

  void _filterCategory(String cat) {
    setState(() {
      _curCat = cat;
      _filtered = _api.filterByCategory(_allMovies, cat);
    });
  }

  void _doSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _api.filterByCategory(_allMovies, _curCat)
          : _api.search(_allMovies, q);
    });
  }

  List<Movie> _getByCat(String cat) => _allMovies
      .where((m) => m.category.toLowerCase().contains(cat.toLowerCase()))
      .toList();

  List<Movie> get _bannerMovies => _allMovies.take(10).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: _loading
          ? _buildLoading()
          : _curNav == 1
              ? _buildSearch()
              : _curNav == 2
                  ? _buildDownloads()
                  : _buildHome(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFe50914)),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadMovies,
      color: const Color(0xFFe50914),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          if (_searching)
            SliverToBoxAdapter(child: _buildSearchBar())
          else ...[
            if (_bannerMovies.isNotEmpty)
              SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildCategoryBar()),
            if (_curCat == 'All') ...[
              _buildSection('🔥 Trending', _getByCat('Trending')),
              _buildSection('🆕 New Release', _getByCat('New Release')),
              _buildSection('🎬 Hollywood', _getByCat('Hollywood')),
              _buildSection('🎪 Bollywood', _getByCat('Bollywood')),
              _buildSection('🎭 Bangla', _getByCat('Bangla')),
              _buildSection('🇮🇳 South Indian', _getByCat('South Indian')),
              _buildSection('🇰🇷 Korean', _getByCat('Korean')),
              _buildSection('🇨🇳 Chinese', _getByCat('Chinese')),
              _buildSection('🇯🇵 Japanese', _getByCat('Japanese')),
              _buildSection('🇹🇷 Turkish', _getByCat('Turkish')),
              _buildSection('🎌 Anime', _getByCat('Anime')),
              _buildSection('🎨 Cartoon', _getByCat('Cartoon')),
              _buildSection('📺 Web Series', _getByCat('Web Series')),
              _buildSection('💥 Action', _getByCat('Action')),
              _buildSection('💕 Romance', _getByCat('Romance')),
              _buildSection('😂 Comedy', _getByCat('Comedy')),
              _buildSection('👻 Horror', _getByCat('Horror')),
              _buildSection('🚀 Sci-Fi', _getByCat('Sci-Fi')),
              _buildSection('📚 Course', _getByCat('Course')),
              _buildSection('🔞 18+', _getByCat('18+')),
              _buildSection('🔥 Viral', _getByCat('Viral')),
            ] else
              SliverToBoxAdapter(child: _buildGrid(_filtered)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 50, 15, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141414), Color(0xFF0a0a0a)],
        ),
      ),
      child: Row(
        children: [
          const Text('🎬',style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Text('Movie App',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFe50914),
              letterSpacing: 1,
            )),
          const Spacer(),
          IconButton(
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              color: Colors.white, size: 26),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) { _searchCtrl.clear(); _doSearch(''); }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'মুভি খুঁজুন...',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1e1e1e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFe50914)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchCtrl.clear();
                    _doSearch('');
                  })
              : null,
        ),
        onChanged: _doSearch,
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerCtrl,
            itemCount: _bannerMovies.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final m = _bannerMovies[i];
              return GestureDetector(
                onTap: () => _openPlayer(m),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    m.poster.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: m.poster,
                            fit: BoxFit.cover,
                          )
                        : Container(color: const Color(0xFF252525)),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xCC000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15, left: 15, right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFe50914),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(m.category,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          Text(m.title,
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              if (m.rating.isNotEmpty)
                                Text('⭐ ${m.rating}',
                                  style: const TextStyle(
                                      color: Color(0xFFffd700), fontSize: 12)),
                              const SizedBox(width: 8),
                              Text(m.year,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerMovies.length, (i) =>
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _bannerIndex == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _bannerIndex == i
                        ? const Color(0xFFe50914)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final on = _curCat == cat['name'];
          return GestureDetector(
            onTap: () => _filterCategory(cat['name']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: on ? const Color(0xFFe50914) : const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: on ? const Color(0xFFe50914) : Colors.transparent,
                ),
              ),
              child: Text(
                '${cat['emoji']} ${cat['name']}',
                style: TextStyle(
                  color: on ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: on ? FontWeight.bold : FontWeight.normal,
                )),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Row(
              children: [
                Text(title,
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('সব দেখুন',
                  style: TextStyle(
                    fontSize: 12, color: Colors.grey[400])),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
              ],
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: movies.length,
              itemBuilder: (_, i) => SizedBox(
                width: 115,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MovieCard(
                    movie: movies[i],
                    onTap: () => _openPlayer(movies[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [
              Icon(Icons.movie_filter, color: Colors.grey, size: 60),
              SizedBox(height: 16),
              Text('কোনো মুভি পাওয়া যায়নি',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: movies.length,
      itemBuilder: (_, i) => MovieCard(
        movie: movies[i],
        onTap: () => _openPlayer(movies[i]),
      ),
    );
  }

  Widget _buildSearch() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'মুভি, সিরিজ খুঁজুন...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1e1e1e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFe50914)),
              ),
              onChanged: _doSearch,
            ),
          ),
          Expanded(child: _buildGrid(_filtered)),
        ],
      ),
    );
  }

  Widget _buildDownloads() {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done, color: Colors.grey, size: 60),
            SizedBox(height: 16),
            Text('কোনো ডাউনলোড নেই',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: Color(0xFF2a2a2a))),
      ),
      child: BottomNavigationBar(
        currentIndex: _curNav,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFe50914),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _curNav = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded), label: 'Downloads'),
        ],
      ),
    );
  }

  void _openPlayer(Movie movie) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)));
  }
}
