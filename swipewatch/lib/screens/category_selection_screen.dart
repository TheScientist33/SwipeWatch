import 'package:flutter/material.dart';
import 'package:swipewatch/screens/home_screen.dart';
import 'package:swipewatch/services/api_service.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ApiService api = ApiService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond sombre premium
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bonjour 👋",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16, // Reduced font size
                ),
              ),
              const SizedBox(height: 4), // Reduced spacing
              const Text(
                "Que veux-tu regarder ?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Reduced spacing
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 8, // Very tight vertical spacing
                childAspectRatio: 2.5, // Ultra wide/short cards to fit height
                children: [
                  _buildCategoryCard(
                    context,
                    "Films",
                    Icons.movie_outlined,
                    [const Color(0xFFFBE8A6), const Color(0xFFEBC17B)], // Golden Sand to Honey
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          title: "Films Populaires",
                          fetchFunction: api.getPopularMovies,
                        ),
                      ),
                    ),
                  ),
                  _buildCategoryCard(
                    context,
                    "Séries",
                    Icons.tv,
                    [const Color(0xFFEBC17B), const Color(0xFFD49A5A)], // Honey to Caramel
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          title: "Séries TV",
                          fetchFunction: api.getPopularSeries,
                        ),
                      ),
                    ),
                  ),
                  _buildCategoryCard(
                    context,
                    "Animes",
                    Icons.whatshot, 
                    [const Color(0xFFD49A5A), const Color(0xFFB5733A)], // Caramel to Cinnamon
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          title: "Animes & Isekai",
                          fetchFunction: api.getAnimes,
                        ),
                      ),
                    ),
                  ),
                  _buildCategoryCard(
                    context,
                    "Animation",
                    Icons.auto_awesome,
                    [const Color(0xFFB5733A), const Color(0xFF8E5122)], // Cinnamon to Chestnut
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          title: "Films d'Animation",
                          fetchFunction: api.getAnimationMovies,
                        ),
                      ),
                    ),
                  ),
                  _buildCategoryCard(
                    context,
                    "À l'affiche",
                    Icons.local_movies_outlined,
                    [const Color(0xFF8E5122), const Color(0xFF5E3211)], // Chestnut to Dark Walnut
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          title: "À l'affiche",
                          fetchFunction: api.getNowPlayingMovies,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
