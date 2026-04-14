import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;

import '../../features/vocab/domain/entities/vocab.dart';

part 'app_database.g.dart';

// ============================================================================
// Type Converters
// ============================================================================

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(json.decode(fromDb));
  }
  @override
  String toSql(List<String> value) => json.encode(value);
}

class MeaningListConverter extends TypeConverter<List<Meaning>, String> {
  const MeaningListConverter();
  @override
  List<Meaning> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final list = json.decode(fromDb) as List;
    return list.map((e) => Meaning.fromJson(e as Map<String, dynamic>)).toList();
  }
  @override
  String toSql(List<Meaning> value) => json.encode(value.map((e) => e.toJson()).toList());
}

class ExampleListConverter extends TypeConverter<List<ExampleSentence>, String> {
  const ExampleListConverter();
  @override
  List<ExampleSentence> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final list = json.decode(fromDb) as List;
    return list.map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>)).toList();
  }
  @override
  String toSql(List<ExampleSentence> value) => json.encode(value.map((e) => e.toJson()).toList());
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
  TextColumn get meaning => text()();
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

// ============================================================================
// Database & Seeding Strategy
// ============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hanzify.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [VocabsTable, CharactersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed Database with JSON initial data
        await _seedVocabs();
        await _seedCharacters();
      },
    );
  }

  Future<void> forceSeed() async {
    await _seedVocabs();
  }

  Future<void> _seedVocabs() async {
    try {
      final List<VocabsTableCompanion> inserts = [];

      void addVocab(Map<String, dynamic> v, String id) {
        final meaningsList = (v['meanings'] as List?)?.map((m) {
              final map = m as Map<String, dynamic>;
              return Meaning(
                pos: map['pos'] as String? ?? 'other',
                vi: map['vi'] as String? ?? '',
                en: map['en'] as String? ?? '',
              );
            }).toList() ??
            [];

        final meaningFlat = v['meaning'] as String? ??
            meaningsList.map((m) => '${m.pos}. ${m.vi}').join('; ');

        final examplesList = (v['exampleSentences'] as List?)?.map((e) {
              if (e is Map) {
                final map = e as Map<String, dynamic>;
                return ExampleSentence(
                  cn: map['cn'] as String? ?? '',
                  pinyin: map['pinyin'] as String? ?? '',
                  vi: map['vi'] as String? ?? '',
                );
              }
              return ExampleSentence(cn: e as String, pinyin: '', vi: '');
            }).toList() ??
            [];

        final wordType = v['wordType'] as String? ??
            (meaningsList.isNotEmpty ? meaningsList.first.pos : 'other');
            
        final hanziStr = v['hanzi'] as String? ?? '';
        final pinyinStr = v['pinyin'] as String? ?? '';

        inserts.add(
          VocabsTableCompanion.insert(
            id: id,
            hanzi: hanziStr,
            pinyin: pinyinStr,
            pinyinNormalized: _normalizePinyinLocal(v['pinyinNormalized'] as String? ?? pinyinStr),
            characters: List<String>.from((v['characters'] as List?) ?? hanziStr.split('')),
            meanings: meaningsList,
            meaning: meaningFlat,
            exampleSentences: examplesList,
            level: v['level'] as int? ?? 1,
            wordType: wordType,
            isBookmarked: Value(v['isBookmarked'] as bool? ?? false),
            isMastered: Value(v['isMastered'] as bool? ?? false),
            repetitions: Value(v['repetitions'] as int? ?? 0),
            easeFactor: Value((v['easeFactor'] as num?)?.toDouble() ?? 2.5),
            interval: Value(v['interval'] as int? ?? v['srsInterval'] as int? ?? 0),
            nextReview: DateTime.parse(
              v['nextReview'] as String? ?? DateTime.now().toUtc().toIso8601String(),
            ),
            needsSync: Value(v['needsSync'] as bool? ?? false),
          ),
        );
      }

      final listFiles = ['hsk1.json', 'hsk2.json', 'hsk3.json', 'hsk4.json', 'hsk5.json', 'hsk6.json'];
      for (final fileName in listFiles) {
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);

          if (decoded is List) {
            for (var v in decoded) {
              final map = v as Map<String, dynamic>;
              final id = map['id'] as String? ?? '${map['hanzi']}_${map['level']}';
              addVocab(map, id);
            }
          } else if (decoded is Map) {
            for (var e in decoded.entries) {
              addVocab(e.value as Map<String, dynamic>, e.key);
            }
          }
        } catch (e) {
          // ignore: avoid_print
          print('⚠️ [Drift] Skipping $fileName: $e');
        }
      }

      if (inserts.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(vocabsTable, inserts, mode: InsertMode.insertOrReplace);
        });
        // ignore: avoid_print
        print('✅ [Drift] Seeded ${inserts.length} vocab items');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ [Drift] Vocab seed error: $e');
    }
  }

  Future<void> _seedCharacters() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/char_base.json');
      final List<dynamic> charList = json.decode(jsonStr);

      final List<CharactersTableCompanion> inserts = [];

      void addChar(Map<String, dynamic> c) {
        final charVal = c['char'] as String? ?? c['character'] as String? ?? '';
        final rawStrokes = c['strokes'] as List? ?? [];
        final strokesList = rawStrokes.map((s) {
          if (s is String) return s;
          if (s is Map) return s['path'] as String? ?? '';
          return '';
        }).where((s) => s.isNotEmpty).toList();

        final pinyinVal = c['pinyin'] as String?;

        inserts.add(CharactersTableCompanion.insert(
          char: charVal,
          strokes: strokesList,
          hskLevel: Value(c['hskLevel'] as int? ?? c['level'] as int?),
          radical: Value(c['radical'] as String?),
          strokeCount: Value(c['strokeCount'] as int? ?? strokesList.length),
          pinyin: Value(pinyinVal),
          pinyinNormalized: Value(
              c['pinyinNormalized'] as String? ?? (pinyinVal != null ? _normalizePinyinLocal(pinyinVal) : null)),
          definition: Value(c['definition'] as String?),
          definitionVi: Value(c['definitionVi'] as String?),
        ));
      }

      for (var c in charList) {
        addChar(c as Map<String, dynamic>);
      }

      try {
        final ext = await rootBundle.loadString('assets/data/char_hsk56.json');
        final extList = json.decode(ext) as List;
        for (var c in extList) {
          addChar(c as Map<String, dynamic>);
        }
      } catch (_) {}

      await batch((batch) {
        batch.insertAll(charactersTable, inserts, mode: InsertMode.insertOrReplace);
      });
      // ignore: avoid_print
      print('✅ [Drift] Seeded ${inserts.length} character items');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [Drift] Character seed error: $e');
    }
  }

  static String _normalizePinyinLocal(String pinyin) {
    const toneMap = {
      'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
      'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
      'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
      'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
      'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
      'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
    };
    var result = pinyin.toLowerCase();
    toneMap.forEach((t, p_) => result = result.replaceAll(t, p_));
    return result.replaceAll(RegExp(r'[\s\d]'), '');
  }
}
