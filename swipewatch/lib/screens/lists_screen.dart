import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/screens/movie_details_screen.dart';
import 'package:swipewatch/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ListsScreen extends StatelessWidget {
  final String? initialType;

  const ListsScreen({Key? key, this.initialType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Listes")),
      body: ListView(
        children: [
          _buildMovieList(context, "❤️ Likes", movieProvider.likedMovies, "like"),
          _buildMovieList(context, "💔 Dislikes", movieProvider.dislikedMovies, "dislike"),
          _buildMovieList(context, "✨ Superlikes", movieProvider.superLikedMovies, "superlike"),
          _buildMovieList(context, "📌 Unseen", movieProvider.unseenMovies, "unseen"),
        ],
      ),
    );
  }

  Widget _buildMovieList(BuildContext context, String title, List<Map<String, dynamic>> movies, String currentKey) {
    return ExpansionTile(
      initiallyExpanded: currentKey == initialType,
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: movies.map((movie) {
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  initialListType: currentKey,
                  initialMovieId: movie['id'],
                ),
              ),
            );
          },
          leading: Image.network(
            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          ),
          title: Text(movie['title'] ?? movie['name'] ?? 'Titre inconnu'),
          subtitle: Text("Note : ${movie['vote_average']?.toString() ?? 'N/A'} / 10"),
          trailing: PopupMenuButton<String>(
            onSelected: (String action) async {
              final provider = Provider.of<MovieProvider>(context, listen: false);
              
              if (action == 'delete') {
                provider.removeFromList(movie, currentKey);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Film supprimé !")));
              } else if (action == 'watch') {
                 // Open Streaming Link Logic
                 _launchWatchLink(context, movie);
              } else {
                provider.moveMovie(movie, currentKey, action);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Film déplacé !")));
              }
            },
            itemBuilder: (BuildContext context) {
               final options = <PopupMenuEntry<String>>[];
               
               // Option Regarder direct
               options.add(const PopupMenuItem(
                 value: 'watch', 
                 child: Row(
                   children: [
                     Icon(Icons.play_arrow, color: Colors.blue),
                     SizedBox(width: 8),
                     Text('Regarder maintenant 🍿', style: TextStyle(fontWeight: FontWeight.bold)),
                   ],
                 )
               ));
               options.add(const PopupMenuDivider());

               if (currentKey != 'like') {
                 options.add(const PopupMenuItem(value: 'like', child: Text('Déplacer vers ❤️ Likes')));
               }
               if (currentKey != 'dislike') {
                 options.add(const PopupMenuItem(value: 'dislike', child: Text('Déplacer vers 💔 Dislikes')));
               }
               if (currentKey != 'superlike') {
                 options.add(const PopupMenuItem(value: 'superlike', child: Text('Déplacer vers ✨ Superlikes')));
               }
               if (currentKey != 'unseen') {
                 options.add(const PopupMenuItem(value: 'unseen', child: Text('Déplacer vers 📌 Unseen')));
               }
               options.add(const PopupMenuDivider());
               options.add(const PopupMenuItem(value: 'delete', child: Text('Supprimer 🗑️', style: TextStyle(color: Colors.red))));
               
               return options;
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _launchWatchLink(BuildContext context, Map<String, dynamic> movie) async {
    final api = ApiService();
    final isTv = movie.containsKey('name');
    final id = movie['id'];
    final title = movie['title'] ?? movie['name'] ?? 'Film';
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recherche des liens... ⏳")));

    final data = await api.getWatchProviders(id, isTv ? 'tv' : 'movie');
    
    String urlString;
    if (data != null && data['link'] != null) {
      urlString = data['link'];
    } else {
      // Smart Fallback si pas de lien TMDB
      urlString = 'https://www.google.com/search?q=regarder+${Uri.encodeComponent(title)}+streaming';
    }

    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le lien')));
    }
  }
}
