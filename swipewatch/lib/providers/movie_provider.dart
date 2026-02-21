import 'package:flutter/material.dart';

class MovieProvider with ChangeNotifier {
  List<Map<String, dynamic>> likedMovies = [];
  List<Map<String, dynamic>> dislikedMovies = [];
  List<Map<String, dynamic>> superLikedMovies = [];
  List<Map<String, dynamic>> unseenMovies = [];
  List<Map<String, dynamic>> favoriteMovies = [];

  // Custom dynamically created lists Mapping (ListName -> Movies)
  Map<String, List<Map<String, dynamic>>> customLists = {};

  // Fonction pour vérifier si un film est déjà dans la liste
  bool isMovieInList(List<Map<String, dynamic>> list, Map<String, dynamic> movie) {
    if (movie['id'] == null) return false;
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
      default:
        // Handle custom lists
        if (customLists.containsKey(action)) {
           if (!isMovieInList(customLists[action]!, movie)) {
             customLists[action]!.add(movie);
           }
        } else {
           print("Warning: Attempted to add to a list that does not exist: $action");
        }
        break;
    }
    notifyListeners();
  }

  // Helper pour récupérer la bonne liste selon le type
  List<Map<String, dynamic>> getListByType(String type) {
    switch (type) {
      case "like": return likedMovies;
      case "dislike": return dislikedMovies;
      case "superlike": return superLikedMovies;
      case "unseen": return unseenMovies;
      case "favorite": return favoriteMovies;
      default: return customLists[type] ?? [];
    }
  }

  void removeFromList(Map<String, dynamic> movie, String type) {
    final list = getListByType(type);
    list.removeWhere((m) => m['id'] == movie['id']);
    notifyListeners();
  }

  void moveMovie(Map<String, dynamic> movie, String oldType, String newType) {
    removeFromList(movie, oldType);
    addMovie(movie, newType);
  }

  // --- CUSTOM LISTS MANAGEMENT ---
  void createCustomList(String listName) {
    if (listName.isNotEmpty && !customLists.containsKey(listName)) {
      customLists[listName] = [];
      notifyListeners();
    }
  }

  void deleteCustomList(String listName) {
    if (customLists.containsKey(listName)) {
      customLists.remove(listName);
      notifyListeners();
    }
  }
}
