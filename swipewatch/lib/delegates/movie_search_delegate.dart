import 'package:flutter/material.dart';
import 'package:swipewatch/services/api_service.dart';
import 'package:swipewatch/screens/details_screen.dart';

class MovieSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final ApiService _apiService = ApiService();

  @override
  String get searchFieldLabel => 'Rechercher un film ou une série...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.black),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Saisissez un titre pour rechercher."));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apiService.searchContent(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Erreur lors de la recherche."));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun résultat trouvé."));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            final title = item['title'] ?? item['name'] ?? 'Inconnu';
            final posterPath = item['poster_path'];
            final mediaType = item['media_type'];
            final voteAverage = item['vote_average'];

            // Skip people
            if (mediaType == 'person') return const SizedBox.shrink();

            return ListTile(
              leading: posterPath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w92$posterPath',
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 50),
                    )
                  : const Icon(Icons.movie, size: 50),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(mediaType == 'tv' ? 'Série TV' : 'Film'),
              trailing: voteAverage != null 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (voteAverage as num).toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ]
                  ) 
                : null,
              onTap: () {
                // Navigate to DetailsScreen to view the selected movie
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(movie: item),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Saisissez un titre pour rechercher."));
    }
    // Affichage des suggestions en temps réel
    return buildResults(context);
  }
}
