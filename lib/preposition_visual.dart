/// The two-way prepositions, drawn rather than described.
///
/// German's nine Wechselpräpositionen — an, auf, hinter, in, neben, über,
/// unter, vor, zwischen — take the accusative when they answer *wohin?* and
/// the dative when they answer *wo?*. Every course explains this in a
/// sentence and every learner keeps getting it wrong anyway, because a
/// sentence about movement is not movement.
///
/// It is also the one piece of German grammar that is literally geometry: a
/// thing, a reference object, and a spatial relation between them. So it is
/// drawn here in code — a box and a ball, still for the dative and moving for
/// the accusative — with no asset of any kind. That is the first rule of
/// `docs/ASSET_POLICY.md` satisfied exactly: not licensed, not downloaded,
/// not attributed, because there is nothing to license.
///
/// The comparison is the lesson, not the picture. Showing *auf den Tisch* and
/// *auf dem Tisch* side by side is what makes the case distinction visible;
/// either one alone is just a ball on a box.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Where the moving object ends up, relative to the reference box.
enum PrepositionPlacement {
  on,
  under,
  inside,
  beside,
  behind,
  inFront,
  above,
  against,
  between,
}

class TwoWayPreposition {
  const TwoWayPreposition({
    required this.german,
    required this.english,
    required this.placement,
    required this.accusative,
    required this.dative,
  });

  final String german;
  final String english;
  final PrepositionPlacement placement;

  /// *Wohin?* — a change of place.
  final String accusative;

  /// *Wo?* — a position.
  final String dative;
}

/// The nine, with a real example pair each.
///
/// The pairs use the same noun on both sides on purpose: changing the noun as
/// well as the case would hide the thing being taught.
const List<TwoWayPreposition> twoWayPrepositions = <TwoWayPreposition>[
  TwoWayPreposition(
    german: 'auf',
    english: 'on, onto',
    placement: PrepositionPlacement.on,
    accusative: 'Ich lege das Buch auf den Tisch.',
    dative: 'Das Buch liegt auf dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'in',
    english: 'in, into',
    placement: PrepositionPlacement.inside,
    accusative: 'Ich lege das Buch in die Schachtel.',
    dative: 'Das Buch liegt in der Schachtel.',
  ),
  TwoWayPreposition(
    german: 'unter',
    english: 'under',
    placement: PrepositionPlacement.under,
    accusative: 'Ich lege das Buch unter den Tisch.',
    dative: 'Das Buch liegt unter dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'über',
    english: 'above, over',
    placement: PrepositionPlacement.above,
    accusative: 'Ich hänge die Lampe über den Tisch.',
    dative: 'Die Lampe hängt über dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'neben',
    english: 'next to',
    placement: PrepositionPlacement.beside,
    accusative: 'Ich stelle den Stuhl neben den Tisch.',
    dative: 'Der Stuhl steht neben dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'vor',
    english: 'in front of',
    placement: PrepositionPlacement.inFront,
    accusative: 'Ich stelle den Stuhl vor den Tisch.',
    dative: 'Der Stuhl steht vor dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'hinter',
    english: 'behind',
    placement: PrepositionPlacement.behind,
    accusative: 'Ich stelle den Stuhl hinter den Tisch.',
    dative: 'Der Stuhl steht hinter dem Tisch.',
  ),
  TwoWayPreposition(
    german: 'an',
    english: 'on (a vertical surface), at',
    placement: PrepositionPlacement.against,
    accusative: 'Ich hänge das Bild an die Wand.',
    dative: 'Das Bild hängt an der Wand.',
  ),
  TwoWayPreposition(
    german: 'zwischen',
    english: 'between',
    placement: PrepositionPlacement.between,
    accusative: 'Ich stelle den Stuhl zwischen die Tische.',
    dative: 'Der Stuhl steht zwischen den Tischen.',
  ),
];

/// The entry for [german], or null.
TwoWayPreposition? twoWayPrepositionFor(String german) {
  final String needle = german.trim().toLowerCase();
  for (final TwoWayPreposition p in twoWayPrepositions) {
    if (p.german == needle) return p;
  }
  return null;
}

/// The comparison: *wohin?* beside *wo?*, for one preposition.
class PrepositionDiagram extends StatefulWidget {
  const PrepositionDiagram({super.key, required this.preposition});

  final TwoWayPreposition preposition;

  @override
  State<PrepositionDiagram> createState() => _PrepositionDiagramState();
}

