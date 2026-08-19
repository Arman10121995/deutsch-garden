#!/usr/bin/env python3
"""Patch the generated Android manifest for TTS and speech recognition.

`flutter create` writes a plain manifest. DeutschGarden needs three additions:

* a friendly application label,
* the RECORD_AUDIO permission, plus INTERNET because the platform recogniser
  falls back to a network service when no offline language pack is installed,
* Android 11+ package-visibility <intent> entries for the text-to-speech engine
  and the speech-recognition service, without which both plugins silently fail.

The script is idempotent and additive: it never removes anything Flutter wrote,
in particular the ACTION_PROCESS_TEXT query the engine relies on.
"""
import re
import sys
from pathlib import Path

manifest = Path('android/app/src/main/AndroidManifest.xml')
if not manifest.exists():
    sys.exit('AndroidManifest.xml not found. Run: flutter create . --platforms=android')

text = manifest.read_text(encoding='utf-8')
original = text

text = text.replace('android:label="deutsch_garden"', 'android:label="DeutschGarden"')

PERMISSIONS = [
    'android.permission.RECORD_AUDIO',
    'android.permission.INTERNET',
]

INTENTS = [
    'android.intent.action.TTS_SERVICE',
    'android.speech.RecognitionService',
]

application = re.search(r'^([ \t]*)<application\b', text, re.MULTILINE)
if application is None:
    sys.exit('Could not find <application> in AndroidManifest.xml')
indent = application.group(1)

missing_permissions = [name for name in PERMISSIONS if name not in text]
if missing_permissions:
    block = ''.join(
        f'{indent}<uses-permission android:name="{name}" />\n'
        for name in missing_permissions
    )
    text = text[:application.start()] + block + text[application.start():]

missing_intents = [action for action in INTENTS if action not in text]
if missing_intents:
    entries = ''.join(
        f'{indent}    <intent>\n'
        f'{indent}        <action android:name="{action}" />\n'
        f'{indent}    </intent>\n'
        for action in missing_intents
    )
    existing = re.search(r'^([ \t]*)<queries>', text, re.MULTILINE)
    if existing is None:
        # No <queries> yet: add one immediately before <application>.
        application = re.search(r'^([ \t]*)<application\b', text, re.MULTILINE)
        block = (
            f'{indent}<!-- Android 11+ package visibility for the text-to-speech\n'
            f'{indent}     and speech-recognition services. -->\n'
            f'{indent}<queries>\n{entries}{indent}</queries>\n'
        )
        text = text[:application.start()] + block + text[application.start():]
    else:
        # Extend the block Flutter already wrote rather than replacing it.
        insert_at = text.index('\n', existing.end()) + 1
        text = text[:insert_at] + entries + text[insert_at:]

if text != original:
    manifest.write_text(text, encoding='utf-8')
    print('Patched AndroidManifest.xml for TTS, speech recognition and label.')
else:
    print('AndroidManifest.xml already patched.')
