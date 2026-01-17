import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String initialListType;
  final int initialMovieId;

  const MovieDetailsScreen({
    Key? key,
    required this.initialListType,
    required this.initialMovieId,
  }) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();
  
  final List<String> _listOrder = ['like', 'superlike', 'unseen', 'dislike'];
  late PageController _verticalController;
  final Map<String, PageController> _horizontalControllers = {};
  
  @override
  void initState() {
    super.initState();
    int initialListIndex = _listOrder.indexOf(widget.initialListType);
    if (initialListIndex == -1) initialListIndex = 0;
    _verticalController = PageController(initialPage: initialListIndex);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    for (var controller in _horizontalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollHorizontal(String listType, int offset) {
    final controller = _horizontalControllers[listType];
    if (controller != null && controller.hasClients) {
      controller.animateToPage(
        (controller.page ?? 0).toInt() + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollVertical(int offset) {
    if (_verticalController.hasClients) {
      _verticalController.animateToPage(
        (_verticalController.page ?? 0).toInt() + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        itemCount: _listOrder.length,
        itemBuilder: (context, verticalIndex) {
          final listType = _listOrder[verticalIndex];
          final movies = _getList(movieProvider, listType);
          
          if (movies.isEmpty) return _buildEmptyState(listType);

          // Init controller if needed
          if (!_horizontalControllers.containsKey(listType)) {
             int initialPage = 0;
             if (listType == widget.initialListType) {
               initialPage = movies.indexWhere((m) => m['id'] == widget.initialMovieId);
               if (initialPage == -1) initialPage = 0;
             }
             _horizontalControllers[listType] = PageController(initialPage: initialPage);
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Watermark
              Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: IgnorePointer(
                    child: Text(
                      _getListName(listType).toUpperCase(),
                      style: TextStyle(
                        fontSize: 100, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white.withOpacity(0.1) // Plus visible
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Carousel
              PageView.builder(
                controller: _horizontalControllers[listType],
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, horizontalIndex) {
                  return MovieDetailItem(movie: movies[horizontalIndex], apiService: _apiService);
                },
              ),

              // Arrows (Clickable)
              if (verticalIndex > 0)
                Positioned(top: 60, left: 0, right: 0, child: Center(child: IconButton(icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 40), onPressed: () => _scrollVertical(-1)))),
              if (verticalIndex < _listOrder.length - 1)
                Positioned(bottom: 20, left: 0, right: 0, child: Center(child: IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40), onPressed: () => _scrollVertical(1)))),
              
              Positioned(left: 10, top: 0, bottom: 0, child: Center(child: IconButton(icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 40), onPressed: () => _scrollHorizontal(listType, -1)))),
              Positioned(right: 10, top: 0, bottom: 0, child: Center(child: IconButton(icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 40), onPressed: () => _scrollHorizontal(listType, 1)))),
            ],
          );
        },
      ),
    );
  }

  // ... Helpers _getList, _getListName, _buildEmptyState remain the same ...
  List<Map<String, dynamic>> _getList(MovieProvider provider, String type) {
    switch (type) {
      case 'like': return provider.likedMovies;
      case 'superlike': return provider.superLikedMovies;
      case 'unseen': return provider.unseenMovies;
      case 'dislike': return provider.dislikedMovies;
      default: return [];
    }
  }

  String _getListName(String type) {
    switch (type) {
      case 'like': return 'Likes';
      case 'superlike': return 'Superlikes';
      case 'unseen': return 'À Voir';
      case 'dislike': return 'Dislikes';
      default: return '';
    }
  }

  Widget _buildEmptyState(String listType) {
    return Center(
      child: Text(
        "Liste ${_getListName(listType)} vide",
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class MovieDetailItem extends StatefulWidget {
  final Map<String, dynamic> movie;
  final ApiService apiService;

  const MovieDetailItem({Key? key, required this.movie, required this.apiService}) : super(key: key);

  @override
  State<MovieDetailItem> createState() => _MovieDetailItemState();
}

class _MovieDetailItemState extends State<MovieDetailItem> {
  Map<String, dynamic>? _providers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final isTv = widget.movie.containsKey('name');
    final id = widget.movie['id'];
    final data = await widget.apiService.getWatchProviders(id, isTv ? 'tv' : 'movie');
    if (mounted) {
      setState(() {
        _providers = data;
        _isLoading = false;
      });
    }
  }

  void _launchProvider(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le lien')));
    }
  }

  String _getSearchLink(String providerName, String title) {
    final encodedTitle = Uri.encodeComponent(title);
    switch (providerName.toLowerCase()) {
      case 'netflix': return 'https://www.netflix.com/search?q=$encodedTitle';
      case 'disney plus': return 'https://www.disneyplus.com/search?q=$encodedTitle';
      case 'amazon prime video': return 'https://www.primevideo.com/search/ref=atv_nb_sr?phrase=$encodedTitle';
      default: return 'https://www.google.com/search?q=regarder+$encodedTitle+sur+$providerName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.movie['title'] ?? widget.movie['name'] ?? 'Inconnu';
    final posterPath = widget.movie['poster_path'];
    final overview = widget.movie['overview'];
    final rating = widget.movie['vote_average']?.toStringAsFixed(1) ?? 'N/A';
    final flatrate = (_providers?['flatrate'] as List?) ?? [];

    return Stack(
      fit: StackFit.expand,
      children: [
        posterPath != null
            ? Image.network(
                'https://image.tmdb.org/t/p/original$posterPath',
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => const Center(child: Icon(Icons.movie, size: 50, color: Colors.grey)),
              )
            : Container(color: const Color(0xFF1E1E1E)),

        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black26, Colors.transparent, Colors.black87, Colors.black],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 20)])),
              const SizedBox(height: 12),
              
              Row(children: [const Icon(Icons.star, color: Colors.amber, size: 24), const SizedBox(width: 8), Text("$rating / 10", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(child: Text(overview ?? "Aucun résumé", style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4, shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
              ),
              const SizedBox(height: 24),

              if (_isLoading) 
                 const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
              else if (flatrate.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Disponible sur :", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: flatrate.map<Widget>((p) {
                        return InkWell(
                          onTap: () => _launchProvider(_getSearchLink(p['provider_name'], title)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8), 
                              border: Border.all(color: Colors.white24)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network('https://image.tmdb.org/t/p/w200${p['logo_path']}', width: 50, height: 50),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else 
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => _launchProvider('https://www.google.com/search?q=regarder+${Uri.encodeComponent(title)}+streaming'),
                    icon: const Icon(Icons.search),
                    label: const Text("Chercher sur Google"),
                  ),
                ),
                
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
