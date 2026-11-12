# Instructions for coding agents

These apply to every automated assistant working in this repository (Codex,
Claude Code and any other).

## One branch

This repository has exactly one branch: `main`, locally and on `origin`.

- Commit on `main` and push to `origin main`.
- Do not create work branches (`codex/*`, `claude/*`, feature branches) and do
  not open pull requests.
- Before starting, run `git pull --rebase origin main`: another assistant may
  have pushed since your checkout.
- Never force-push `main` and never rewrite commits that are already on
  `origin`.
- If you find any branch other than `main`, report it to the maintainer
  instead of using it or deleting it.

## Check before you push

Nothing reviews a change before it reaches `main`, and CI only runs after the
push. Run the same gate CI runs, and go by exit codes rather than by reading
the output (analysis fails on info-level lints too):

```sh
python tool/validate_content.py
python tool/check_l10n.py
flutter analyze
flutter test
```

The remaining `tool/check_*.py` scripts listed in `.github/workflows/ci.yml`
are part of the gate as well. After changing the version, the content or the
file list, regenerate the manifest files with
`python tool/validate_content.py --write` and commit the result.

## Commits and releases

- One commit per coherent change, with a message that says what changed and
  why. Write the message to a file and use `git commit -F`; a message passed
  through the shell with backticks in it gets executed.
- The version in `pubspec.yaml` and the newest `CHANGELOG.md` heading must
  match. A release is a `v*` tag on `main`; do not create or push tags unless
  the maintainer asks.
- Do not run `dart format` across the whole repository. Format only the files
  you changed, and only if they were formatted before. See `docs/ROADMAP.md`.