class _PrepositionDiagramState extends State<PrepositionDiagram>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Someone who has asked their device to stop animating has asked this app
    // too. The accusative panel then shows the object already arrived, with
    // the arrow still drawn -- the direction is the information, and it
    // survives being still.
    final bool motionOff = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (motionOff) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TwoWayPreposition p = widget.preposition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${p.german} — ${p.english}',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          'A two-way preposition: the case says whether something moved.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 10),
        // Side by side on anything wide enough, stacked when not. The
        // comparison is the lesson, so the two panels must stay together.
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 340;
            final List<Widget> panels = <Widget>[
              _panel(context, moving: true),
              SizedBox(width: wide ? 12 : 0, height: wide ? 0 : 12),
              _panel(context, moving: false),
            ];
            return wide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(child: panels[0]),
                        panels[1],
                        Expanded(child: panels[2]),
                      ],
                    ),
                  )
                : Column(children: panels);
          },
        ),
      ],
    );
  }

  Widget _panel(BuildContext context, {required bool moving}) {
    final ThemeData theme = Theme.of(context);
    final TwoWayPreposition p = widget.preposition;
    final Color accent =
        moving ? theme.colorScheme.primary : theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(14),
        color: accent.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Wrap, not Row: "wohin?" beside "accusative" does not fit a
          // half-width panel on a narrow phone, and the case label is the
          // half a learner most needs to keep.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: <Widget>[
              Text(
                moving ? 'wohin?' : 'wo?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
              Text(
                moving ? 'accusative' : 'dative',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            width: double.infinity,
            child: _controller == null
                ? CustomPaint(
                    painter: _PrepositionPainter(
                      placement: p.placement,
                      moving: moving,
                      // Stillness means arrived, not mid-flight: a frozen
                      // half-way ball reads as a rendering bug.
                      progress: 1,
                      accent: accent,
                      structure: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _controller!,
                    builder: (BuildContext context, Widget? _) => CustomPaint(
                      painter: _PrepositionPainter(
                        placement: p.placement,
                        moving: moving,
                        progress: moving ? _eased(_controller!.value) : 1,
                        accent: accent,
                        structure: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            moving ? p.accusative : p.dative,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Travel, then hold. A ball that restarts the instant it lands never looks
  /// like it arrived anywhere.
  double _eased(double t) {
    const double travel = 0.62;
    if (t >= travel) return 1;
    return Curves.easeInOut.transform(t / travel);
  }
}

class _PrepositionPainter extends CustomPainter {
  _PrepositionPainter({
    required this.placement,
    required this.moving,
    required this.progress,
    required this.accent,
    required this.structure,
  });

  final PrepositionPlacement placement;
  final bool moving;
  final double progress;
  final Color accent;
  final Color structure;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = structure.withValues(alpha: 0.75);
    final Paint ballPaint = Paint()..color = accent;

    final double w = size.width;
    final double h = size.height;
    final double boxW = math.min(w * 0.34, 62);
    const double boxH = 30;
    final Offset boxCentre = Offset(w / 2, h * 0.56);

    Rect box = Rect.fromCenter(
      center: boxCentre,
      width: boxW,
      height: boxH,
    );

    // zwischen needs two reference objects, or there is no "between".
    Rect? second;
    if (placement == PrepositionPlacement.between) {
      final double gap = boxW * 1.15;
      box = Rect.fromCenter(
        center: boxCentre.translate(-gap * 0.7, 0),
        width: boxW * 0.7,
        height: boxH,
      );
      second = Rect.fromCenter(
        center: boxCentre.translate(gap * 0.7, 0),
        width: boxW * 0.7,
        height: boxH,
      );
    }

    // `an` is a vertical surface, which is what distinguishes it from `auf`.
    if (placement == PrepositionPlacement.against) {
      final Rect wall = Rect.fromLTWH(w / 2 - 2, h * 0.18, 4, h * 0.62);
      canvas.drawRect(wall, Paint()..color = structure.withValues(alpha: 0.75));
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(4)),
        boxPaint,
      );
      if (second != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(second, const Radius.circular(4)),
          boxPaint,
        );
      }
    }

    const double radius = 9;
    final Offset target = _target(box, second, size, radius);
    final Offset start = _start(size, target);
    final Offset position =
        moving ? Offset.lerp(start, target, progress.clamp(0.0, 1.0))! : target;

    // The arrow carries the direction, which is the half of "wohin?" that a
    // still frame still has to convey.
    if (moving) {
      final Paint arrow = Paint()
        ..color = accent.withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, target, arrow);
      _arrowHead(canvas, start, target, arrow);
    }

    // Inside means occluded: drawn before the box outline is re-stroked so the
    // object reads as contained rather than resting on top of it.
    canvas.drawCircle(position, radius, ballPaint);
    if (placement == PrepositionPlacement.inside) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(4)),
        boxPaint,
      );
    }
  }

  Offset _target(Rect box, Rect? second, Size size, double r) {
    switch (placement) {
      case PrepositionPlacement.on:
        return Offset(box.center.dx, box.top - r);
      case PrepositionPlacement.under:
        return Offset(box.center.dx, box.bottom + r);
      case PrepositionPlacement.inside:
        return box.center;
      case PrepositionPlacement.above:
        // Clearly clear of it: `über` is not `auf`, and a gap is the whole
        // difference.
        return Offset(box.center.dx, box.top - r * 3.2);
      case PrepositionPlacement.beside:
        return Offset(box.right + r * 1.6, box.center.dy);
      case PrepositionPlacement.inFront:
        return Offset(box.center.dx, box.bottom + r * 0.2);
      case PrepositionPlacement.behind:
        return Offset(box.center.dx, box.top - r * 0.2);
      case PrepositionPlacement.against:
        return Offset(size.width / 2 + r + 2, size.height * 0.45);
      case PrepositionPlacement.between:
        return Offset(
          second == null ? box.center.dx : (box.right + second.left) / 2,
          box.center.dy,
        );
    }
  }

  /// Always enters from off-picture, so the movement reads as arriving.
  Offset _start(Size size, Offset target) {
    switch (placement) {
      case PrepositionPlacement.under:
      case PrepositionPlacement.inFront:
        return Offset(size.width * 0.08, size.height * 0.94);
      case PrepositionPlacement.beside:
      case PrepositionPlacement.against:
        return Offset(size.width * 0.94, size.height * 0.12);
      default:
        return Offset(size.width * 0.08, size.height * 0.10);
    }
  }

  void _arrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final double angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const double len = 7;
    for (final double spread in <double>[2.6, -2.6]) {
      canvas.drawLine(
        to,
        to.translate(
          math.cos(angle + spread) * len,
          math.sin(angle + spread) * len,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PrepositionPainter old) =>
      old.progress != progress ||
      old.moving != moving ||
      old.placement != placement ||
      old.accent != accent ||
      old.structure != structure;
}
