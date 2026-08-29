/// Gives a pictogram the movement its word describes.
///
/// A verb is not a thing. A still picture of a plane says *plane*; the same
/// picture travelling says *to fly*. That difference is the whole reason
/// animated stock footage looked worth buying — but the motion is the
/// meaningful half of it, and motion is something we can author ourselves for
/// nothing.
///
/// So no GIFs. This animates assets the project already owns, which keeps it
/// inside the first line of `docs/ASSET_POLICY.md` on both counts: nothing
/// comes from outside, and it adds no bytes at all to a bundle that has
/// nineteen megabytes of headroom before Google Play stops accepting it.
///
/// Deliberately small movements. This sits beside a word the learner is trying
/// to read; anything larger competes with the text instead of supporting it.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'vocab_motion.dart';

class MovingPictogram extends StatefulWidget {
  const MovingPictogram({
    super.key,
    required this.motion,
    required this.child,
    this.size = 44,
  });

  final VocabMotion motion;
  final Widget child;
  final double size;

  @override
  State<MovingPictogram> createState() => _MovingPictogramState();
}

class _MovingPictogramState extends State<MovingPictogram>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  /// One cycle. Slow enough to read as deliberate rather than as a glitch.
  static const Duration _period = Duration(milliseconds: 2600);

  @override
  void initState() {
    super.initState();
    if (widget.motion != VocabMotion.none) {
      _controller = AnimationController(vsync: this, duration: _period)
        ..repeat();
    }
  }

  @override
  void didUpdateWidget(MovingPictogram old) {
    super.didUpdateWidget(old);
    if (old.motion == widget.motion) return;
    // A list that recycles its rows can hand this widget a different word.
    if (widget.motion == VocabMotion.none) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    _controller ??= AnimationController(vsync: this, duration: _period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? controller = _controller;
    // Respected rather than ignored: a learner who has asked their system to
    // stop animating things has asked this app too, and vestibular disorders
    // are a real reason to ask.
    if (controller == null ||
        MediaQuery.maybeDisableAnimationsOf(context) == true) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) =>
          _transform(controller.value, child!),
      child: widget.child,
    );
  }

  Widget _transform(double t, Widget child) {
    // A smooth there-and-back, so nothing ever snaps back to its start.
    final double wave = math.sin(t * 2 * math.pi);
    final double reach = widget.size * 0.12;

    switch (widget.motion) {
      case VocabMotion.none:
        return child;
      case VocabMotion.travel:
        return Transform.translate(offset: Offset(wave * reach, 0), child: child);
      case VocabMotion.rise:
        return Transform.translate(offset: Offset(0, -wave * reach), child: child);
      case VocabMotion.rock:
        return Transform.rotate(angle: wave * 0.18, child: child);
      case VocabMotion.pulse:
        return Transform.scale(scale: 1 + wave * 0.08, child: child);
      case VocabMotion.fade:
        // Never all the way out: a pictogram that disappears reads as a bug.
        return Opacity(opacity: 0.55 + (wave + 1) / 2 * 0.45, child: child);
      case VocabMotion.spin:
        return Transform.rotate(angle: t * 2 * math.pi, child: child);
    }
  }
}
