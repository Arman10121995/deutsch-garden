import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'l10n/app_localizations.dart';

/// Original vector art, paired with text; no information relies on colour.
class LearningIllustration extends StatelessWidget {
  const LearningIllustration({
    super.key,
    this.complete = false,
    this.width = 96,
  });
  final bool complete;
  final double width;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    complete ? 'assets/ui/lesson-finish.svg' : 'assets/ui/practice-guide.svg',
    width: width,
    height: width * .75,
    excludeFromSemantics: true,
  );
}

class LearningGuideCard extends StatelessWidget {
  const LearningGuideCard({super.key, this.questions = false});
  final bool questions;
  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return Card(
      child: ExpansionTile(
        leading: const LearningIllustration(width: 56),
        title: Text(questions ? t.questionGuideTitle : t.learningGuideTitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _GuideStep(
            icon: Icons.hearing_rounded,
            title: t.guideListenTitle,
            body: questions ? t.guideQuestionListen : t.guideListenBody,
          ),
          _GuideStep(
            icon: Icons.psychology_outlined,
            title: t.guideRecallTitle,
            body: questions ? t.guideQuestionRecall : t.guideRecallBody,
          ),
          _GuideStep(
            icon: Icons.check_circle_outline_rounded,
            title: t.guideUseTitle,
            body: questions ? t.guideQuestionUse : t.guideUseBody,
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(body),
            ],
          ),
        ),
      ],
    ),
  );
}
