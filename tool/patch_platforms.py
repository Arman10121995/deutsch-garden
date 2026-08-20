#!/usr/bin/env python3
"""Patch every generated platform wrapper for DeutschGarden.

`flutter create` writes generic scaffolding named after the pubspec package.
Each target needs a few project-specific edits before it is shippable:

* Android — app label, RECORD_AUDIO/INTERNET, TTS and speech-recognition
  package-visibility queries (delegated to patch_android_manifest.py).
* Linux / Windows — window title and a sensible default window size.
* macOS — product name, microphone and speech-recognition usage strings, and
  the sandbox entitlement without which the microphone is silently denied.
* iOS — microphone and speech-recognition usage strings, without which the
  app is terminated by the OS the moment it asks for the microphone.

Every edit is idempotent, so running this repeatedly is safe.
"""
from __future__ import annotations

import re
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_NAME = 'DeutschGarden'
APP_DESCRIPTION = ('Offline German study from A1 to C2 - vocabulary, grammar, listening, reading, writing, speaking, stories and exam practice, with no account and no server.')
WINDOW_WIDTH = 1180
WINDOW_HEIGHT = 820

MIC_REASON = (
    'DeutschGarden uses the microphone only while you are practising speaking, '
    'so it can compare what you said with the target sentence. Audio is not '
    'recorded, stored or sent anywhere by this app.'
)
SPEECH_REASON = (
    'DeutschGarden uses speech recognition to transcribe your spoken German '
    'so it can give you feedback on the words you produced.'
)

changed: list[str] = []
skipped: list[str] = []


# Edits whose target pattern was not found -- hard failures.
failures: list[str] = []


def patch_file(path: Path, edits, label: str) -> None:
    """Apply (pattern, replacement) edits to a file if it exists.

    Every replacement here is a literal string, so the check for success is
    simply whether it is present afterwards. That distinction matters: a
    regex that stops matching because Flutter reshaped a generated file
    produces exactly the same "nothing changed" as a file that was already
    patched, and the old version reported both as skipped and exited 0. The
    app then shipped with the edit missing -- which is how the microphone
    permission went absent from iOS and macOS builds before 3.2.0.
    """
    if not path.exists():
        skipped.append(f'{label} (not generated)')
        return
    text = path.read_text(encoding='utf-8')
    original = text
    for pattern, replacement in edits:
        text = re.sub(pattern, replacement, text)

    unmet = [replacement for _, replacement in edits if replacement not in text]
    if unmet:
        failures.append(
            '%s: %d edit(s) did not apply. The generated file no longer '
            'matches the expected pattern -- most likely a Flutter upgrade '
            'reshaped it. Expected to find: %s'
            % (label, len(unmet), '; '.join(repr(u) for u in unmet))
        )
        return

    if text != original:
        path.write_text(text, encoding='utf-8')
        changed.append(label)
    else:
        skipped.append(f'{label} (already correct)')


# --- Android ---------------------------------------------------------------
android_manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
if android_manifest.exists():
    sys.argv = ['patch_android_manifest.py']
    runpy.run_path(str(ROOT / 'tool/patch_android_manifest.py'), run_name='__main__')
else:
    skipped.append('android (not generated)')


