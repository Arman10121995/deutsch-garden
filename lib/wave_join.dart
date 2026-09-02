import 'dart:typed_data';

/// One PCM WAV recording followed by a requested silent gap.
class WaveSegment {
  const WaveSegment(this.bytes, {this.gapAfter = Duration.zero});

  final Uint8List bytes;
  final Duration gapAfter;
}

/// Joins compatible PCM/float WAV recordings into one canonical WAV.
///
/// Android's local text-to-speech engine writes one file per utterance. This
/// parser preserves only each `data` chunk, verifies that every voice uses the
/// same format, and inserts sample-accurate silence between speakers. It does
/// not assume a 44-byte input header because engines may add metadata chunks.
Uint8List joinWaveSegments(List<WaveSegment> segments) {
  if (segments.isEmpty) {
    throw const FormatException('At least one WAV segment is required');
  }
  final List<_ParsedWave> waves = segments
      .map((WaveSegment segment) => _parseWave(segment.bytes))
      .toList(growable: false);
  final _ParsedWave highestRate = waves.reduce(
    (_ParsedWave a, _ParsedWave b) =>
        a.format.sampleRate >= b.format.sampleRate ? a : b,
  );
  final _WaveFormat format = highestRate.format;
  final List<Uint8List> recordings = <Uint8List>[];
  for (final _ParsedWave wave in waves) {
    if (!wave.format.isEncodingCompatibleWith(format)) {
      throw FormatException(
        'TTS voices produced incompatible WAVs: ${wave.format} vs $format',
      );
    }
    recordings.add(_resample(wave, format.sampleRate));
  }

  var dataLength = 0;
  for (var i = 0; i < recordings.length; i++) {
    dataLength += recordings[i].length;
    if (i + 1 < recordings.length) {
      dataLength += _gapBytes(format, segments[i].gapAfter);
    }
  }
  final Uint8List output = Uint8List(44 + dataLength);
  final ByteData header = ByteData.sublistView(output);
  _ascii(output, 0, 'RIFF');
  header.setUint32(4, 36 + dataLength, Endian.little);
  _ascii(output, 8, 'WAVE');
  _ascii(output, 12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, format.audioFormat, Endian.little);
  header.setUint16(22, format.channels, Endian.little);
  header.setUint32(24, format.sampleRate, Endian.little);
  header.setUint32(28, format.byteRate, Endian.little);
  header.setUint16(32, format.blockAlign, Endian.little);
  header.setUint16(34, format.bitsPerSample, Endian.little);
  _ascii(output, 36, 'data');
  header.setUint32(40, dataLength, Endian.little);

  var offset = 44;
  for (var i = 0; i < recordings.length; i++) {
    output.setAll(offset, recordings[i]);
    offset += recordings[i].length;
    if (i + 1 >= recordings.length) continue;
    final int silenceLength = _gapBytes(format, segments[i].gapAfter);
    if (format.audioFormat == 1 && format.bitsPerSample == 8) {
      output.fillRange(offset, offset + silenceLength, 0x80);
    }
    offset += silenceLength;
  }
  return output;
}

Uint8List _resample(_ParsedWave wave, int targetRate) {
  final _WaveFormat format = wave.format;
  if (format.sampleRate == targetRate) return wave.data;
  final int sourceFrames = wave.data.length ~/ format.blockAlign;
  if (sourceFrames == 0) return Uint8List(0);
  final int targetFrames = (sourceFrames * targetRate / format.sampleRate)
      .round()
      .clamp(1, 1 << 30);
  final Uint8List out = Uint8List(targetFrames * format.blockAlign);
  final ByteData source = ByteData.sublistView(wave.data);
  final ByteData target = ByteData.sublistView(out);

  for (var frame = 0; frame < targetFrames; frame++) {
    final double sourcePosition = frame * format.sampleRate / targetRate;
    final int left = sourcePosition.floor().clamp(0, sourceFrames - 1);
    final int right = (left + 1).clamp(0, sourceFrames - 1);
    final double mix = sourcePosition - left;
    for (var channel = 0; channel < format.channels; channel++) {
      final int leftOffset =
          left * format.blockAlign + channel * format.bitsPerSample ~/ 8;
      final int rightOffset =
          right * format.blockAlign + channel * format.bitsPerSample ~/ 8;
      final int targetOffset =
          frame * format.blockAlign + channel * format.bitsPerSample ~/ 8;
      if (format.audioFormat == 1 && format.bitsPerSample == 16) {
        final int a = source.getInt16(leftOffset, Endian.little);
        final int b = source.getInt16(rightOffset, Endian.little);
        target.setInt16(
          targetOffset,
          (a + (b - a) * mix).round().clamp(-32768, 32767),
          Endian.little,
        );
      } else if (format.audioFormat == 1 && format.bitsPerSample == 8) {
        final int a = source.getUint8(leftOffset);
        final int b = source.getUint8(rightOffset);
        target.setUint8(targetOffset, (a + (b - a) * mix).round());
      } else if (format.audioFormat == 3 && format.bitsPerSample == 32) {
        final double a = source.getFloat32(leftOffset, Endian.little);
        final double b = source.getFloat32(rightOffset, Endian.little);
        target.setFloat32(targetOffset, a + (b - a) * mix, Endian.little);
      } else {
        throw FormatException(
          'Cannot resample WAV format ${format.audioFormat}/'
          '${format.bitsPerSample}-bit',
        );
      }
    }
  }
  return out;
}

