import 'package:flutter/material.dart';

class FlippingCardDemo extends StatefulWidget {
  final Map<String, dynamic> movie;

  const FlippingCardDemo({Key? key, required this.movie}) : super(key: key);

  @override
  State<FlippingCardDemo> createState() => _FlippingCardDemoState();
}

class _FlippingCardDemoState extends State<FlippingCardDemo> {
  bool isFlipped = false;

  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title'] ?? 'Titre inconnu'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: flipCard,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                builder: (context, child) {
                  final isFront = rotate.value < 0.5;
                  final angle = isFront
                      ? rotate.value * 3.14
                      : (1 - rotate.value) * 3.14;

                  return Transform(
                    transform: Matrix4.rotationY(angle),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: child,
              );
            },
            child: isFlipped
                ? BackCard(
              key: const ValueKey('back'),
              movie: movie,
            )
                : FrontCard(
              key: const ValueKey('front'),
              movie: movie,
            ),
          ),
        ),
      ),
    );
  }
}

class FrontCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const FrontCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 300,
          height: 400,
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class BackCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const BackCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 300,
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'] ?? 'Titre inconnu',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    movie['overview'] ?? 'Pas de description disponible',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Note : ${movie['vote_average']?.toString() ?? 'N/A'} / 10',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
