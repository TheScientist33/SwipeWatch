import 'dart:ui';
import 'package:flutter/material.dart';

class SwipeWatchSplashScreen extends StatefulWidget {
  const SwipeWatchSplashScreen({
    super.key,
    required this.next,
    this.duration = const Duration(milliseconds: 2400),
  });

  final Widget next;
  final Duration duration;

  @override
  State<SwipeWatchSplashScreen> createState() => _SwipeWatchSplashScreenState();
}

class _SwipeWatchSplashScreenState extends State<SwipeWatchSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  late final Animation<double> _bgBreath;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardGlow;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: widget.duration);

    // Fond "respiration" (très lent)
    _bgBreath = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    // Carte qui apparaît
    _cardOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.05, 0.30, curve: Curves.easeOut),
    );

    _cardScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Micro swipe (droite puis retour) via TweenSequence
    _cardSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.08, 0.0))
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.08, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.30, 0.62),
      ),
    );

    // Glow léger pendant le swipe
    _cardGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.30, 0.62, curve: Curves.easeInOut),
      ),
    );

    // Logo/texte qui apparaît après le swipe
    _logoOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.58, 0.85, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.58, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Petit fondu de sortie (pour une transition plus douce)
    _fadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );

    _c.forward();

    // Transition vers l'écran suivant à la fin
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(_softRoute(widget.next));
      }
    });
  }

  PageRouteBuilder _softRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final fade = (1.0 - _fadeOut.value).clamp(0.0, 1.0);

          // Respiration du fond
          final breath = lerpDouble(0.0, 1.0, _bgBreath.value)!;
          final blurSigma = lerpDouble(10.0, 18.0, breath)!;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Fond dégradé
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0B1020),
                      Color.lerp(const Color(0xFF121A33), const Color(0xFF0F1830), breath)!,
                      const Color(0xFF05070F),
                    ],
                  ),
                ),
              ),

              // “Glow” diffus qui bouge très lentement (zen)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.22 * fade,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.2, -0.2),
                          radius: 0.9,
                          colors: [
                            Color(0xFF2A66FF),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Contenu centré
              Center(
                child: Opacity(
                  opacity: fade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Carte animée
                      Opacity(
                        opacity: _cardOpacity.value,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: Transform.scale(
                            scale: _cardScale.value,
                            child: _LogoCard(glow: _cardGlow.value),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Logo/nom
                      Opacity(
                        opacity: _logoOpacity.value * fade,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Column(
                            children: [
                              Text(
                                "SwipeWatch",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Find your next movie",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  letterSpacing: 0.5,
                                  color: Colors.white.withOpacity(0.62),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Petit indicateur discret (optionnel)
                      Opacity(
                        opacity: (_logoOpacity.value) * 0.8 * fade,
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.glow});

  final double glow;

  @override
  Widget build(BuildContext context) {
    final glowOpacity = lerpDouble(0.0, 0.35, glow)!;
    final glowBlur = lerpDouble(10.0, 22.0, glow)!;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A66FF).withOpacity(glowOpacity),
            blurRadius: glowBlur,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        // Icône “film + swipe” minimaliste
        child: SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _SwipeFilmPainter(),
          ),
        ),
      ),
    );
  }
}

class _SwipeFilmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Rectangle "film"
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.18, size.width * 0.76, size.height * 0.62),
      const Radius.circular(10),
    );
    canvas.drawRRect(r, paint);

    // Perforations film (points à gauche)
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.70)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final dy = size.height * (0.28 + i * 0.14);
      canvas.drawCircle(Offset(size.width * 0.18, dy), 2.2, dotPaint);
    }

    // Flèche "swipe" (droite)
    final path = Path();
    final y = size.height * 0.78;
    path.moveTo(size.width * 0.18, y);
    path.lineTo(size.width * 0.78, y);
    path.moveTo(size.width * 0.78, y);
    path.lineTo(size.width * 0.70, y - 0.08 * size.height);
    path.moveTo(size.width * 0.78, y);
    path.lineTo(size.width * 0.70, y + 0.08 * size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SwipeFilmPainter oldDelegate) => false;
}