int _gapBytes(_WaveFormat format, Duration duration) {
  final int frames = (format.sampleRate * duration.inMicroseconds / 1000000)
      .round();
  return frames * format.blockAlign;
}

_ParsedWave _parseWave(Uint8List bytes) {
  if (bytes.length < 44 ||
      _readAscii(bytes, 0, 4) != 'RIFF' ||
      _readAscii(bytes, 8, 4) != 'WAVE') {
    throw const FormatException('Not a RIFF/WAVE file');
  }
  final ByteData data = ByteData.sublistView(bytes);
  _WaveFormat? format;
  Uint8List? samples;
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final String id = _readAscii(bytes, offset, 4);
    final int length = data.getUint32(offset + 4, Endian.little);
    final int start = offset + 8;
    final int end = start + length;
    if (end > bytes.length) {
      throw const FormatException('Truncated WAV chunk');
    }
    if (id == 'fmt ' && length >= 16) {
      final int audioFormat = data.getUint16(start, Endian.little);
      if (audioFormat != 1 && audioFormat != 3) {
        throw FormatException('Unsupported WAV format $audioFormat');
      }
      format = _WaveFormat(
        audioFormat: audioFormat,
        channels: data.getUint16(start + 2, Endian.little),
        sampleRate: data.getUint32(start + 4, Endian.little),
        byteRate: data.getUint32(start + 8, Endian.little),
        blockAlign: data.getUint16(start + 12, Endian.little),
        bitsPerSample: data.getUint16(start + 14, Endian.little),
      );
    } else if (id == 'data') {
      samples = Uint8List.fromList(bytes.sublist(start, end));
    }
    offset = end + (length.isOdd ? 1 : 0);
  }
  if (format == null || samples == null) {
    throw const FormatException('WAV is missing fmt or data');
  }
  if (format.channels <= 0 ||
      format.sampleRate <= 0 ||
      format.blockAlign <= 0 ||
      format.byteRate <= 0 ||
      samples.length % format.blockAlign != 0) {
    throw const FormatException('Invalid WAV format values');
  }
  return _ParsedWave(format, samples);
}

void _ascii(Uint8List target, int offset, String text) {
  for (var i = 0; i < text.length; i++) {
    target[offset + i] = text.codeUnitAt(i);
  }
}

String _readAscii(Uint8List bytes, int offset, int length) =>
    String.fromCharCodes(bytes.sublist(offset, offset + length));

class _ParsedWave {
  const _ParsedWave(this.format, this.data);

  final _WaveFormat format;
  final Uint8List data;
}

class _WaveFormat {
  const _WaveFormat({
    required this.audioFormat,
    required this.channels,
    required this.sampleRate,
    required this.byteRate,
    required this.blockAlign,
    required this.bitsPerSample,
  });

  final int audioFormat;
  final int channels;
  final int sampleRate;
  final int byteRate;
  final int blockAlign;
  final int bitsPerSample;

  bool isEncodingCompatibleWith(_WaveFormat other) =>
      audioFormat == other.audioFormat &&
      channels == other.channels &&
      blockAlign == other.blockAlign &&
      bitsPerSample == other.bitsPerSample;

  @override
  String toString() =>
      '$audioFormat/${channels}ch/${sampleRate}Hz/${bitsPerSample}bit';

  @override
  bool operator ==(Object other) =>
      other is _WaveFormat &&
      audioFormat == other.audioFormat &&
      channels == other.channels &&
      sampleRate == other.sampleRate &&
      byteRate == other.byteRate &&
      blockAlign == other.blockAlign &&
      bitsPerSample == other.bitsPerSample;

  @override
  int get hashCode => Object.hash(
    audioFormat,
    channels,
    sampleRate,
    byteRate,
    blockAlign,
    bitsPerSample,
  );
}
