import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/services/api_service.dart';
import 'package:swipewatch/screens/movie_details_screen.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

  const DetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: MovieDetailItem(
        movie: movie,
        apiService: ApiService(),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 30, top: 10, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(context, Icons.close, Colors.white70, 'dislike', 'Dislike'),
            _buildActionButton(context, Icons.star, Colors.blue, 'superlike', 'Superlike'),
            _buildActionButton(context, Icons.favorite, Colors.red, 'like', 'Like'),
            _buildActionButton(context, Icons.bookmark, Colors.amber, 'favorite', 'À voir'),
            _buildCustomListButton(context),
            _buildShareButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 28),
            tooltip: 'Partager',
            onPressed: () {
              final title = movie['title'] ?? movie['name'] ?? 'Inconnu';
              final id = movie['id'];
              final isTv = movie.containsKey('name');
              final tmdbLink = 'https://www.themoviedb.org/${isTv ? 'tv' : 'movie'}/$id';
              Share.share('🍿 Je te conseille de regarder "$title" !\n\nPlus d\'infos ici : $tmdbLink');
            },
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Partager',
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCustomListButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
            border: Border.all(color: Colors.greenAccent, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent, size: 28),
            tooltip: 'Ajouter à une liste',
            onPressed: () => _showAddToListModal(context),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Listes...',
          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showAddToListModal(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Ajouter à une liste", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (provider.customLists.isEmpty)
                 const Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Text("Vous n'avez pas encore créé de listes personnalisées. Créez-en une dans l'onglet 'Mes Listes'.", style: TextStyle(color: Colors.white70)),
                 )
              else
                ...provider.customLists.keys.map((listName) {
                  return ListTile(
                    leading: const Icon(Icons.folder, color: Colors.blueAccent),
                    title: Text(listName, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      provider.addMovie(movie, listName);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ajouté à : $listName'), backgroundColor: Colors.green.shade800),
                      );
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color, String action, String tooltip) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            tooltip: tooltip,
            onPressed: () {
              final provider = Provider.of<MovieProvider>(context, listen: false);
              provider.addMovie(movie, action);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ajouté à : $tooltip'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green.shade800,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tooltip,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
