import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  List<Movie> _allMovies = [];
  List<Movie> _filtered = [];
  bool _loading = true;
  String _curCat = 'All';
  int _curNav = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searching = false;

  final List<String> _categories = [
    'All',
    'Hollywood', 'Bollywood', 'Bangla', 'South Indian',
    'Korean', 'Chinese', 'Japanese', 'Turkish', 'Thai',
    'Spanish', 'French', 'Italian', 'German', 'Russian',
    'Arabic', 'Pakistani', 'Nepali', 'Sri Lankan',
    'Action', 'Romance', 'Comedy', 'Horror', 'Thriller',
    'Drama', 'Sci-Fi', 'Fantasy', 'Adventure', 'Mystery',
    'Crime', 'Biography', 'Documentary', 'Animation',
    'Anime', 'Cartoon', 'Family', 'Kids', 'Musical',
    'Historical', 'War', 'Western', 'Sports',
    'Web Series', 'TV Show', 'Short Film', 'Live TV',
    'Course', 'Viral', '18+', 'New Release', 'Trending',
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
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

  List<Movie> _getByCat(String cat) =>
      _allMovies.where((m) =>
          m.category.toLowerCase().contains(cat.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFe50914)))
          : _buildHome(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        if (_searching)
          SliverToBoxAdapter(child: _buildSearchBar())
        else ...[
          SliverToBoxAdapter(child: _buildCategoryBar()),
          if (_curCat == 'All') ...[
            _buildSection('🔥 সব মুভি', _allMovies),
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
            _buildSection('🎭 Action', _getByCat('Action')),
            _buildSection('💕 Romance', _getByCat('Romance')),
            _buildSection('😂 Comedy', _getByCat('Comedy')),
            _buildSection('👻 Horror', _getByCat('Horror')),
            _buildSection('🔥 Thriller', _getByCat('Thriller')),
            _buildSection('🎬 Drama', _getByCat('Drama')),
            _buildSection('🚀 Sci-Fi', _getByCat('Sci-Fi')),
            _buildSection('🧙 Fantasy', _getByCat('Fantasy')),
            _buildSection('📚 Documentary', _getByCat('Documentary')),
            _buildSection('📚 Course', _getByCat('Course')),
            _buildSection('🔞 18+', _getByCat('18+')),
            _buildSection('🔥 Viral', _getByCat('Viral')),
            _buildSection('🆕 New Release', _getByCat('New Release')),
          ] else
            SliverToBoxAdapter(child: _buildGrid(_filtered)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 45, 15, 10),
      child: Row(
        children: [
          const Text('🎬 Movie App',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: Color(0xFFe50914))),
          const Spacer(),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search,
                color: Colors.white),
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
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: _doSearch,
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final on = _curCat == cat;
          return GestureDetector(
            onTap: () => _filterCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: on ? const Color(0xFFe50914) : const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat,
                style: TextStyle(
                  color: on ? Colors.white : Colors.grey,
                  fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
            child: Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: movies.length,
              itemBuilder: (_, i) => SizedBox(
                width: 110,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
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
          padding: EdgeInsets.all(30),
          child: Text('কোনো মুভি নেই',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _curNav,
      backgroundColor: const Color(0xFF141414),
      selectedItemColor: const Color(0xFFe50914),
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() => _curNav = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
            icon: Icon(Icons.download), label: 'Downloads'),
      ],
    );
  }

  void _openPlayer(Movie movie) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)));
  }
}
