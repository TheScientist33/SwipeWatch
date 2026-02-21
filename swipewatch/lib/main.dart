import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';
import 'package:swipewatch/screens/category_selection_screen.dart';
import 'package:swipewatch/screens/splash_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "api_key.env");
  } catch (e) {
    print("Warning: Impossible de charger api_key.env: $e");
  }
  
  const apiKey = "b56548a8df08a342516316ebd40198ef"; // Fallback/Legacy
  runApp(const MyApp(apiKey: apiKey));
}

class MyApp extends StatelessWidget {
  final String apiKey;

  const MyApp({Key? key, required this.apiKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SwipeWatch',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SwipeWatchSplashScreen(
          next: CategorySelectionScreen(),
        ),
      ),
    );
  }
}