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
import re
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_NAME = 'DeutschGarden'
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


def patch_file(path: Path, edits, label: str) -> None:
    """Apply (pattern, replacement) edits to a file if it exists."""
    if not path.exists():
        skipped.append(f'{label} (not generated)')
        return
    text = path.read_text(encoding='utf-8')
    original = text
    for pattern, replacement in edits:
        text = re.sub(pattern, replacement, text)
    if text != original:
        path.write_text(text, encoding='utf-8')
        changed.append(label)
    else:
        skipped.append(f'{label} (already patched)')


# --- Android ---------------------------------------------------------------
android_manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
if android_manifest.exists():
    sys.argv = ['patch_android_manifest.py']
    runpy.run_path(str(ROOT / 'tool/patch_android_manifest.py'), run_name='__main__')
else:
    skipped.append('android (not generated)')


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
