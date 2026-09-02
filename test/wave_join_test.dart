import 'dart:typed_data';

import 'package:deutsch_garden/wave_join.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('joins PCM data and inserts sample-accurate silence', () {
    final Uint8List joined = joinWaveSegments(<WaveSegment>[
      WaveSegment(
        _pcmWave(<int>[1, 2, 3, 4]),
        gapAfter: const Duration(milliseconds: 10),
      ),
      WaveSegment(_pcmWave(<int>[5, 6, 7, 8])),
    ]);
    final ByteData header = ByteData.sublistView(joined);

    expect(String.fromCharCodes(joined.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(joined.sublist(8, 12)), 'WAVE');
    expect(header.getUint32(40, Endian.little), 28);
    expect(joined.length, 72);
    expect(joined.sublist(44, 48), <int>[1, 2, 3, 4]);
    expect(joined.sublist(48, 68), everyElement(0));
    expect(joined.sublist(68), <int>[5, 6, 7, 8]);
  });

  test('resamples compatible voice segments to the highest sample rate', () {
    final Uint8List joined = joinWaveSegments(<WaveSegment>[
      WaveSegment(_pcmWave(<int>[1, 2], sampleRate: 1000)),
      WaveSegment(_pcmWave(<int>[3, 4], sampleRate: 2000)),
    ]);
    expect(ByteData.sublistView(joined).getUint32(24, Endian.little), 2000);
  });

  test('rejects voice segments with incompatible channel layouts', () {
    expect(
      () => joinWaveSegments(<WaveSegment>[
        WaveSegment(_pcmWave(<int>[1, 2], channels: 1)),
        WaveSegment(_pcmWave(<int>[3, 4, 5, 6], channels: 2)),
      ]),
      throwsFormatException,
    );
  });
}

Uint8List _pcmWave(
  List<int> samples, {
  int sampleRate = 1000,
  int channels = 1,
}) {
  const int bitsPerSample = 16;
  final int blockAlign = channels * bitsPerSample ~/ 8;
  final int byteRate = sampleRate * blockAlign;
  final Uint8List out = Uint8List(44 + samples.length);
  final ByteData data = ByteData.sublistView(out);
  _ascii(out, 0, 'RIFF');
  data.setUint32(4, 36 + samples.length, Endian.little);
  _ascii(out, 8, 'WAVE');
  _ascii(out, 12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, byteRate, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  _ascii(out, 36, 'data');
  data.setUint32(40, samples.length, Endian.little);
  out.setAll(44, samples);
  return out;
}

void _ascii(Uint8List target, int offset, String text) {
  for (var i = 0; i < text.length; i++) {
    target[offset + i] = text.codeUnitAt(i);
  }
}
