import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/services/data_service.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/widgets/swiper.dart';
import 'package:swipewatch/screens/lists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _moviesFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _moviesFuture = _dataService.loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwipeWatch'),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erreur de chargement des films'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun film trouvé'));
                }

                final movies = snapshot.data!;
                return DraggableCardDemo(movies: movies);
              },
            ),
          ),

          // Affichage des compteurs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[200], // Fond gris léger
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCounter(context, "❤️ Likes", "like"),
                _buildCounter(context, "💔 Dislikes", "dislike"),
                _buildCounter(context, "✨ Superlikes", "superlike"),
                _buildCounter(context, "📌 Unseen", "unseen"),
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
          case "like":
            count = movieProvider.likedMovies.length;
            break;
          case "dislike":
            count = movieProvider.dislikedMovies.length;
            break;
          case "superlike":
            count = movieProvider.superLikedMovies.length;
            break;
          case "unseen":
            count = movieProvider.unseenMovies.length;
            break;
        }

        return Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        );
      },
    );
  }
}
