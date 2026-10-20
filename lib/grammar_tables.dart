/// Compact grammar reference tables used by lessons and the handbook.
library;

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'curriculum_text.dart';
import 'models.dart';
import 'grammar_reference_data.dart';
import 'sentence_audio.dart';

export 'grammar_reference_data.dart';

class GrammarTableCard extends StatelessWidget {
  const GrammarTableCard({
    super.key,
    required this.table,
    this.ttsEnabled = true,
  });

  final GrammarReferenceTable table;
  final bool ttsEnabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              curriculumText(AppText.of(context), table.title),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: table.columns.length * 138.0,
                child: Table(
                  border: TableBorder.all(color: scheme.outlineVariant),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: BoxDecoration(color: scheme.primaryContainer),
                      children: <Widget>[
                        for (final String column in table.columns)
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Text(
                              curriculumText(AppText.of(context), column),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final List<String> row in table.rows)
                      TableRow(
                        children: <Widget>[
                          for (int index = 0; index < row.length; index++)
                            Padding(
                              padding: const EdgeInsets.all(9),
                              child:
                                  table.columns[index].toLowerCase().contains(
                                    'example',
                                  )
                                  ? Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            curriculumText(
                                              AppText.of(context),
                                              row[index],
                                            ),
                                          ),
                                        ),
                                        SentenceAudioButton(
                                          text: row[index],
                                          enabled: ttsEnabled,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      curriculumText(
                                        AppText.of(context),
                                        row[index],
                                      ),
                                    ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              curriculumText(AppText.of(context), table.note),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class GrammarTablesScreen extends StatefulWidget {
  const GrammarTablesScreen({
    super.key,
    this.initialLevel = CefrLevel.a1,
    this.ttsEnabled = true,
  });

  final CefrLevel initialLevel;
  final bool ttsEnabled;

  @override
  State<GrammarTablesScreen> createState() => _GrammarTablesScreenState();
}

class _GrammarTablesScreenState extends State<GrammarTablesScreen> {
  late CefrLevel _level;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    final List<GrammarReferenceTable> tables = grammarReferenceTables
        .where((GrammarReferenceTable table) => table.level == _level)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).guideGrammarTables)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<CefrLevel>(
              segments: <ButtonSegment<CefrLevel>>[
                for (final CefrLevel level in CefrLevel.values)
                  ButtonSegment<CefrLevel>(
                    value: level,
                    label: Text(level.label),
                  ),
              ],
              selected: <CefrLevel>{_level},
              onSelectionChanged: (Set<CefrLevel> value) =>
                  setState(() => _level = value.single),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppText.of(context).guideLevelReference(_level.label),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(AppText.of(context).guideTablesIntro),
          const SizedBox(height: 14),
          for (final GrammarReferenceTable table in tables) ...<Widget>[
            GrammarTableCard(table: table, ttsEnabled: widget.ttsEnabled),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