# --- Android release signing -----------------------------------------------
#
# `flutter build apk --release` signs with the DEBUG keystore unless a release
# config exists -- Flutter's own scaffolding says so in a TODO. A release build
# carrying CN=Android Debug is what makes Play Protect and third-party scanners
# warn the user that the app is unsafe, and it can never be published to Play.
#
# The key itself is never in this repository. It is read from key.properties at
# the FLUTTER project root -- referenced as ../key.properties, because for
# android/app/build.gradle.kts `rootProject` is the android/ directory, not the
# Flutter project. CI writes that file from repository secrets. With no
# key.properties the build falls back to debug signing, so a contributor
# without the key can still build and run.
gradle = ROOT / 'android/app/build.gradle.kts'
if gradle.exists():
    text = gradle.read_text(encoding='utf-8')
    if 'signingConfigs.getByName("release")' in text:
        skipped.append('android signing (already correct)')
    else:
        header = (
            'import java.io.FileInputStream' + chr(10) +
            'import java.util.Properties' + chr(10) + chr(10) +
            'val keystorePropertiesFile = rootProject.file("../key.properties")' + chr(10) +
            'val keystoreProperties = Properties()' + chr(10) +
            'if (keystorePropertiesFile.exists()) {' + chr(10) +
            '    keystoreProperties.load(FileInputStream(keystorePropertiesFile))' + chr(10) +
            '}' + chr(10) + chr(10)
        )
        old_release = (
            '    buildTypes {' + chr(10) +
            '        release {' + chr(10) +
            '            // TODO: Add your own signing config for the release build.' + chr(10) +
            '            // Signing with the debug keys for now, so `flutter run --release` works.' + chr(10) +
            '            signingConfig = signingConfigs.getByName("debug")' + chr(10) +
            '        }' + chr(10) +
            '    }'
        )
        new_release = (
            '    signingConfigs {' + chr(10) +
            '        create("release") {' + chr(10) +
            '            if (keystorePropertiesFile.exists()) {' + chr(10) +
            '                keyAlias = keystoreProperties["keyAlias"] as String' + chr(10) +
            '                keyPassword = keystoreProperties["keyPassword"] as String' + chr(10) +
            '                storeFile = file(keystoreProperties["storeFile"] as String)' + chr(10) +
            '                storePassword = keystoreProperties["storePassword"] as String' + chr(10) +
            '            }' + chr(10) +
            '        }' + chr(10) +
            '    }' + chr(10) + chr(10) +
            '    buildTypes {' + chr(10) +
            '        release {' + chr(10) +
            '            // Falls back to debug signing only when the key is absent,' + chr(10) +
            '            // so an unsigned contributor build still runs.' + chr(10) +
            '            signingConfig = if (keystorePropertiesFile.exists()) {' + chr(10) +
            '                signingConfigs.getByName("release")' + chr(10) +
            '            } else {' + chr(10) +
            '                signingConfigs.getByName("debug")' + chr(10) +
            '            }' + chr(10) +
            '        }' + chr(10) +
            '    }'
        )
        if old_release not in text:
            failures.append(
                'android signing: the generated build.gradle.kts no longer '
                'contains the expected debug-signing block, so release signing '
                'was NOT configured. The APK would ship debug-signed.'
            )
        else:
            text = header + text.replace(old_release, new_release, 1)
            gradle.write_text(text, encoding='utf-8')
            changed.append('android signing')
else:
    skipped.append('android signing (not generated)')


# --- Web -------------------------------------------------------------------
#
# Two things the scaffold gets wrong for this app.
#
# First, the Flutter loader fetches CanvasKit from
# https://www.gstatic.com/flutter-canvaskit unless told otherwise, even though
# `flutter build web` has already copied it into build/web/canvaskit/. For an
# app whose entire premise is that it never contacts a server, downloading the
# renderer from a Google CDN on every cold load is both a broken promise and a
# hard failure anywhere the CDN is unreachable. canvasKitBaseUrl pins it local.
#
# Second, the scaffolded index.html and manifest.json still say
# "deutsch_garden" and "A new Flutter project".
WEB_DIR = ROOT / 'web'
if WEB_DIR.exists():
    bootstrap = WEB_DIR / 'flutter_bootstrap.js'
    bootstrap_body = chr(10).join([
        '// Customised loader. Do not add network dependencies here: this app',
        '// is expected to work with no server once it has been loaded once.',
        '{{flutter_js}}',
        '{{flutter_build_config}}',
        '',
        '_flutter.loader.load({',
        '  config: {',
        '    // Use the CanvasKit copied into the build output rather than the',
        '    // gstatic CDN the loader would otherwise reach for.',
        '    canvasKitBaseUrl: "canvaskit/",',
        '  },',
        '  serviceWorkerSettings: {',
        '    serviceWorkerVersion: {{flutter_service_worker_version}},',
        '  },',
        '});',
        '',
    ])
    if bootstrap.exists() and bootstrap.read_text(encoding='utf-8') == bootstrap_body:
        skipped.append('web loader (already correct)')
    else:
        bootstrap.write_text(bootstrap_body, encoding='utf-8')
        changed.append('web loader')

    index = WEB_DIR / 'index.html'
    if index.exists():
        text = index.read_text(encoding='utf-8')
        before = text
        text = text.replace(
            '<meta name="description" content="A new Flutter project.">',
            '<meta name="description" content="' + APP_DESCRIPTION + '">')
        text = text.replace(
            '<title>deutsch_garden</title>', '<title>' + APP_NAME + '</title>')
        text = text.replace(
            '<meta name="apple-mobile-web-app-title" content="deutsch_garden">',
            '<meta name="apple-mobile-web-app-title" content="' + APP_NAME + '">')
        if '<meta name="theme-color"' not in text:
            text = text.replace(
                '<link rel="manifest" href="manifest.json">',
                '<meta name="theme-color" content="#7C5CFC">' + chr(10) +
                '  <link rel="manifest" href="manifest.json">')
        if text != before:
            index.write_text(text, encoding='utf-8')
            changed.append('web index.html')
        else:
            skipped.append('web index.html (already correct)')

    manifest_json = WEB_DIR / 'manifest.json'
    if manifest_json.exists():
        import json as _json
        data = _json.loads(manifest_json.read_text(encoding='utf-8'))
        data['name'] = APP_NAME
        data['short_name'] = APP_NAME
        data['description'] = APP_DESCRIPTION
        data['theme_color'] = '#7C5CFC'
        data['background_color'] = '#101116'
        manifest_json.write_text(
            _json.dumps(data, indent=4, ensure_ascii=False) + chr(10),
            encoding='utf-8')
        changed.append('web manifest')
