import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';

class DraggableCardDemo extends StatefulWidget {
  final List<Map<String, dynamic>> movies;

  const DraggableCardDemo({Key? key, required this.movies}) : super(key: key);

  @override
  State<DraggableCardDemo> createState() => _DraggableCardDemoState();
}

class _DraggableCardDemoState extends State<DraggableCardDemo> {
  int currentIndex = 0;
  Offset cardOffset = Offset.zero;
  bool isFlipped = false;

  // Déplacer la carte
  void updatePosition(DragUpdateDetails details) {
    setState(() {
      cardOffset += details.delta;
    });
  }

  // Gérer la fin du mouvement
void handlePanEnd() {
  if (widget.movies.isEmpty) {
    print("Aucun film à afficher !");
    return;
  }

  print("Nombre total de films : ${widget.movies.length}");
  print("Index actuel : $currentIndex");
  final provider = Provider.of<MovieProvider>(context, listen: false);
  String action = "";

  if (cardOffset.dx > 150) {
    action = "like"; // Swipe droite
  } else if (cardOffset.dx < -150) {
    action = "dislike"; // Swipe gauche
  } else if (cardOffset.dy < -150) {
    action = "superlike"; // Swipe haut
  } else if (cardOffset.dy > 150) {
    action = "unseen"; // Swipe bas
  }

  if (action.isNotEmpty) {
    provider.addMovie(widget.movies[currentIndex], action); // Ajout dans la bonne liste
    moveToNextCard(); // Passe au film suivant
  } else {
    resetPosition(); // Remet la carte au centre si le swipe est annulé
  }
}

void moveToNextCard() {
  if (!mounted) {
    print("Le widget a été démonté, annulation du changement de carte.");
    return;
  }

  print("Avant setState - currentIndex : $currentIndex");

  setState(() {
    cardOffset = Offset.zero;
    isFlipped = false;

    if (currentIndex + 1 < widget.movies.length) {
      currentIndex++;
      print("Film affiché après swipe : ${widget.movies[currentIndex]['title']}");
      print("Après setState - currentIndex : $currentIndex");
    } else {
      print("Liste terminée, retour au début !");
      currentIndex = 0;
    }
  });
}

  // Réinitialiser la position
  void resetPosition() {
    setState(() {
      cardOffset = Offset.zero;
    });
  }

  // Bascule entre le recto et le verso
  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int remainingCards = widget.movies.length - currentIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Une seule carte en arrière-plan
        if (currentIndex + 1 < widget.movies.length)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 150,
            top: MediaQuery.of(context).size.height / 2 - 200 + 10,
            child: Transform.scale(
              scale: 0.95,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 300,
                    height: 450,
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${widget.movies[currentIndex + 1]['poster_path']}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Carte draggable (active) avec flipping
        if (remainingCards > 0)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 150 + cardOffset.dx,
            top: MediaQuery.of(context).size.height / 2 - 200 + cardOffset.dy,
            child: GestureDetector(
              key: ValueKey(currentIndex), // 🔥 Clé dynamique pour forcer la reconstruction
              onTap: flipCard,
              onPanUpdate: updatePosition,
              onPanEnd: (_) => handlePanEnd(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isFlipped
                  ? BackCard(
                      key: UniqueKey(), // 🔥 Forcer la reconstruction complète de la carte
                      movie: widget.movies[currentIndex],
                    )
                  : FrontCard(
                      key: UniqueKey(),
                      movie: widget.movies[currentIndex],
                    ),
              ),
            ),
          ),
      ],
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
          height: 450,
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
        child: Container(
          width: 300,
          height: 450,
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
                child: SingleChildScrollView(
                  child: Text(
                    movie['overview'] ?? 'Pas de description disponible',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
    );
  }
}