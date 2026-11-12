"""Generate original, quiet UI tones. No external recordings or packages.

Run with --check to verify the committed PCM WAVs byte for byte.
"""
import io
import math
from pathlib import Path
import struct
import sys
import wave

ROOT = Path(__file__).resolve().parents[1] / 'assets/sounds'
RATE = 22050
NOTES = {
    'click': [(1046.5, .03)],
    'success': [(523.25, .07), (659.25, .07), (783.99, .07)],
    'failure': [(349.23, .11), (293.66, .11)],
    'achievement': [(783.99, .1), (1046.5, .2)],
    'complete': [(523.25, .1), (659.25, .1), (783.99, .1), (1046.5, .24)],
}


def render(notes):
    samples = []
    for frequency, seconds in notes:
        count = round(seconds * RATE)
        for i in range(count):
            # Smooth endpoints, restrained harmonics and -16 dBFS peak.
            envelope = min(1, i / (RATE * .005), (count - 1 - i) / (RATE * .012))
            phase = 2 * math.pi * frequency * i / RATE
            value = .15 * envelope * (.88 * math.sin(phase) + .12 * math.sin(phase * 2))
            samples.append(round(32767 * value))
    stream = io.BytesIO()
    with wave.open(stream, 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(struct.pack('<%dh' % len(samples), *samples))
    return stream.getvalue()


if __name__ == '__main__':
    ROOT.mkdir(parents=True, exist_ok=True)
    for name, notes in NOTES.items():
        path = ROOT / f'{name}.wav'
        data = render(notes)
        if '--check' in sys.argv:
            if not path.exists() or path.read_bytes() != data:
                raise SystemExit(f'Stale UI sound: {path.name}')
        else:
            path.write_bytes(data)
    print('Five original UI sounds verified.' if '--check' in sys.argv else 'Five original UI sounds generated.')
