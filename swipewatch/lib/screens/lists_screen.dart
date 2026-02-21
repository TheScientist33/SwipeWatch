import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/screens/movie_details_screen.dart';
import 'package:swipewatch/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
          // Default lists
          _buildMovieList(context, "🌟 À voir", movieProvider.favoriteMovies, "favorite"),
          _buildMovieList(context, "❤️ Likes", movieProvider.likedMovies, "like"),
          _buildMovieList(context, "💔 Dislikes", movieProvider.dislikedMovies, "dislike"),
          _buildMovieList(context, "✨ Superlikes", movieProvider.superLikedMovies, "superlike"),
          _buildMovieList(context, "📌 Unseen", movieProvider.unseenMovies, "unseen"),
          
          // Custom lists
          if (movieProvider.customLists.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Mes Listes Personnalisées", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ),
          ...movieProvider.customLists.entries.map((entry) {
            return _buildMovieList(context, "📁 ${entry.key}", entry.value, entry.key, isCustom: true);
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context, movieProvider),
        icon: const Icon(Icons.add),
        label: const Text("Créer une liste"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, MovieProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouvelle Liste"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nom de la liste (ex: Films d'horreur)"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  provider.createCustomList(name);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Liste '$name' créée !")));
                }
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovieList(BuildContext context, String title, List<Map<String, dynamic>> movies, String currentKey, {bool isCustom = false}) {
    return ExpansionTile(
      initiallyExpanded: currentKey == initialType,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 20, color: Colors.blue),
                onPressed: () => _shareList(title, movies),
              ),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    showDialog(context: context, builder: (context) => AlertDialog(
                      title: const Text("Supprimer la liste"),
                      content: Text("Voulez-vous vraiment supprimer la liste '$title' ?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                        TextButton(
                          onPressed: () {
                            Provider.of<MovieProvider>(context, listen: false).deleteCustomList(currentKey);
                            Navigator.pop(context);
                          }, 
                          child: const Text("Supprimer", style: TextStyle(color: Colors.red))
                        ),
                      ]
                    ));
                  },
                ),
            ],
          )
        ],
      ),
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
              } else if (action == 'share') {
                 _shareMovie(movie);
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
               
               // Options standards
               if (currentKey != 'favorite') {
                 options.add(const PopupMenuItem(value: 'favorite', child: Text('Déplacer vers 🌟 À voir')));
               }
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
               
               // Options listes persos
               final provider = Provider.of<MovieProvider>(context, listen: false);
               for (var listName in provider.customLists.keys) {
                 if (currentKey != listName) {
                    options.add(PopupMenuItem(value: listName, child: Text('Déplacer vers 📁 $listName')));
                 }
               }

               options.add(const PopupMenuDivider());
               options.add(const PopupMenuItem(value: 'share', child: Text('Partager 🔗', style: TextStyle(color: Colors.blue))));
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

  void _shareList(String title, List<Map<String, dynamic>> movies) {
    if (movies.isEmpty) {
      Share.share("La liste $title est complètement vide !");
      return;
    }
    
    String shareText = '🎬 Voici ma liste "$title" sur SwipeWatch :\n\n';
    for (var i = 0; i < movies.length; i++) {
       final movie = movies[i];
       final titleFilm = movie['title'] ?? movie['name'] ?? 'Inconnu';
       final note = movie['vote_average']?.toString() ?? 'N/A';
       shareText += '${i+1}. $titleFilm (⭐ $note/10)\n';
    }
    shareText += '\nRegarde vite ça ! 👀';
    
    Share.share(shareText);
  }

  void _shareMovie(Map<String, dynamic> movie) {
    final title = movie['title'] ?? movie['name'] ?? 'Inconnu';
    final id = movie['id'];
    final isTv = movie.containsKey('name');
    final tmdbLink = 'https://www.themoviedb.org/${isTv ? 'tv' : 'movie'}/$id';
    
    Share.share('🍿 Je te conseille de regarder "$title" !\n\nPlus d\'infos ici : $tmdbLink');
  }
}
