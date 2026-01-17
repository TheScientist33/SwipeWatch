import 'package:flutter/material.dart';

class MovieProvider with ChangeNotifier {
  List<Map<String, dynamic>> likedMovies = [];
  List<Map<String, dynamic>> dislikedMovies = [];
  List<Map<String, dynamic>> superLikedMovies = [];
  List<Map<String, dynamic>> unseenMovies = [];
  List<Map<String, dynamic>> favoriteMovies = [];

  // Fonction pour vérifier si un film est déjà dans la liste
  bool isMovieInList(List<Map<String, dynamic>> list, Map<String, dynamic> movie) {
    return list.any((m) => m['id'] == movie['id']);
  }

  void addMovie(Map<String, dynamic> movie, String action) {
    switch (action) {
      case "like":
        if (!isMovieInList(likedMovies, movie)) likedMovies.add(movie);
        break;
      case "dislike":
        if (!isMovieInList(dislikedMovies, movie)) dislikedMovies.add(movie);
        break;
      case "superlike":
        if (!isMovieInList(superLikedMovies, movie)) superLikedMovies.add(movie);
        break;
      case "unseen":
        if (!isMovieInList(unseenMovies, movie)) unseenMovies.add(movie);
        break;
      case "favorite":
        if (!isMovieInList(favoriteMovies, movie)) favoriteMovies.add(movie);
        break;
    }
    notifyListeners();
  }

  // Helper pour récupérer la bonne liste selon le type
  List<Map<String, dynamic>> _getListByType(String type) {
    switch (type) {
      case "like": return likedMovies;
      case "dislike": return dislikedMovies;
      case "superlike": return superLikedMovies;
      case "unseen": return unseenMovies;
      case "favorite": return favoriteMovies;
      default: return [];
    }
  }

  void removeFromList(Map<String, dynamic> movie, String type) {
    final list = _getListByType(type);
    list.removeWhere((m) => m['id'] == movie['id']);
    notifyListeners();
  }

  void moveMovie(Map<String, dynamic> movie, String oldType, String newType) {
    removeFromList(movie, oldType);
    addMovie(movie, newType);
  }
}
