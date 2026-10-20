"""Launch the actual release APK twice on an emulator; never erase app data.

A successful build does not exercise JNI calls. In 4.21 the first preferences
read failed before runApp, although every build/test job passed. Require the
production startup marker emitted after the loaded app's first frame.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

PACKAGE = 'com.deutschgarden.deutsch_garden'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', type=Path, required=True)
    parser.add_argument('--device', default='emulator-5554')
    parser.add_argument('--adb')
    args = parser.parse_args()
    if not re.fullmatch(r'emulator-\d+', args.device):
        parser.error('Use a disposable emulator; physical devices are not modified')
    if not args.apk.is_file():
        parser.error('APK does not exist')
    adb = args.adb or shutil.which('adb')
    if not adb:
        sdk = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
        if sdk:
            adb = str(Path(sdk) / 'platform-tools' / ('adb.exe' if os.name == 'nt' else 'adb'))
    if not adb:
        parser.error('ADB is not on PATH and no Android SDK was located')
    root = Path(__file__).resolve().parents[1]
    version = re.search(r'^version:\s*(\S+)', (root / 'pubspec.yaml').read_text(), re.M)[1]
    expected = f'DeutschGarden startup ready ({version})'

    def run(*command: str, timeout: int = 30, check: bool = True) -> str:
        result = subprocess.run(
            [adb, '-s', args.device, *command], capture_output=True,
            text=True, encoding='utf-8', errors='replace', timeout=timeout,
        )
        if result.returncode and check:
            raise RuntimeError(result.stdout + result.stderr)
        return result.stdout

    try:
        if run('shell', 'getprop', 'sys.boot_completed').strip() != '1':
            raise RuntimeError('Emulator has not finished booting')
        installed = run('install', '-r', str(args.apk.resolve()), timeout=180)
        if 'Success' not in installed:
            raise RuntimeError(installed)
        for attempt in (1, 2):
            run('shell', 'am', 'force-stop', PACKAGE)
            # This script is emulator-only. Clearing logs prevents a previous
            # launch's success from satisfying the current launch's assertion.
            run('logcat', '-c')
            run('shell', 'am', 'start', '-n', f'{PACKAGE}/.MainActivity')
            deadline = time.monotonic() + 90
            logs = ''
            while time.monotonic() < deadline:
                pid = run('shell', 'pidof', PACKAGE, check=False).strip()
                if not pid:
                    time.sleep(1)
                    continue
                logs = run('logcat', '-d', f'--pid={pid}')
                if 'Unhandled Exception:' in logs or 'FATAL EXCEPTION:' in logs:
                    raise RuntimeError(logs[-10000:])
                if expected in logs:
                    print(f'Android release launch {attempt}/2 passed: {expected}')
                    break
                time.sleep(1)
            else:
                raise RuntimeError('No loaded first-frame marker within 90 seconds\n' + logs[-10000:])
        print('Release APK survived cold/warm launch with saved app data retained.')
        return 0
    except (RuntimeError, subprocess.TimeoutExpired, OSError) as error:
        print(f'Android release smoke failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