else:
    skipped.append('web (not generated)')


# --- Linux -----------------------------------------------------------------
patch_file(
    ROOT / 'linux/runner/my_application.cc',
    [
        (r'gtk_header_bar_set_title\(header_bar, "[^"]*"\)',
         f'gtk_header_bar_set_title(header_bar, "{APP_NAME}")'),
        (r'gtk_window_set_title\(window, "[^"]*"\)',
         f'gtk_window_set_title(window, "{APP_NAME}")'),
        (r'gtk_window_set_default_size\(window, \d+, \d+\)',
         f'gtk_window_set_default_size(window, {WINDOW_WIDTH}, {WINDOW_HEIGHT})'),
    ],
    'linux window',
)


# --- Windows ---------------------------------------------------------------
patch_file(
    ROOT / 'windows/runner/main.cpp',
    [
        (r'Win32Window::Size size\(\d+, \d+\)',
         f'Win32Window::Size size({WINDOW_WIDTH}, {WINDOW_HEIGHT})'),
        (r'window\.Create\(L"[^"]*"', f'window.Create(L"{APP_NAME}"'),
    ],
    'windows window',
)

# The executable itself is named after the pubspec package -- deutsch_garden.exe
# -- while macOS gets DeutschGarden.app from PRODUCT_NAME. Name it the same way
# on both, so what the README promises is what lands in the zip.
patch_file(
    ROOT / 'windows/CMakeLists.txt',
    [(r'set\(BINARY_NAME "[^"]*"\)', f'set(BINARY_NAME "{APP_NAME}")')],
    'windows binary name',
)

patch_file(
    ROOT / 'windows/runner/Runner.rc',
    [
        (r'VALUE "FileDescription", "[^"]*"',
         f'VALUE "FileDescription", "{APP_NAME}"'),
        (r'VALUE "ProductName", "[^"]*"', f'VALUE "ProductName", "{APP_NAME}"'),
        (r'VALUE "InternalName", "[^"]*"', f'VALUE "InternalName", "{APP_NAME}"'),
    ],
    'windows metadata',
)


# --- macOS -----------------------------------------------------------------
patch_file(
    ROOT / 'macos/Runner/Configs/AppInfo.xcconfig',
    [(r'PRODUCT_NAME = .*', f'PRODUCT_NAME = {APP_NAME}')],
    'macos product name',
)


def add_plist_keys(path: Path, label: str, keys: dict) -> None:
    """Insert <key>/<string> pairs into an Info.plist before the final </dict>."""
    if not path.exists():
        skipped.append(f'{label} (not generated)')
        return
    text = path.read_text(encoding='utf-8')
    missing = {k: v for k, v in keys.items() if f'<key>{k}</key>' not in text}
    if not missing:
        skipped.append(f'{label} (already patched)')
        return
    block = ''.join(
        f'\t<key>{key}</key>\n\t<string>{value}</string>\n'
        for key, value in missing.items()
    )
    index = text.rindex('</dict>')
    text = text[:index] + block + text[index:]
    path.write_text(text, encoding='utf-8')
    changed.append(f'{label} (+{", ".join(missing)})')


PERMISSION_KEYS = {
    'NSMicrophoneUsageDescription': MIC_REASON,
    'NSSpeechRecognitionUsageDescription': SPEECH_REASON,
}

add_plist_keys(ROOT / 'ios/Runner/Info.plist', 'ios permissions', PERMISSION_KEYS)
add_plist_keys(ROOT / 'macos/Runner/Info.plist', 'macos permissions', PERMISSION_KEYS)


def add_entitlement(path: Path, label: str, key: str) -> None:
    """The macOS sandbox denies the microphone unless this entitlement is set."""
    if not path.exists():
        skipped.append(f'{label} (not generated)')
        return
    text = path.read_text(encoding='utf-8')
    if f'<key>{key}</key>' in text:
        skipped.append(f'{label} (already patched)')
        return
    index = text.rindex('</dict>')
    text = text[:index] + f'\t<key>{key}</key>\n\t<true/>\n' + text[index:]
    path.write_text(text, encoding='utf-8')
    changed.append(label)


for entitlement in ('DebugProfile', 'Release'):
    add_entitlement(
        ROOT / f'macos/Runner/{entitlement}.entitlements',
        f'macos {entitlement.lower()} entitlement',
        'com.apple.security.device.audio-input',
    )


print('Platform patching complete.')
for item in changed:
    print(f'  patched: {item}')
for item in skipped:
    print(f'  skipped: {item}')

if failures:
    print()
    print('PLATFORM PATCHING FAILED')
    for item in failures:
        print(f'  - {item}')
    sys.exit(1)
