import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipewatch/providers/movie_provider.dart';

class DraggableCardDemo extends StatefulWidget {
  final List<Map<String, dynamic>> movies;

  const DraggableCardDemo({Key? key, required this.movies}) : super(key: key);

  @override
  State<DraggableCardDemo> createState() => _DraggableCardDemoState();
}

class _DraggableCardDemoState extends State<DraggableCardDemo> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  Offset cardOffset = Offset.zero;
  bool isFlipped = false;

  // Déplacer la carte
  void updatePosition(DragUpdateDetails details) {
    if (!mounted) return;
    setState(() {
      cardOffset += details.delta;
    });
  }

void moveToNextCard() {
  if (!mounted) return; // ✅ Empêche le crash si le widget a été démonté

  setState(() {
    isFlipped = false;
  });

  animateCardTo(
    targetOffset: Offset(
      cardOffset.dx > 0 ? MediaQuery.of(context).size.width : -MediaQuery.of(context).size.width,
      cardOffset.dy,
    ),
    onComplete: () {
      if (!mounted) return; // ✅ Vérifie à nouveau si le widget est encore là
      setState(() {
        cardOffset = Offset.zero;
        currentIndex = (currentIndex + 1) % widget.movies.length;
      });
    },
  );
}

void animateCardTo({required Offset targetOffset, required VoidCallback onComplete}) {
  AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this, // Ajoute SingleTickerProviderStateMixin à _DraggableCardDemoState
  );

  Animation<Offset> animation = Tween<Offset>(
    begin: cardOffset,
    end: targetOffset,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

  animation.addListener(() {
    if (!mounted) return;
    setState(() {
      cardOffset = animation.value;
    });
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      onComplete();
      controller.dispose();
    }
  });

  controller.forward();
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
    moveToNextCard();
  } else {
    resetPosition(); // Remet la carte au centre si le swipe est annulé
  }
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
    print("Rendering carte index: $currentIndex");
    
    final int remainingCards = widget.movies.length - currentIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        const cardW = 300.0;
        const cardH = 450.0;

        return Stack(
          children: [
            // Carte en arrière-plan
            if (currentIndex + 1 < widget.movies.length)
              Positioned(
                left: centerX - cardW / 2,
                top: centerY - cardH / 2 + 10,
                child: Transform.scale(
                  scale: 0.95,
                  child: FrontCard(
                    movie: widget.movies[currentIndex + 1],
                  ),
                ),
              ),

            // Carte draggable (active) avec flipping
            if (remainingCards > 0)
              Positioned(
                key: ValueKey(currentIndex),
                left: centerX - cardW / 2 + cardOffset.dx,
                top: centerY - cardH / 2 + cardOffset.dy,
                child: GestureDetector(
                  // ✅ IMPORTANT : pas de UniqueKey ici
                  onTap: flipCard,
                  onPanUpdate: updatePosition,
                  onPanEnd: (_) => handlePanEnd(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: isFlipped
                        ? BackCard(
                      key: const ValueKey('back'),
                      movie: widget.movies[currentIndex],
                    )
                        : FrontCard(
                      key: const ValueKey('front'),
                      movie: widget.movies[currentIndex],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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