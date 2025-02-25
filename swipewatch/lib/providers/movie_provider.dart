import 'package:flutter/material.dart';

class MovieProvider with ChangeNotifier {
  List<Map<String, dynamic>> likedMovies = [];
  List<Map<String, dynamic>> dislikedMovies = [];
  List<Map<String, dynamic>> superLikedMovies = [];
  List<Map<String, dynamic>> unseenMovies = [];

  // Fonction pour vérifier si un film est déjà dans la liste
  bool isMovieInList(List<Map<String, dynamic>> list, Map<String, dynamic> movie) {
    return list.any((m) => m['title'] == movie['title']);
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
    }
    notifyListeners();
  }
}
