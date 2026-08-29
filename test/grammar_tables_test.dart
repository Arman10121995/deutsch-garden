import 'package:deutsch_garden/grammar_tables.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every CEFR level has at least one reference table', () {
    for (final CefrLevel level in CefrLevel.values) {
      expect(
        grammarReferenceTables
            .where((GrammarReferenceTable table) => table.level == level),
        isNotEmpty,
        reason: '${level.label} has no grammar table',
      );
    }
  });

  test('reference tables are rectangular and uniquely identified', () {
    expect(
      grammarReferenceTables.map((GrammarReferenceTable table) => table.id).toSet(),
      hasLength(grammarReferenceTables.length),
    );
    for (final GrammarReferenceTable table in grammarReferenceTables) {
      expect(table.columns.length, greaterThanOrEqualTo(3), reason: table.id);
      expect(table.rows, isNotEmpty, reason: table.id);
      for (final List<String> row in table.rows) {
        expect(row, hasLength(table.columns.length), reason: table.id);
        expect(row.every((String cell) => cell.trim().isNotEmpty), isTrue,
            reason: table.id);
      }
    }
  });
}
