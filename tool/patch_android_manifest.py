from pathlib import Path

manifest = Path('android/app/src/main/AndroidManifest.xml')
if not manifest.exists():
    raise SystemExit('AndroidManifest.xml not found. Run: flutter create . --platforms=android')

text = manifest.read_text(encoding='utf-8')
text = text.replace('android:label="deutsch_garden"', 'android:label="DeutschGarden"')
query = '''\n    <!-- Required for Android 11+ text-to-speech engine discovery. -->\n    <queries>\n        <intent>\n            <action android:name="android.intent.action.TTS_SERVICE" />\n        </intent>\n    </queries>\n'''
if 'android.intent.action.TTS_SERVICE' not in text:
    marker = '<application'
    index = text.find(marker)
    if index == -1:
        raise SystemExit('Could not find <application> in AndroidManifest.xml')
    text = text[:index] + query + '    ' + text[index:]
    manifest.write_text(text, encoding='utf-8')
    print('Patched AndroidManifest.xml for TTS.')
else:
    print('AndroidManifest.xml already contains the TTS query.')
