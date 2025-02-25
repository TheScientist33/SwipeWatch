import 'dart:convert';
import 'package:flutter/services.dart';

class DataService {
  Future<List<Map<String, dynamic>>> loadMovies() async {
    final String response = await rootBundle.loadString('assets/movies_dataset.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<Map<String, dynamic>>();
  }
}
