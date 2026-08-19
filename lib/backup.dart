import 'dart:convert';

import 'app_state.dart';
import 'platform_support.dart';

/// Outcome of trying to read a pasted backup.
class BackupImportResult {
  const BackupImportResult.detailed({
    required this.state,
    required this.exportedAt,
    required this.sourcePlatform,
  }) : error = '';

  const BackupImportResult.failure(this.error)
      : state = null,
        exportedAt = '',
        sourcePlatform = '';

  final Map<String, dynamic>? state;
  final String error;
  final String exportedAt;
  final String sourcePlatform;

  bool get isSuccess => state != null;
}

/// Moving a profile between platforms, without a server.
///
/// DeutschGarden has no account system and no backend, which is what keeps it
/// genuinely offline — but it also means a learner who studies on Android and
/// on a Windows desktop has two unrelated profiles. This turns the whole local
/// state into a portable text blob they can carry across by any means they
/// like: clipboard, a text file, a messaging app, a USB stick.
class ProgressBackup {
  const ProgressBackup._();

  static const String magic = 'deutschgarden.backup';
  static const int formatVersion = 1;

  static String export(AppController controller) {
    final Map<String, dynamic> envelope = <String, dynamic>{
      'format': magic,
      'formatVersion': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'platform': PlatformSupport.displayName,
      'state': controller.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Parses and validates a pasted backup without touching app state, so a
  /// malformed paste reports a clear reason instead of half-applying.
  static BackupImportResult parse(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const BackupImportResult.failure('Nothing was pasted.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return const BackupImportResult.failure(
        'That is not valid JSON. Paste the whole backup, including the '
        'opening and closing braces.',
      );
    }

    if (decoded is! Map) {
      return const BackupImportResult.failure(
        'That JSON is not a DeutschGarden backup.',
      );
    }
    final Map<String, dynamic> envelope =
        decoded.map((key, value) => MapEntry(key.toString(), value));

    if (envelope['format'] != magic) {
      return const BackupImportResult.failure(
        'That JSON is not a DeutschGarden backup.',
      );
    }

    final int version = (envelope['formatVersion'] as num?)?.toInt() ?? 0;
    if (version > formatVersion) {
      return BackupImportResult.failure(
        'This backup was written by a newer version of DeutschGarden '
        '(format $version, this build reads $formatVersion). Update the app '
        'first.',
      );
    }

    final Object? state = envelope['state'];
    if (state is! Map) {
      return const BackupImportResult.failure(
        'The backup is missing its state section.',
      );
    }

    return BackupImportResult.detailed(
      state: state.map((key, value) => MapEntry(key.toString(), value)),
      exportedAt: envelope['exportedAt'] as String? ?? 'unknown date',
      sourcePlatform: envelope['platform'] as String? ?? 'unknown platform',
    );
  }

  /// A one-line summary of what a valid backup contains, so the learner can
  /// confirm they are restoring the right profile before it overwrites theirs.
  static String describe(Map<String, dynamic> state) {
    final int xp = (state['xp'] as num?)?.toInt() ?? 0;
    final int streak = (state['streak'] as num?)?.toInt() ?? 0;
    final Object? progress = state['progress'];
    final int words = progress is Map ? progress.length : 0;
    final Object? activities = state['activities'];
    final int lessons = activities is Map ? activities.length : 0;
    return '$xp XP • $streak-day streak • $words words • $lessons activities';
  }
}
