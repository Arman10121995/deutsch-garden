#!/usr/bin/env python3
"""Fails the build when the bundled voices disagree in a way dialogue cannot hide.

Two-voice dialogue renders each line with its own model and concatenates the
results into one WAV. That only works if every line ends up at one sample rate.
Until 4.7.1 the renderer threw when they differed -- and they did differ, so
*every* dialogue mixing Thorsten and Kerstin failed at render time on a
learner's device, with nothing in the build saying so.

The renderer now resamples instead, so a mismatch is no longer fatal. It is
still not free: upsampling cannot add detail the smaller model never produced,
so a 16 kHz voice next to a 22.05 kHz one just sounds worse. This reports that
plainly rather than letting it pass unnoticed.

Run: python tool/check_voice_rates.py
"""

from __future__ import annotations

import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TTS = os.path.join(ROOT, 'assets', 'tts')


def main() -> int:
    problems: list[str] = []
    notes: list[str] = []

    if not os.path.isdir(TTS):
        print('Voice check failed:\n\n  - assets/tts is missing.')
        return 1

    cards = sorted(f for f in os.listdir(TTS) if f.endswith('.onnx.json'))
    if not cards:
        problems.append('no voice model cards found in assets/tts.')

    rates: dict[str, int] = {}
    for card in cards:
        path = os.path.join(TTS, card)
        try:
            data = json.loads(io.open(path, encoding='utf-8').read())
        except Exception as error:
            problems.append('%s is not readable JSON: %s' % (card, error))
            continue
        rate = (data.get('audio') or {}).get('sample_rate')
        if not isinstance(rate, int) or rate <= 0:
            problems.append('%s declares no usable sample_rate.' % card)
            continue
        rates[card[:-len('.onnx.json')]] = rate

        model = os.path.join(TTS, card[:-len('.json')])
        if not os.path.exists(model):
            problems.append(
                '%s has a model card but no %s beside it.'
                % (card, os.path.basename(model))
            )

    if len(set(rates.values())) > 1:
        listing = ', '.join(
            '%s at %d Hz' % (name, rate) for name, rate in sorted(rates.items())
        )
        notes.append(
            'The bundled voices render at different sample rates (%s). '
            'Dialogue resamples, so this is not a fault -- it is a decision. '
            'Every German voice at 22050 Hz is either Thorsten, or licensed '
            'CC BY-NC-SA (dii, miro, pavoque -- "commercial use is not '
            'allowed"), or a game character. A second *person* is worth more '
            'to a dialogue than a higher sample rate on a doubled one, so the '
            'cast is CC0 and BSD-3-Clause at 16 kHz instead.' % listing
        )

    # Every voice the app can select must actually be bundled. A roster entry
    # with no file behind it crashes the synthesis isolate the first time
    # somebody plays a dialogue containing that speaker.
    roster = os.path.join(ROOT, 'lib', 'neural_voice.dart')
    if os.path.exists(roster):
        source = io.open(roster, encoding='utf-8').read()
        declared = re.findall(r"model: '([^']+)'", source)
        tokens = re.findall(r"tokens: '([^']+)'", source)
        cards = re.findall(r"card: '([^']+)'", source)
        for name in declared + tokens + cards:
            if not os.path.exists(os.path.join(TTS, name)):
                problems.append(
                    'lib/neural_voice.dart lists %s but assets/tts/%s does '
                    'not exist.' % (name, name)
                )
        if len(set(declared)) != len(declared):
            problems.append(
                'two voices in lib/neural_voice.dart share a model file, so '
                'they are not two people.'
            )
        if declared and len(declared) < 2:
            problems.append(
                'only one voice is declared; multi-speaker dialogue needs at '
                'least two.'
            )

    # The renderer must not go back to refusing a mismatch.
    worker = os.path.join(ROOT, 'lib', 'neural_tts_io.dart')
    if os.path.exists(worker):
        source = io.open(worker, encoding='utf-8').read()
        if 'Bundled voices use different sample rates' in source:
            problems.append(
                'lib/neural_tts_io.dart still throws on a sample-rate '
                'mismatch. That made every two-voice dialogue fail.'
            )
        if '_resampleLinear(' not in source:
            problems.append(
                'lib/neural_tts_io.dart no longer resamples mixed-rate lines, '
                'so a dialogue would play one speaker at the wrong pitch.'
            )

    if problems:
        print('Voice check failed:\n')
        for problem in problems:
            print('  - %s' % problem)
        return 1

    print('Voice check passed: %d voice(s), dialogue resamples safely.'
          % len(rates))
    for note in notes:
        print('\n  note: %s' % note)
    return 0


if __name__ == '__main__':
    sys.exit(main())
