import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One step of an [AppTour]. With a [target], that widget is spotlighted
/// and the card sits beside it; without one, the card is centred.
class TourStep {
  final GlobalKey? target;
  final String title;
  final String body;

  const TourStep({this.target, required this.title, required this.body});
}

/// A first-run guided tour: dims the screen, cuts a spotlight around each
/// step's target, and explains it in a card with Next / Skip.
class AppTour {
  AppTour._();

  static String _seenKey(String id) => 'app_tour_seen_$id';

  /// Shows the tour once per install. Steps whose target isn't on screen
  /// are shown as centred cards instead of being skipped.
  static Future<void> showOnce(
    BuildContext context, {
    required String id,
    required List<TourStep> steps,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey(id)) ?? false) return;
    if (!context.mounted) return;
    await show(context, steps);
    await prefs.setBool(_seenKey(id), true);
  }

  static Future<void> show(BuildContext context, List<TourStep> steps) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => _TourOverlay(steps: steps),
      transitionBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}

class _TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  const _TourOverlay({required this.steps});

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  int _index = 0;

  TourStep get _step => widget.steps[_index];
  bool get _isLast => _index == widget.steps.length - 1;

  Rect? _targetRect() {
    final box = _step.target?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    final offset = box.localToGlobal(Offset.zero);
    return (offset & box.size).inflate(8);
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hole = _targetRect();
    // Card goes on whichever side of the spotlight has more room.
    final cardBelow = hole == null || hole.center.dy < size.height / 2;

    final card = _TourCard(
      step: _step,
      index: _index,
      total: widget.steps.length,
      isLast: _isLast,
      onNext: _next,
      onSkip: () => Navigator.of(context).pop(),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _next,
              child: CustomPaint(painter: _SpotlightPainter(hole)),
            ),
          ),
          if (hole == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: card,
              ),
            )
          else
            Positioned(
              left: 20,
              right: 20,
              top: cardBelow ? hole.bottom + 14 : null,
              bottom: cardBelow ? null : size.height - hole.top + 14,
              child: card,
            ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? hole;
  _SpotlightPainter(this.hole);

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Path()..addRect(Offset.zero & size);
    final shape = hole == null
        ? dim
        : Path.combine(
            PathOperation.difference,
            dim,
            Path()..addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(16))),
          );
    canvas.drawPath(shape, Paint()..color = Colors.black.withValues(alpha: 0.72));
    if (hole != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hole!, const Radius.circular(16)),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole;
}

class _TourCard extends StatelessWidget {
  final TourStep step;
  final int index;
  final int total;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourCard({
    required this.step,
    required this.index,
    required this.total,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP ${index + 1} OF $total',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F1B3E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.body,
            style: TextStyle(fontSize: 14, height: 1.45, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  child: Text('Skip', style: TextStyle(color: Colors.grey.shade600)),
                ),
              const Spacer(),
              TextButton(
                onPressed: onNext,
                child: Text(
                  isLast ? 'Got it' : 'Next',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
