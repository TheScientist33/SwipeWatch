import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Listes")),
      body: ListView(
        children: [
          _buildMovieList("❤️ Likes", movieProvider.likedMovies),
          _buildMovieList("💔 Dislikes", movieProvider.dislikedMovies),
          _buildMovieList("✨ Superlikes", movieProvider.superLikedMovies),
          _buildMovieList("📌 Unseen", movieProvider.unseenMovies),
        ],
      ),
    );
  }

  Widget _buildMovieList(String title, List<Map<String, dynamic>> movies) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: movies.map((movie) {
        return ListTile(
          leading: Image.network(
            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          ),
          title: Text(movie['title'] ?? movie['name'] ?? 'Titre inconnu'),
          subtitle: Text("Note : ${movie['vote_average']?.toString() ?? 'N/A'} / 10"),
        );
      }).toList(),
    );
  }
}
