import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/services/api_service.dart'; // Changed from data_service
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/widgets/swiper.dart';
import 'package:swipewatch/screens/lists_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> Function({int page})? fetchFunction;

  const HomeScreen({
    Key? key, 
    this.title = 'SwipeWatch', 
    this.fetchFunction
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  // State pour la pagination
  final List<Map<String, dynamic>> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> newMovies;
      
      if (widget.fetchFunction != null) {
        // On appelle la fonction passée en paramètre avec le numéro de page
        newMovies = await widget.fetchFunction!(page: _currentPage);
      } else {
        newMovies = await _apiService.getPopularMovies(page: _currentPage);
      }

      // Filtrer les doublons potentiels (sécurité) et exclusions ID null
      final uniqueMovies = newMovies.where((newMovie) {
        return !_movies.any((existing) => existing['id'] == newMovie['id']);
      }).toList();

      if (mounted) {
        setState(() {
          _movies.addAll(uniqueMovies);
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur loading movies: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Si c'est la première page et que ça plante, on marque l'erreur
          if (_movies.isEmpty) _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasError 
                ? const Center(child: Text("Erreur de chargement 😢"))
                : _movies.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DraggableCardDemo(
                        movies: _movies,
                        onLoadMore: _loadMovies,
                      ),
          ),

          // Affichage des compteurs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCounter(context, "Likes", "like"),
                _buildCounter(context, "Dislikes", "dislike"),
                _buildCounter(context, "À voir", "favorite"),
                _buildCounter(context, "Superlikes", "superlike"),
                _buildCounter(context, "Unseen", "unseen"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher le nombre de films dans chaque liste
  Widget _buildCounter(BuildContext context, String label, String type) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        int count = 0;

        switch (type) {
          case "like": count = movieProvider.likedMovies.length; break;
          case "dislike": count = movieProvider.dislikedMovies.length; break;
          case "favorite": count = movieProvider.favoriteMovies.length; break;
          case "superlike": count = movieProvider.superLikedMovies.length; break;
          case "unseen": count = movieProvider.unseenMovies.length; break;
        }

        return Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListsScreen(initialType: type),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
