/// What a learner sees the very first time they open the app.
///
/// Without this they land on a route screen with no explanation of what the
/// app is, whether it needs an account, where their data goes, or what the
/// single button in front of them will do. The repository has an
/// `INSTRUCTIONS.md`, but that is a build guide for whoever compiles the app
/// and would be worse than nothing here.
///
/// Four screens, skippable, shown once. It is deliberately short: an intro
/// that outstays its welcome gets dismissed without being read, which is the
/// same outcome as not having one.
library;

import 'package:flutter/material.dart';

import 'app_state.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const List<_Page> _pages = <_Page>[
  _Page(
    Icons.local_florist_outlined,
    'Willkommen',
    'DeutschGarden teaches German from A1 to C2 — vocabulary, grammar, '
        'listening, reading, writing and speaking, in one place.\n\n'
        'Everything is already on your device. There is nothing to download '
        'as you go.',
  ),
  _Page(
    Icons.wifi_off_outlined,
    'Offline, and yours',
    'No account, no sign-in, no server, no analytics. The app works with '
        'aeroplane mode on and never sends your progress anywhere.\n\n'
        'Because nothing is stored online, your progress lives on this device '
        'only. Profile → Export makes a backup you keep.',
  ),
  _Page(
    Icons.route_outlined,
    'Start with Learn',
    'Learn gives you one next thing to do and works out the rest — new words, '
        'reviews that are due, and repair for anything you got wrong.\n\n'
        'You do not have to plan a session. Open Learn and answer what it '
        'puts in front of you.',
  ),
  _Page(
    Icons.explore_outlined,
    'Explore when you want to choose',
    'Explore holds the libraries: every word, story, lesson and practice game, '
        'plus the placement test if you would rather not start at A1.\n\n'
        'Profile keeps your progress, settings and backups.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pager = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  bool get _onLast => _index == _pages.length - 1;

  Future<void> _finish() => widget.controller.completeOnboarding();

  void _next() {
    if (_onLast) {
      _finish();
      return;
    }
    _pager.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: _pages.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _Page page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(page.icon, size: 56, color: scheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _pages.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_onLast ? 'Los geht’s' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
