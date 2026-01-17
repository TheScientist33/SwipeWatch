import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = "https://api.themoviedb.org/3";
  // Fallback to empty string to avoid crashes if env is missing, but should be handled by caller
  String get apiKey => dotenv.env['TMDB_API_KEY'] ?? "";

  // Helper generique
  Future<List<Map<String, dynamic>>> _get(String endpoint, {Map<String, String>? params, int page = 1}) async {
    final queryParams = {
      'api_key': apiKey,
      'language': 'fr-FR', // On force le français
      'page': page.toString(),
      ...?params,
    };

    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur réseau: $e");
      throw Exception('Erreur de connexion');
    }
  }

  // 1. Films Populaires (Défaut)
  Future<List<Map<String, dynamic>>> getPopularMovies({int page = 1}) async {
    return _get('/movie/popular', page: page);
  }

  // 2. Séries TV Populaires
  Future<List<Map<String, dynamic>>> getPopularSeries({int page = 1}) async {
    return _get('/tv/popular', page: page);
  }

  // 3. Animation / Anime
  Future<List<Map<String, dynamic>>> getAnimes({int page = 1}) async {
    return _get('/discover/tv', page: page, params: {
      'with_genres': '16', // Animation
      'with_keywords': '210024', // Isekai keyword ID
      'sort_by': 'popularity.desc'
    });
  }
  
  // 4. Films d'Animation (Disney, Pixar...)
  Future<List<Map<String, dynamic>>> getAnimationMovies({int page = 1}) async {
    return _get('/discover/movie', page: page, params: {
      'with_genres': '16', // Animation
      'sort_by': 'popularity.desc'
    });
  }

  // Recherche textuelle
  Future<List<Map<String, dynamic>>> searchContent(String query) async {
    return _get('/search/multi', params: {'query': query});
  }
}
