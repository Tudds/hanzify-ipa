import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../features/vocab/domain/entities/vocab.dart';
import '../../features/grammar/domain/entities/grammar_point.dart';
import '../../features/conversation/domain/entities/conversation_context.dart';
import '../utils/pinyin_utils.dart' show normalizePinyin;
import '../../core/utils/vocab_parser.dart' show VocabJsonParser;

part 'app_database.g.dart';

// ============================================================================
// Type Converters
// ============================================================================

/// Safely decode a JSON list string. Returns null if empty, literal "null",
/// or if decoding fails — callers should fall back to an empty list.
List? _safeDecodeList(String fromDb) {
  if (fromDb.isEmpty || fromDb == 'null') return null;
  try {
    final decoded = json.decode(fromDb);
    return decoded is List ? decoded : null;
  } catch (_) {
    return null;
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list.map((e) => e?.toString() ?? '').toList();
  }

  @override
  String toSql(List<String> value) => json.encode(value);
}

class MeaningListConverter extends TypeConverter<List<Meaning>, String> {
  const MeaningListConverter();
  @override
  List<Meaning> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => Meaning.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<Meaning> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class ExampleListConverter
    extends TypeConverter<List<ExampleSentence>, String> {
  const ExampleListConverter();
  @override
  List<ExampleSentence> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<ExampleSentence> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class GrammarExampleListConverter
    extends TypeConverter<List<GrammarExample>, String> {
  const GrammarExampleListConverter();
  @override
  List<GrammarExample> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<GrammarExample> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class FormulaPartListConverter
    extends TypeConverter<List<FormulaPart>, String> {
  const FormulaPartListConverter();
  @override
  List<FormulaPart> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => FormulaPart.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<FormulaPart> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class GrammarUsageListConverter
    extends TypeConverter<List<GrammarUsage>, String> {
  const GrammarUsageListConverter();
  @override
  List<GrammarUsage> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => GrammarUsage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<GrammarUsage> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class DialogueLineListConverter
    extends TypeConverter<List<DialogueLine>, String> {
  const DialogueLineListConverter();
  @override
  List<DialogueLine> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => DialogueLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<DialogueLine> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class VocabInContextListConverter
    extends TypeConverter<List<VocabInContext>, String> {
  const VocabInContextListConverter();
  @override
  List<VocabInContext> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => VocabInContext.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<VocabInContext> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

class SpeakerInfoListConverter
    extends TypeConverter<List<SpeakerInfo>, String> {
  const SpeakerInfoListConverter();
  @override
  List<SpeakerInfo> fromSql(String fromDb) {
    final list = _safeDecodeList(fromDb);
    if (list == null) return [];
    return list
        .map((e) => SpeakerInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<SpeakerInfo> value) =>
      json.encode(value.map((e) => e.toJson()).toList());
}

// ============================================================================
// Tables Schema
// ============================================================================

@DataClassName('VocabDbModel')
class VocabsTable extends Table {
  TextColumn get id => text()();
  TextColumn get hanzi => text()();
  TextColumn get pinyin => text()();
  TextColumn get pinyinNormalized => text()();
  TextColumn get characters => text().map(const StringListConverter())();
  TextColumn get meanings => text().map(const MeaningListConverter())();
  TextColumn get exampleSentences => text().map(const ExampleListConverter())();
  IntColumn get level => integer()();
  TextColumn get wordType => text()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  BoolColumn get isMastered => boolean().withDefault(const Constant(false))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReview => dateTime()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CharacterDbModel')
class CharactersTable extends Table {
  TextColumn get char => text()();
  TextColumn get strokes => text().map(const StringListConverter())();
  IntColumn get hskLevel => integer().nullable()();
  TextColumn get radical => text().nullable()();
  IntColumn get strokeCount => integer().nullable()();
  TextColumn get pinyin => text().nullable()();
  TextColumn get pinyinNormalized => text().nullable()();
  TextColumn get definition => text().nullable()();
  TextColumn get definitionVi => text().nullable()();

  @override
  Set<Column> get primaryKey => {char};
}

@DataClassName('GrammarPointDbModel')
class GrammarPointsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get structure => text()();
  TextColumn get explanation => text()();
  IntColumn get level => integer()();
  TextColumn get category => text()();
  TextColumn get examples => text().map(const GrammarExampleListConverter())();
  TextColumn get relatedGrammar => text().map(const StringListConverter())();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  BoolColumn get isMastered => boolean().withDefault(const Constant(false))();
  TextColumn get formulaParts => text().map(const FormulaPartListConverter())();
  TextColumn get usages => text().map(const GrammarUsageListConverter())();
  TextColumn get exampleTags => text().map(const StringListConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ConversationDbModel')
class ConversationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get titleZh => text()();
  TextColumn get titlePinyin => text()();
  TextColumn get description => text()();
  IntColumn get level => integer()();
  TextColumn get category => text()();
  TextColumn get icon => text()();
  TextColumn get lines => text().map(const DialogueLineListConverter())();
  TextColumn get vocabulary =>
      text().map(const VocabInContextListConverter())();
  TextColumn get speakers => text().map(const SpeakerInfoListConverter())();
  TextColumn get relatedGrammar => text().map(const StringListConverter())();
  TextColumn get cultureTip => text()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  BoolColumn get isMastered => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// Database Connection
// ============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hanzify.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ============================================================================
// AppDatabase
// ============================================================================

@DriftDatabase(
  tables: [
    VocabsTable,
    CharactersTable,
    GrammarPointsTable,
    ConversationsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createAllIndexes(this);
        await DatabaseSeedService(this).seedAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Incremental migrations — không drop-and-recreate nữa
        if (from < 4) {
          // Version 3→4: Thêm GrammarPointsTable + indexes
          await m.createTable(grammarPointsTable);
          await _createIndexes(this);
          await DatabaseSeedService(this).seedGrammar();
        }
        if (from < 5) {
          // Version 4→5: Re-seed grammar data (mở rộng từ 9 lên 66 điểm)
          // Giữ nguyên bảng, chỉ cập nhật dữ liệu
          await DatabaseSeedService(this).seedGrammar();
          debugPrint('[Migration] v4→v5: Re-seeded grammar data');
        }
        if (from < 6) {
          // Version 5→6: Thêm ConversationsTable + indexes
          await m.createTable(conversationsTable);
          await _createConversationIndexes(this);
          await DatabaseSeedService(this).seedConversations();
          debugPrint(
            '[Migration] v5→v6: Added ConversationsTable + seeded data',
          );
        }
        if (from < 7) {
          // Version 6→7: Thêm index còn thiếu cho vocab.hanzi và character.pinyin_normalized
          await _createExtraIndexes(this);
          debugPrint(
            '[Migration] v6→v7: Added hanzi + char pinyin_normalized indexes',
          );
        }
        if (from < 8) {
          // Version 7→8: Xóa column meaning thừa (derive được từ meanings[0].vi)
          await m.alterTable(TableMigration(vocabsTable));
          debugPrint('[Migration] v7→v8: Dropped meaning column from vocabs');
        }
      },
    );
  }

  /// Tạo indexes cho Vocab + Character + Grammar (không gồm Conversation).
  /// Dùng trong onCreate và upgrade v3→v4 (khi ConversationsTable chưa tồn tại).
  static Future<void> _createIndexes(AppDatabase db) async {
    final v = db.vocabsTable.actualTableName;
    final c = db.charactersTable.actualTableName;
    final g = db.grammarPointsTable.actualTableName;

    // Vocab indexes
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_level ON $v (level)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_next_review ON $v (next_review)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_bookmarked ON $v (is_bookmarked)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_mastered ON $v (is_mastered)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_word_type ON $v (word_type)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_pinyin_normalized ON $v (pinyin_normalized)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_hanzi ON $v (hanzi)',
    );

    // Character indexes
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_char_hsk_level ON $c (hsk_level)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_char_pinyin_normalized ON $c (pinyin_normalized)',
    );

    // Grammar indexes
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_level ON $g (level)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_category ON $g (category)',
    );
  }

  /// Tạo tất cả indexes (gồm cả Conversation).
  /// Chỉ dùng trong onCreate khi mọi table đã sẵn.
  static Future<void> _createAllIndexes(AppDatabase db) async {
    await _createIndexes(db);
    await _createConversationIndexes(db);
  }

  /// Idempotent — dùng bởi migration v6→v7 để thêm index đã được
  /// gộp sẵn vào `_createIndexes`. Gọi lại an toàn nhờ IF NOT EXISTS.
  static Future<void> _createExtraIndexes(AppDatabase db) async {
    final v = db.vocabsTable.actualTableName;
    final c = db.charactersTable.actualTableName;
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_hanzi ON $v (hanzi)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_char_pinyin_normalized ON $c (pinyin_normalized)',
    );
  }

  /// Tạo indexes riêng cho ConversationsTable.
  static Future<void> _createConversationIndexes(AppDatabase db) async {
    final cv = db.conversationsTable.actualTableName;
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_level ON $cv (level)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_category ON $cv (category)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_bookmarked ON $cv (is_bookmarked)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_mastered ON $cv (is_mastered)',
    );
  }

  /// Public API cho force reseed (giữ lại cho backward compatibility).
  Future<void> forceSeed() async {
    await DatabaseSeedService(this).seedAll();
  }
}

// ============================================================================
// DatabaseSeedService — Extracted seed logic
// Tách riêng khỏi AppDatabase để dễ maintain và test.
// ============================================================================

class DatabaseSeedService {
  final AppDatabase db;
  DatabaseSeedService(this.db);

  Future<void> seedAll() async {
    await seedVocabs();
    await seedCharacters();
    await seedGrammar();
    await seedConversations();
  }

  // ── Vocab seeding ─────────────────────────────────────────────────────

  Future<void> seedVocabs() async {
    try {
      final List<VocabsTableCompanion> inserts = [];

      final listFiles = ['hsk1.json', 'hsk2.json', 'hsk3.json'];
      for (final fileName in listFiles) {
        final inferredLevel =
            int.tryParse(fileName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);

          if (decoded is List) {
            for (var v in decoded) {
              final map = v as Map<String, dynamic>;
              final id =
                  map['id'] as String? ?? '${map['hanzi']}_$inferredLevel';
              final vocab = VocabJsonParser.parse(
                map,
                id: id,
                defaultLevel: inferredLevel,
              );
              inserts.add(
                _vocabToCompanion(
                  vocab,
                  needsSync: map['needsSync'] as bool? ?? false,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('[Seed] Skipping vocab file $fileName: $e');
        }
      }

      if (inserts.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAll(
            db.vocabsTable,
            inserts,
            mode: InsertMode.insertOrReplace,
          );
        });
        debugPrint('[Seed] Seeded ${inserts.length} vocab items');
      }
    } catch (e) {
      debugPrint('[Seed] Vocab seed error: $e');
    }
  }

  // ── Character seeding ─────────────────────────────────────────────────

  Future<void> seedCharacters() async {
    try {
      final List<CharactersTableCompanion> inserts = [];

      final charFiles = ['char_hsk1.json', 'char_hsk2.json', 'char_hsk3.json'];
      for (final fileName in charFiles) {
        final inferredLevel =
            int.tryParse(fileName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);
          if (decoded is List) {
            for (var cRaw in decoded) {
              final c = cRaw as Map<String, dynamic>;
              final charVal =
                  c['char'] as String? ?? c['character'] as String? ?? '';
              if (charVal.isEmpty) continue;

              final rawStrokes = c['strokes'] as List? ?? [];
              final strokesList = rawStrokes
                  .map((s) {
                    if (s is String) return s;
                    if (s is Map) return s['path'] as String? ?? '';
                    return '';
                  })
                  .where((s) => s.isNotEmpty)
                  .toList();

              final pinyinVal = c['pinyin'] as String?;

              inserts.add(
                CharactersTableCompanion.insert(
                  char: charVal,
                  strokes: strokesList,
                  hskLevel: Value(
                    c['hskLevel'] as int? ??
                        c['level'] as int? ??
                        inferredLevel,
                  ),
                  radical: Value(c['radical'] as String?),
                  strokeCount: Value(
                    c['strokeCount'] as int? ?? strokesList.length,
                  ),
                  pinyin: Value(pinyinVal),
                  pinyinNormalized: Value(
                    c['pinyinNormalized'] as String? ??
                        (pinyinVal != null ? normalizePinyin(pinyinVal) : null),
                  ),
                  definition: Value(c['definition'] as String?),
                  definitionVi: Value(c['definitionVi'] as String?),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('[Seed] Skipping character file $fileName: $e');
        }
      }

      if (inserts.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAll(
            db.charactersTable,
            inserts,
            mode: InsertMode.insertOrReplace,
          );
        });
        debugPrint('[Seed] Seeded ${inserts.length} character items');
      }
    } catch (e) {
      debugPrint('[Seed] Character seed error: $e');
    }
  }

  // ── Grammar seeding ──────────────────────────────────────────────────

  Future<void> seedGrammar() async {
    try {
      // Load grammar data từ JSON asset
      final allPoints = await _loadGrammarFromAssets();
      if (allPoints.isEmpty) return;

      // Lưu trạng thái bookmark/mastered của user trước khi re-seed
      final existingRows = await db.select(db.grammarPointsTable).get();
      final Map<String, (bool, bool)> userState = {};
      for (final row in existingRows) {
        if (row.isBookmarked || row.isMastered) {
          userState[row.id] = (row.isBookmarked, row.isMastered);
        }
      }

      final inserts = allPoints.map((gp) {
        // Giữ lại trạng thái bookmark/mastered của user nếu có
        final saved = userState[gp.id];
        final bookmarked = saved?.$1 ?? gp.isBookmarked;
        final mastered = saved?.$2 ?? gp.isMastered;

        return GrammarPointsTableCompanion.insert(
          id: gp.id,
          title: gp.title,
          structure: gp.structure,
          explanation: gp.explanation,
          level: gp.level,
          category: gp.category,
          examples: gp.examples,
          relatedGrammar: gp.relatedGrammar,
          isBookmarked: Value(bookmarked),
          isMastered: Value(mastered),
          formulaParts: gp.formulaParts,
          usages: gp.usages,
          exampleTags: gp.exampleTags,
        );
      }).toList();

      await db.batch((batch) {
        batch.insertAll(
          db.grammarPointsTable,
          inserts,
          mode: InsertMode.insertOrReplace,
        );
      });
      debugPrint(
        '[Seed] Seeded ${inserts.length} grammar points (preserved ${userState.length} user states)',
      );
    } catch (e) {
      debugPrint('[Seed] Grammar seed error: $e');
    }
  }

  /// Nạp grammar từ JSON asset (`assets/data/grammar.json`).
  /// Dùng GrammarPoint.fromJson() đã cập nhật để parse đầy đủ mọi field.
  /// Nếu JSON asset không load được, log warning và trả về list rỗng
  /// (seeding sẽ bị skip, DB giữ nguyên data cũ).
  Future<List<GrammarPoint>> _loadGrammarFromAssets() async {
    const files = [
      'assets/data/grammar_hsk1.json',
      'assets/data/grammar_hsk2.json',
      'assets/data/grammar_hsk3.json',
    ];
    final results = <GrammarPoint>[];
    for (final path in files) {
      try {
        final jsonStr = await rootBundle.loadString(path);
        final decoded = json.decode(jsonStr) as List;
        results.addAll(
          decoded.map((e) {
            final map = e as Map<String, dynamic>;
            final id = map['id'] as String? ?? '';
            return GrammarPoint.fromJson(id, map);
          }),
        );
      } catch (e) {
        debugPrint('[Seed] Failed to load $path: $e');
      }
    }
    return results;
  }

  // ── Conversation seeding ────────────────────────────────────────────

  Future<void> seedConversations() async {
    try {
      // Load conversation data từ JSON asset
      final allConversations = await _loadConversationsFromAssets();
      if (allConversations.isEmpty) return;

      // Lưu trạng thái bookmark/mastered của user trước khi re-seed
      final existingRows = await db.select(db.conversationsTable).get();
      final Map<String, (bool, bool)> userState = {};
      for (final row in existingRows) {
        if (row.isBookmarked || row.isMastered) {
          userState[row.id] = (row.isBookmarked, row.isMastered);
        }
      }

      final inserts = allConversations.map((conv) {
        // Giữ lại trạng thái bookmark/mastered của user nếu có
        final saved = userState[conv.id];
        final bookmarked = saved?.$1 ?? conv.isBookmarked;
        final mastered = saved?.$2 ?? conv.isMastered;

        return ConversationsTableCompanion.insert(
          id: conv.id,
          title: conv.title,
          titleZh: conv.titleZh,
          titlePinyin: conv.titlePinyin,
          description: conv.description,
          level: conv.level,
          category: conv.category,
          icon: conv.icon,
          lines: conv.lines,
          vocabulary: conv.vocabulary,
          speakers: conv.speakers,
          relatedGrammar: conv.relatedGrammar,
          cultureTip: conv.cultureTip,
          isBookmarked: Value(bookmarked),
          isMastered: Value(mastered),
        );
      }).toList();

      await db.batch((batch) {
        batch.insertAll(
          db.conversationsTable,
          inserts,
          mode: InsertMode.insertOrReplace,
        );
      });
      debugPrint(
        '[Seed] Seeded ${inserts.length} conversations (preserved ${userState.length} user states)',
      );
    } catch (e) {
      debugPrint('[Seed] Conversation seed error: $e');
    }
  }

  /// Nạp conversation từ JSON asset (`assets/data/conversation.json`).
  Future<List<ConversationContext>> _loadConversationsFromAssets() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/conversation.json',
      );
      final decoded = json.decode(jsonStr) as List;
      return decoded.map((e) {
        final map = e as Map<String, dynamic>;
        final id = map['id'] as String? ?? '';
        return ConversationContext.fromJson(id, map);
      }).toList();
    } catch (e) {
      debugPrint('[Seed] Failed to load conversation.json: $e');
      return [];
    }
  }

  // ── Helper: Vocab → Drift Companion (consolidated here) ──────────────

  VocabsTableCompanion _vocabToCompanion(Vocab v, {bool needsSync = false}) {
    return VocabsTableCompanion.insert(
      id: v.id,
      hanzi: v.hanzi,
      pinyin: v.pinyin,
      pinyinNormalized: v.pinyinNormalized,
      characters: v.characters,
      meanings: v.meanings,
      exampleSentences: v.exampleSentences,
      level: v.level,
      wordType: v.wordType,
      isBookmarked: Value(v.isBookmarked),
      isMastered: Value(v.isMastered),
      repetitions: Value(v.repetitions),
      easeFactor: Value(v.easeFactor),
      interval: Value(v.interval),
      nextReview: v.nextReview,
      needsSync: Value(needsSync),
    );
  }
}
