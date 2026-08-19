# Local development

Everything here runs on your own machine. There is no cloud step in the loop:
you edit, hot-reload, test and build locally, and GitHub only ever sees what
you choose to push.

## 1. Install Flutter

| OS | Get Flutter | Also install |
| --- | --- | --- |
| Windows | [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows) | Visual Studio 2022 with **Desktop development with C++** |
| macOS | [.../install/macos](https://docs.flutter.dev/get-started/install/macos) | Xcode (App Store), then `sudo xcodebuild -runFirstLaunch` |
| Linux | [.../install/linux](https://docs.flutter.dev/get-started/install/linux) | `sudo apt install ninja-build libgtk-3-dev clang cmake pkg-config` |

Add Android Studio on any OS if you want to build the APK or use an emulator.
This project needs **Dart 3.9+**, which any current stable Flutter provides.

Check the toolchain before anything else:

```bash
flutter doctor -v
```

Only the rows for the platforms you actually intend to build have to be green.

## 2. Clone and set up

```bash
git clone https://github.com/Arman10121995/deutsch-garden.git
cd deutsch-garden

make setup          # macOS/Linux
.\dev.ps1 setup     # Windows
```

`setup` runs `flutter create` to generate the native wrapper for your machine,
patches it (`tool/patch_platforms.py`), and fetches packages. The wrappers are
**not** committed — they are generated from your installed Flutter, so they
never go stale in git. This is why `git status` stays clean after setup.

## 3. The loop

```bash
make run            # hot reload on this desktop
make run-android    # on a connected phone or emulator
make devices        # what Flutter can see right now
make verify         # content check + analyze + tests — run before you commit
```

On Windows the same commands are `.\dev.ps1 run`, `.\dev.ps1 verify`, and so on.
Run `make` or `.\dev.ps1` with no argument to list everything.

While the app is running: **r** hot-reloads, **R** restarts, **q** quits.

## 4. Where things live

| Path | What it is |
| --- | --- |
| `lib/vocabulary*.dart`, `curriculum.dart`, `stories.dart`, `conversation.dart` | all bundled content, as plain Dart constants |
| `lib/srs.dart`, `pronunciation.dart`, `conversation_engine.dart` | pure logic, no Flutter imports, unit-tested |
| `lib/*_screens.dart`, `games.dart`, `screens.dart` | the UI |
| `lib/app_state.dart` | the single `ChangeNotifier` holding all state |
| `lib/platform_support.dart` | what the current platform can do |
| `tool/` | content validator, manifest generator, platform patcher |

Adding a word, a story or a role-play means editing one Dart list. Run
`make verify` afterwards — the validator and the tests will tell you if the new
content is inconsistent, including whether a dialogue step's own model answer
would pass it.

## 5. Before you commit

```bash
make verify
make report      # only if you changed bundled content
```

`make verify` is exactly what CI runs. If it is green locally, CI will be green.

## 6. Building installable artifacts

```bash
make build-android      # APK
make build-linux        # Linux bundle
make build-macos        # macOS .app
.\dev.ps1 build-windows # Windows .exe bundle
```

You can only build a platform your machine supports: Apple targets need macOS,
Windows targets need Windows. `docs/PLATFORMS.md` has the details and output
paths.

## 7. CI is deliberately quiet

Because development is local, the workflow does not build artifacts on every
push. It runs the correctness gate only — about one runner-minute.

The full five-platform matrix runs when you ask for it:

* **Actions → CI → Run workflow**, with *Build artifacts* ticked, or
* pushing a release tag: `git tag v3.2.0 && git push origin v3.2.0`

This matters on a private repository, where Actions minutes are metered and
macOS bills at **10x** wall-clock, Windows at **2x**. A full matrix run costs
roughly **103 billable minutes**; the free allowance is 2,000 a month. Building
on every push across five branches would spend about a quarter of the month's
budget each time. Building on demand costs about five minutes a month instead.

Public repositories get unlimited free minutes, so if you make the repository
public again none of this constrains you.

## 8. Using Claude Code locally

If you want the same assistance you had in the cloud session, but on your own
machine:

```bash
npm install -g @anthropic-ai/claude-code
cd deutsch-garden
claude
```

It picks up this repository, including `CLAUDE.md` if you add one. Nothing about
the project depends on it.
