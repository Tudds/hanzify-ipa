// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VocabsTableTable extends VocabsTable
    with TableInfo<$VocabsTableTable, VocabDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hanziMeta = const VerificationMeta('hanzi');
  @override
  late final GeneratedColumn<String> hanzi = GeneratedColumn<String>(
    'hanzi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinNormalizedMeta = const VerificationMeta(
    'pinyinNormalized',
  );
  @override
  late final GeneratedColumn<String> pinyinNormalized = GeneratedColumn<String>(
    'pinyin_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> characters =
      GeneratedColumn<String>(
        'characters',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($VocabsTableTable.$convertercharacters);
  @override
  late final GeneratedColumnWithTypeConverter<List<Meaning>, String> meanings =
      GeneratedColumn<String>(
        'meanings',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<Meaning>>($VocabsTableTable.$convertermeanings);
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ExampleSentence>, String>
  exampleSentences =
      GeneratedColumn<String>(
        'example_sentences',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<ExampleSentence>>(
        $VocabsTableTable.$converterexampleSentences,
      );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordTypeMeta = const VerificationMeta(
    'wordType',
  );
  @override
  late final GeneratedColumn<String> wordType = GeneratedColumn<String>(
    'word_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isMasteredMeta = const VerificationMeta(
    'isMastered',
  );
  @override
  late final GeneratedColumn<bool> isMastered = GeneratedColumn<bool>(
    'is_mastered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mastered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hanzi,
    pinyin,
    pinyinNormalized,
    characters,
    meanings,
    meaning,
    exampleSentences,
    level,
    wordType,
    isBookmarked,
    isMastered,
    repetitions,
    easeFactor,
    interval,
    nextReview,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hanzi')) {
      context.handle(
        _hanziMeta,
        hanzi.isAcceptableOrUnknown(data['hanzi']!, _hanziMeta),
      );
    } else if (isInserting) {
      context.missing(_hanziMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('pinyin_normalized')) {
      context.handle(
        _pinyinNormalizedMeta,
        pinyinNormalized.isAcceptableOrUnknown(
          data['pinyin_normalized']!,
          _pinyinNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pinyinNormalizedMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('word_type')) {
      context.handle(
        _wordTypeMeta,
        wordType.isAcceptableOrUnknown(data['word_type']!, _wordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_wordTypeMeta);
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('is_mastered')) {
      context.handle(
        _isMasteredMeta,
        isMastered.isAcceptableOrUnknown(data['is_mastered']!, _isMasteredMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hanzi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanzi'],
      )!,
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      )!,
      pinyinNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_normalized'],
      )!,
      characters: $VocabsTableTable.$convertercharacters.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}characters'],
        )!,
      ),
      meanings: $VocabsTableTable.$convertermeanings.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meanings'],
        )!,
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      exampleSentences: $VocabsTableTable.$converterexampleSentences.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}example_sentences'],
        )!,
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      wordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_type'],
      )!,
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      isMastered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mastered'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      )!,
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $VocabsTableTable createAlias(String alias) {
    return $VocabsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertercharacters =
      const StringListConverter();
  static TypeConverter<List<Meaning>, String> $convertermeanings =
      const MeaningListConverter();
  static TypeConverter<List<ExampleSentence>, String>
  $converterexampleSentences = const ExampleListConverter();
}

class VocabDbModel extends DataClass implements Insertable<VocabDbModel> {
  final String id;
  final String hanzi;
  final String pinyin;
  final String pinyinNormalized;
  final List<String> characters;
  final List<Meaning> meanings;
  final String meaning;
  final List<ExampleSentence> exampleSentences;
  final int level;
  final String wordType;
  final bool isBookmarked;
  final bool isMastered;
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime nextReview;
  final bool needsSync;
  const VocabDbModel({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.pinyinNormalized,
    required this.characters,
    required this.meanings,
    required this.meaning,
    required this.exampleSentences,
    required this.level,
    required this.wordType,
    required this.isBookmarked,
    required this.isMastered,
    required this.repetitions,
    required this.easeFactor,
    required this.interval,
    required this.nextReview,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hanzi'] = Variable<String>(hanzi);
    map['pinyin'] = Variable<String>(pinyin);
    map['pinyin_normalized'] = Variable<String>(pinyinNormalized);
    {
      map['characters'] = Variable<String>(
        $VocabsTableTable.$convertercharacters.toSql(characters),
      );
    }
    {
      map['meanings'] = Variable<String>(
        $VocabsTableTable.$convertermeanings.toSql(meanings),
      );
    }
    map['meaning'] = Variable<String>(meaning);
    {
      map['example_sentences'] = Variable<String>(
        $VocabsTableTable.$converterexampleSentences.toSql(exampleSentences),
      );
    }
    map['level'] = Variable<int>(level);
    map['word_type'] = Variable<String>(wordType);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['is_mastered'] = Variable<bool>(isMastered);
    map['repetitions'] = Variable<int>(repetitions);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval'] = Variable<int>(interval);
    map['next_review'] = Variable<DateTime>(nextReview);
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  VocabsTableCompanion toCompanion(bool nullToAbsent) {
    return VocabsTableCompanion(
      id: Value(id),
      hanzi: Value(hanzi),
      pinyin: Value(pinyin),
      pinyinNormalized: Value(pinyinNormalized),
      characters: Value(characters),
      meanings: Value(meanings),
      meaning: Value(meaning),
      exampleSentences: Value(exampleSentences),
      level: Value(level),
      wordType: Value(wordType),
      isBookmarked: Value(isBookmarked),
      isMastered: Value(isMastered),
      repetitions: Value(repetitions),
      easeFactor: Value(easeFactor),
      interval: Value(interval),
      nextReview: Value(nextReview),
      needsSync: Value(needsSync),
    );
  }

  factory VocabDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabDbModel(
      id: serializer.fromJson<String>(json['id']),
      hanzi: serializer.fromJson<String>(json['hanzi']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      pinyinNormalized: serializer.fromJson<String>(json['pinyinNormalized']),
      characters: serializer.fromJson<List<String>>(json['characters']),
      meanings: serializer.fromJson<List<Meaning>>(json['meanings']),
      meaning: serializer.fromJson<String>(json['meaning']),
      exampleSentences: serializer.fromJson<List<ExampleSentence>>(
        json['exampleSentences'],
      ),
      level: serializer.fromJson<int>(json['level']),
      wordType: serializer.fromJson<String>(json['wordType']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      isMastered: serializer.fromJson<bool>(json['isMastered']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      interval: serializer.fromJson<int>(json['interval']),
      nextReview: serializer.fromJson<DateTime>(json['nextReview']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hanzi': serializer.toJson<String>(hanzi),
      'pinyin': serializer.toJson<String>(pinyin),
      'pinyinNormalized': serializer.toJson<String>(pinyinNormalized),
      'characters': serializer.toJson<List<String>>(characters),
      'meanings': serializer.toJson<List<Meaning>>(meanings),
      'meaning': serializer.toJson<String>(meaning),
      'exampleSentences': serializer.toJson<List<ExampleSentence>>(
        exampleSentences,
      ),
      'level': serializer.toJson<int>(level),
      'wordType': serializer.toJson<String>(wordType),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'isMastered': serializer.toJson<bool>(isMastered),
      'repetitions': serializer.toJson<int>(repetitions),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'interval': serializer.toJson<int>(interval),
      'nextReview': serializer.toJson<DateTime>(nextReview),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  VocabDbModel copyWith({
    String? id,
    String? hanzi,
    String? pinyin,
    String? pinyinNormalized,
    List<String>? characters,
    List<Meaning>? meanings,
    String? meaning,
    List<ExampleSentence>? exampleSentences,
    int? level,
    String? wordType,
    bool? isBookmarked,
    bool? isMastered,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReview,
    bool? needsSync,
  }) => VocabDbModel(
    id: id ?? this.id,
    hanzi: hanzi ?? this.hanzi,
    pinyin: pinyin ?? this.pinyin,
    pinyinNormalized: pinyinNormalized ?? this.pinyinNormalized,
    characters: characters ?? this.characters,
    meanings: meanings ?? this.meanings,
    meaning: meaning ?? this.meaning,
    exampleSentences: exampleSentences ?? this.exampleSentences,
    level: level ?? this.level,
    wordType: wordType ?? this.wordType,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    isMastered: isMastered ?? this.isMastered,
    repetitions: repetitions ?? this.repetitions,
    easeFactor: easeFactor ?? this.easeFactor,
    interval: interval ?? this.interval,
    nextReview: nextReview ?? this.nextReview,
    needsSync: needsSync ?? this.needsSync,
  );
  VocabDbModel copyWithCompanion(VocabsTableCompanion data) {
    return VocabDbModel(
      id: data.id.present ? data.id.value : this.id,
      hanzi: data.hanzi.present ? data.hanzi.value : this.hanzi,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      pinyinNormalized: data.pinyinNormalized.present
          ? data.pinyinNormalized.value
          : this.pinyinNormalized,
      characters: data.characters.present
          ? data.characters.value
          : this.characters,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      exampleSentences: data.exampleSentences.present
          ? data.exampleSentences.value
          : this.exampleSentences,
      level: data.level.present ? data.level.value : this.level,
      wordType: data.wordType.present ? data.wordType.value : this.wordType,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      isMastered: data.isMastered.present
          ? data.isMastered.value
          : this.isMastered,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      interval: data.interval.present ? data.interval.value : this.interval,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabDbModel(')
          ..write('id: $id, ')
          ..write('hanzi: $hanzi, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinNormalized: $pinyinNormalized, ')
          ..write('characters: $characters, ')
          ..write('meanings: $meanings, ')
          ..write('meaning: $meaning, ')
          ..write('exampleSentences: $exampleSentences, ')
          ..write('level: $level, ')
          ..write('wordType: $wordType, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('isMastered: $isMastered, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('nextReview: $nextReview, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hanzi,
    pinyin,
    pinyinNormalized,
    characters,
    meanings,
    meaning,
    exampleSentences,
    level,
    wordType,
    isBookmarked,
    isMastered,
    repetitions,
    easeFactor,
    interval,
    nextReview,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabDbModel &&
          other.id == this.id &&
          other.hanzi == this.hanzi &&
          other.pinyin == this.pinyin &&
          other.pinyinNormalized == this.pinyinNormalized &&
          other.characters == this.characters &&
          other.meanings == this.meanings &&
          other.meaning == this.meaning &&
          other.exampleSentences == this.exampleSentences &&
          other.level == this.level &&
          other.wordType == this.wordType &&
          other.isBookmarked == this.isBookmarked &&
          other.isMastered == this.isMastered &&
          other.repetitions == this.repetitions &&
          other.easeFactor == this.easeFactor &&
          other.interval == this.interval &&
          other.nextReview == this.nextReview &&
          other.needsSync == this.needsSync);
}

class VocabsTableCompanion extends UpdateCompanion<VocabDbModel> {
  final Value<String> id;
  final Value<String> hanzi;
  final Value<String> pinyin;
  final Value<String> pinyinNormalized;
  final Value<List<String>> characters;
  final Value<List<Meaning>> meanings;
  final Value<String> meaning;
  final Value<List<ExampleSentence>> exampleSentences;
  final Value<int> level;
  final Value<String> wordType;
  final Value<bool> isBookmarked;
  final Value<bool> isMastered;
  final Value<int> repetitions;
  final Value<double> easeFactor;
  final Value<int> interval;
  final Value<DateTime> nextReview;
  final Value<bool> needsSync;
  final Value<int> rowid;
  const VocabsTableCompanion({
    this.id = const Value.absent(),
    this.hanzi = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.pinyinNormalized = const Value.absent(),
    this.characters = const Value.absent(),
    this.meanings = const Value.absent(),
    this.meaning = const Value.absent(),
    this.exampleSentences = const Value.absent(),
    this.level = const Value.absent(),
    this.wordType = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabsTableCompanion.insert({
    required String id,
    required String hanzi,
    required String pinyin,
    required String pinyinNormalized,
    required List<String> characters,
    required List<Meaning> meanings,
    required String meaning,
    required List<ExampleSentence> exampleSentences,
    required int level,
    required String wordType,
    this.isBookmarked = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    required DateTime nextReview,
    this.needsSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hanzi = Value(hanzi),
       pinyin = Value(pinyin),
       pinyinNormalized = Value(pinyinNormalized),
       characters = Value(characters),
       meanings = Value(meanings),
       meaning = Value(meaning),
       exampleSentences = Value(exampleSentences),
       level = Value(level),
       wordType = Value(wordType),
       nextReview = Value(nextReview);
  static Insertable<VocabDbModel> custom({
    Expression<String>? id,
    Expression<String>? hanzi,
    Expression<String>? pinyin,
    Expression<String>? pinyinNormalized,
    Expression<String>? characters,
    Expression<String>? meanings,
    Expression<String>? meaning,
    Expression<String>? exampleSentences,
    Expression<int>? level,
    Expression<String>? wordType,
    Expression<bool>? isBookmarked,
    Expression<bool>? isMastered,
    Expression<int>? repetitions,
    Expression<double>? easeFactor,
    Expression<int>? interval,
    Expression<DateTime>? nextReview,
    Expression<bool>? needsSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hanzi != null) 'hanzi': hanzi,
      if (pinyin != null) 'pinyin': pinyin,
      if (pinyinNormalized != null) 'pinyin_normalized': pinyinNormalized,
      if (characters != null) 'characters': characters,
      if (meanings != null) 'meanings': meanings,
      if (meaning != null) 'meaning': meaning,
      if (exampleSentences != null) 'example_sentences': exampleSentences,
      if (level != null) 'level': level,
      if (wordType != null) 'word_type': wordType,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (isMastered != null) 'is_mastered': isMastered,
      if (repetitions != null) 'repetitions': repetitions,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (interval != null) 'interval': interval,
      if (nextReview != null) 'next_review': nextReview,
      if (needsSync != null) 'needs_sync': needsSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hanzi,
    Value<String>? pinyin,
    Value<String>? pinyinNormalized,
    Value<List<String>>? characters,
    Value<List<Meaning>>? meanings,
    Value<String>? meaning,
    Value<List<ExampleSentence>>? exampleSentences,
    Value<int>? level,
    Value<String>? wordType,
    Value<bool>? isBookmarked,
    Value<bool>? isMastered,
    Value<int>? repetitions,
    Value<double>? easeFactor,
    Value<int>? interval,
    Value<DateTime>? nextReview,
    Value<bool>? needsSync,
    Value<int>? rowid,
  }) {
    return VocabsTableCompanion(
      id: id ?? this.id,
      hanzi: hanzi ?? this.hanzi,
      pinyin: pinyin ?? this.pinyin,
      pinyinNormalized: pinyinNormalized ?? this.pinyinNormalized,
      characters: characters ?? this.characters,
      meanings: meanings ?? this.meanings,
      meaning: meaning ?? this.meaning,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      level: level ?? this.level,
      wordType: wordType ?? this.wordType,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isMastered: isMastered ?? this.isMastered,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReview: nextReview ?? this.nextReview,
      needsSync: needsSync ?? this.needsSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hanzi.present) {
      map['hanzi'] = Variable<String>(hanzi.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (pinyinNormalized.present) {
      map['pinyin_normalized'] = Variable<String>(pinyinNormalized.value);
    }
    if (characters.present) {
      map['characters'] = Variable<String>(
        $VocabsTableTable.$convertercharacters.toSql(characters.value),
      );
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(
        $VocabsTableTable.$convertermeanings.toSql(meanings.value),
      );
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (exampleSentences.present) {
      map['example_sentences'] = Variable<String>(
        $VocabsTableTable.$converterexampleSentences.toSql(
          exampleSentences.value,
        ),
      );
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (wordType.present) {
      map['word_type'] = Variable<String>(wordType.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (isMastered.present) {
      map['is_mastered'] = Variable<bool>(isMastered.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabsTableCompanion(')
          ..write('id: $id, ')
          ..write('hanzi: $hanzi, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinNormalized: $pinyinNormalized, ')
          ..write('characters: $characters, ')
          ..write('meanings: $meanings, ')
          ..write('meaning: $meaning, ')
          ..write('exampleSentences: $exampleSentences, ')
          ..write('level: $level, ')
          ..write('wordType: $wordType, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('isMastered: $isMastered, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('nextReview: $nextReview, ')
          ..write('needsSync: $needsSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharactersTableTable extends CharactersTable
    with TableInfo<$CharactersTableTable, CharacterDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> strokes =
      GeneratedColumn<String>(
        'strokes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($CharactersTableTable.$converterstrokes);
  static const VerificationMeta _hskLevelMeta = const VerificationMeta(
    'hskLevel',
  );
  @override
  late final GeneratedColumn<int> hskLevel = GeneratedColumn<int>(
    'hsk_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radicalMeta = const VerificationMeta(
    'radical',
  );
  @override
  late final GeneratedColumn<String> radical = GeneratedColumn<String>(
    'radical',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokeCountMeta = const VerificationMeta(
    'strokeCount',
  );
  @override
  late final GeneratedColumn<int> strokeCount = GeneratedColumn<int>(
    'stroke_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinNormalizedMeta = const VerificationMeta(
    'pinyinNormalized',
  );
  @override
  late final GeneratedColumn<String> pinyinNormalized = GeneratedColumn<String>(
    'pinyin_normalized',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionViMeta = const VerificationMeta(
    'definitionVi',
  );
  @override
  late final GeneratedColumn<String> definitionVi = GeneratedColumn<String>(
    'definition_vi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    char,
    strokes,
    hskLevel,
    radical,
    strokeCount,
    pinyin,
    pinyinNormalized,
    definition,
    definitionVi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    } else if (isInserting) {
      context.missing(_charMeta);
    }
    if (data.containsKey('hsk_level')) {
      context.handle(
        _hskLevelMeta,
        hskLevel.isAcceptableOrUnknown(data['hsk_level']!, _hskLevelMeta),
      );
    }
    if (data.containsKey('radical')) {
      context.handle(
        _radicalMeta,
        radical.isAcceptableOrUnknown(data['radical']!, _radicalMeta),
      );
    }
    if (data.containsKey('stroke_count')) {
      context.handle(
        _strokeCountMeta,
        strokeCount.isAcceptableOrUnknown(
          data['stroke_count']!,
          _strokeCountMeta,
        ),
      );
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    }
    if (data.containsKey('pinyin_normalized')) {
      context.handle(
        _pinyinNormalizedMeta,
        pinyinNormalized.isAcceptableOrUnknown(
          data['pinyin_normalized']!,
          _pinyinNormalizedMeta,
        ),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('definition_vi')) {
      context.handle(
        _definitionViMeta,
        definitionVi.isAcceptableOrUnknown(
          data['definition_vi']!,
          _definitionViMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {char};
  @override
  CharacterDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterDbModel(
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      )!,
      strokes: $CharactersTableTable.$converterstrokes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}strokes'],
        )!,
      ),
      hskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hsk_level'],
      ),
      radical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radical'],
      ),
      strokeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_count'],
      ),
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      ),
      pinyinNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_normalized'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      ),
      definitionVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_vi'],
      ),
    );
  }

  @override
  $CharactersTableTable createAlias(String alias) {
    return $CharactersTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterstrokes =
      const StringListConverter();
}

class CharacterDbModel extends DataClass
    implements Insertable<CharacterDbModel> {
  final String char;
  final List<String> strokes;
  final int? hskLevel;
  final String? radical;
  final int? strokeCount;
  final String? pinyin;
  final String? pinyinNormalized;
  final String? definition;
  final String? definitionVi;
  const CharacterDbModel({
    required this.char,
    required this.strokes,
    this.hskLevel,
    this.radical,
    this.strokeCount,
    this.pinyin,
    this.pinyinNormalized,
    this.definition,
    this.definitionVi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['char'] = Variable<String>(char);
    {
      map['strokes'] = Variable<String>(
        $CharactersTableTable.$converterstrokes.toSql(strokes),
      );
    }
    if (!nullToAbsent || hskLevel != null) {
      map['hsk_level'] = Variable<int>(hskLevel);
    }
    if (!nullToAbsent || radical != null) {
      map['radical'] = Variable<String>(radical);
    }
    if (!nullToAbsent || strokeCount != null) {
      map['stroke_count'] = Variable<int>(strokeCount);
    }
    if (!nullToAbsent || pinyin != null) {
      map['pinyin'] = Variable<String>(pinyin);
    }
    if (!nullToAbsent || pinyinNormalized != null) {
      map['pinyin_normalized'] = Variable<String>(pinyinNormalized);
    }
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || definitionVi != null) {
      map['definition_vi'] = Variable<String>(definitionVi);
    }
    return map;
  }

  CharactersTableCompanion toCompanion(bool nullToAbsent) {
    return CharactersTableCompanion(
      char: Value(char),
      strokes: Value(strokes),
      hskLevel: hskLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(hskLevel),
      radical: radical == null && nullToAbsent
          ? const Value.absent()
          : Value(radical),
      strokeCount: strokeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(strokeCount),
      pinyin: pinyin == null && nullToAbsent
          ? const Value.absent()
          : Value(pinyin),
      pinyinNormalized: pinyinNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(pinyinNormalized),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      definitionVi: definitionVi == null && nullToAbsent
          ? const Value.absent()
          : Value(definitionVi),
    );
  }

  factory CharacterDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterDbModel(
      char: serializer.fromJson<String>(json['char']),
      strokes: serializer.fromJson<List<String>>(json['strokes']),
      hskLevel: serializer.fromJson<int?>(json['hskLevel']),
      radical: serializer.fromJson<String?>(json['radical']),
      strokeCount: serializer.fromJson<int?>(json['strokeCount']),
      pinyin: serializer.fromJson<String?>(json['pinyin']),
      pinyinNormalized: serializer.fromJson<String?>(json['pinyinNormalized']),
      definition: serializer.fromJson<String?>(json['definition']),
      definitionVi: serializer.fromJson<String?>(json['definitionVi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'char': serializer.toJson<String>(char),
      'strokes': serializer.toJson<List<String>>(strokes),
      'hskLevel': serializer.toJson<int?>(hskLevel),
      'radical': serializer.toJson<String?>(radical),
      'strokeCount': serializer.toJson<int?>(strokeCount),
      'pinyin': serializer.toJson<String?>(pinyin),
      'pinyinNormalized': serializer.toJson<String?>(pinyinNormalized),
      'definition': serializer.toJson<String?>(definition),
      'definitionVi': serializer.toJson<String?>(definitionVi),
    };
  }

  CharacterDbModel copyWith({
    String? char,
    List<String>? strokes,
    Value<int?> hskLevel = const Value.absent(),
    Value<String?> radical = const Value.absent(),
    Value<int?> strokeCount = const Value.absent(),
    Value<String?> pinyin = const Value.absent(),
    Value<String?> pinyinNormalized = const Value.absent(),
    Value<String?> definition = const Value.absent(),
    Value<String?> definitionVi = const Value.absent(),
  }) => CharacterDbModel(
    char: char ?? this.char,
    strokes: strokes ?? this.strokes,
    hskLevel: hskLevel.present ? hskLevel.value : this.hskLevel,
    radical: radical.present ? radical.value : this.radical,
    strokeCount: strokeCount.present ? strokeCount.value : this.strokeCount,
    pinyin: pinyin.present ? pinyin.value : this.pinyin,
    pinyinNormalized: pinyinNormalized.present
        ? pinyinNormalized.value
        : this.pinyinNormalized,
    definition: definition.present ? definition.value : this.definition,
    definitionVi: definitionVi.present ? definitionVi.value : this.definitionVi,
  );
  CharacterDbModel copyWithCompanion(CharactersTableCompanion data) {
    return CharacterDbModel(
      char: data.char.present ? data.char.value : this.char,
      strokes: data.strokes.present ? data.strokes.value : this.strokes,
      hskLevel: data.hskLevel.present ? data.hskLevel.value : this.hskLevel,
      radical: data.radical.present ? data.radical.value : this.radical,
      strokeCount: data.strokeCount.present
          ? data.strokeCount.value
          : this.strokeCount,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      pinyinNormalized: data.pinyinNormalized.present
          ? data.pinyinNormalized.value
          : this.pinyinNormalized,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      definitionVi: data.definitionVi.present
          ? data.definitionVi.value
          : this.definitionVi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterDbModel(')
          ..write('char: $char, ')
          ..write('strokes: $strokes, ')
          ..write('hskLevel: $hskLevel, ')
          ..write('radical: $radical, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinNormalized: $pinyinNormalized, ')
          ..write('definition: $definition, ')
          ..write('definitionVi: $definitionVi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    char,
    strokes,
    hskLevel,
    radical,
    strokeCount,
    pinyin,
    pinyinNormalized,
    definition,
    definitionVi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterDbModel &&
          other.char == this.char &&
          other.strokes == this.strokes &&
          other.hskLevel == this.hskLevel &&
          other.radical == this.radical &&
          other.strokeCount == this.strokeCount &&
          other.pinyin == this.pinyin &&
          other.pinyinNormalized == this.pinyinNormalized &&
          other.definition == this.definition &&
          other.definitionVi == this.definitionVi);
}

class CharactersTableCompanion extends UpdateCompanion<CharacterDbModel> {
  final Value<String> char;
  final Value<List<String>> strokes;
  final Value<int?> hskLevel;
  final Value<String?> radical;
  final Value<int?> strokeCount;
  final Value<String?> pinyin;
  final Value<String?> pinyinNormalized;
  final Value<String?> definition;
  final Value<String?> definitionVi;
  final Value<int> rowid;
  const CharactersTableCompanion({
    this.char = const Value.absent(),
    this.strokes = const Value.absent(),
    this.hskLevel = const Value.absent(),
    this.radical = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.pinyinNormalized = const Value.absent(),
    this.definition = const Value.absent(),
    this.definitionVi = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersTableCompanion.insert({
    required String char,
    required List<String> strokes,
    this.hskLevel = const Value.absent(),
    this.radical = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.pinyinNormalized = const Value.absent(),
    this.definition = const Value.absent(),
    this.definitionVi = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : char = Value(char),
       strokes = Value(strokes);
  static Insertable<CharacterDbModel> custom({
    Expression<String>? char,
    Expression<String>? strokes,
    Expression<int>? hskLevel,
    Expression<String>? radical,
    Expression<int>? strokeCount,
    Expression<String>? pinyin,
    Expression<String>? pinyinNormalized,
    Expression<String>? definition,
    Expression<String>? definitionVi,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (char != null) 'char': char,
      if (strokes != null) 'strokes': strokes,
      if (hskLevel != null) 'hsk_level': hskLevel,
      if (radical != null) 'radical': radical,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (pinyin != null) 'pinyin': pinyin,
      if (pinyinNormalized != null) 'pinyin_normalized': pinyinNormalized,
      if (definition != null) 'definition': definition,
      if (definitionVi != null) 'definition_vi': definitionVi,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersTableCompanion copyWith({
    Value<String>? char,
    Value<List<String>>? strokes,
    Value<int?>? hskLevel,
    Value<String?>? radical,
    Value<int?>? strokeCount,
    Value<String?>? pinyin,
    Value<String?>? pinyinNormalized,
    Value<String?>? definition,
    Value<String?>? definitionVi,
    Value<int>? rowid,
  }) {
    return CharactersTableCompanion(
      char: char ?? this.char,
      strokes: strokes ?? this.strokes,
      hskLevel: hskLevel ?? this.hskLevel,
      radical: radical ?? this.radical,
      strokeCount: strokeCount ?? this.strokeCount,
      pinyin: pinyin ?? this.pinyin,
      pinyinNormalized: pinyinNormalized ?? this.pinyinNormalized,
      definition: definition ?? this.definition,
      definitionVi: definitionVi ?? this.definitionVi,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    if (strokes.present) {
      map['strokes'] = Variable<String>(
        $CharactersTableTable.$converterstrokes.toSql(strokes.value),
      );
    }
    if (hskLevel.present) {
      map['hsk_level'] = Variable<int>(hskLevel.value);
    }
    if (radical.present) {
      map['radical'] = Variable<String>(radical.value);
    }
    if (strokeCount.present) {
      map['stroke_count'] = Variable<int>(strokeCount.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (pinyinNormalized.present) {
      map['pinyin_normalized'] = Variable<String>(pinyinNormalized.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (definitionVi.present) {
      map['definition_vi'] = Variable<String>(definitionVi.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersTableCompanion(')
          ..write('char: $char, ')
          ..write('strokes: $strokes, ')
          ..write('hskLevel: $hskLevel, ')
          ..write('radical: $radical, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('pinyin: $pinyin, ')
          ..write('pinyinNormalized: $pinyinNormalized, ')
          ..write('definition: $definition, ')
          ..write('definitionVi: $definitionVi, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabsTableTable vocabsTable = $VocabsTableTable(this);
  late final $CharactersTableTable charactersTable = $CharactersTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabsTable,
    charactersTable,
  ];
}

typedef $$VocabsTableTableCreateCompanionBuilder =
    VocabsTableCompanion Function({
      required String id,
      required String hanzi,
      required String pinyin,
      required String pinyinNormalized,
      required List<String> characters,
      required List<Meaning> meanings,
      required String meaning,
      required List<ExampleSentence> exampleSentences,
      required int level,
      required String wordType,
      Value<bool> isBookmarked,
      Value<bool> isMastered,
      Value<int> repetitions,
      Value<double> easeFactor,
      Value<int> interval,
      required DateTime nextReview,
      Value<bool> needsSync,
      Value<int> rowid,
    });
typedef $$VocabsTableTableUpdateCompanionBuilder =
    VocabsTableCompanion Function({
      Value<String> id,
      Value<String> hanzi,
      Value<String> pinyin,
      Value<String> pinyinNormalized,
      Value<List<String>> characters,
      Value<List<Meaning>> meanings,
      Value<String> meaning,
      Value<List<ExampleSentence>> exampleSentences,
      Value<int> level,
      Value<String> wordType,
      Value<bool> isBookmarked,
      Value<bool> isMastered,
      Value<int> repetitions,
      Value<double> easeFactor,
      Value<int> interval,
      Value<DateTime> nextReview,
      Value<bool> needsSync,
      Value<int> rowid,
    });

class $$VocabsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VocabsTableTable> {
  $$VocabsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanzi => $composableBuilder(
    column: $table.hanzi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get characters => $composableBuilder(
    column: $table.characters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Meaning>, List<Meaning>, String>
  get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<ExampleSentence>,
    List<ExampleSentence>,
    String
  >
  get exampleSentences => $composableBuilder(
    column: $table.exampleSentences,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabsTableTable> {
  $$VocabsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanzi => $composableBuilder(
    column: $table.hanzi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characters => $composableBuilder(
    column: $table.characters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentences => $composableBuilder(
    column: $table.exampleSentences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabsTableTable> {
  $$VocabsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hanzi =>
      $composableBuilder(column: $table.hanzi, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get characters =>
      $composableBuilder(
        column: $table.characters,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<Meaning>, String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ExampleSentence>, String>
  get exampleSentences => $composableBuilder(
    column: $table.exampleSentences,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get wordType =>
      $composableBuilder(column: $table.wordType, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$VocabsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabsTableTable,
          VocabDbModel,
          $$VocabsTableTableFilterComposer,
          $$VocabsTableTableOrderingComposer,
          $$VocabsTableTableAnnotationComposer,
          $$VocabsTableTableCreateCompanionBuilder,
          $$VocabsTableTableUpdateCompanionBuilder,
          (
            VocabDbModel,
            BaseReferences<_$AppDatabase, $VocabsTableTable, VocabDbModel>,
          ),
          VocabDbModel,
          PrefetchHooks Function()
        > {
  $$VocabsTableTableTableManager(_$AppDatabase db, $VocabsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hanzi = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String> pinyinNormalized = const Value.absent(),
                Value<List<String>> characters = const Value.absent(),
                Value<List<Meaning>> meanings = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<List<ExampleSentence>> exampleSentences =
                    const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> wordType = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<DateTime> nextReview = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabsTableCompanion(
                id: id,
                hanzi: hanzi,
                pinyin: pinyin,
                pinyinNormalized: pinyinNormalized,
                characters: characters,
                meanings: meanings,
                meaning: meaning,
                exampleSentences: exampleSentences,
                level: level,
                wordType: wordType,
                isBookmarked: isBookmarked,
                isMastered: isMastered,
                repetitions: repetitions,
                easeFactor: easeFactor,
                interval: interval,
                nextReview: nextReview,
                needsSync: needsSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hanzi,
                required String pinyin,
                required String pinyinNormalized,
                required List<String> characters,
                required List<Meaning> meanings,
                required String meaning,
                required List<ExampleSentence> exampleSentences,
                required int level,
                required String wordType,
                Value<bool> isBookmarked = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> interval = const Value.absent(),
                required DateTime nextReview,
                Value<bool> needsSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabsTableCompanion.insert(
                id: id,
                hanzi: hanzi,
                pinyin: pinyin,
                pinyinNormalized: pinyinNormalized,
                characters: characters,
                meanings: meanings,
                meaning: meaning,
                exampleSentences: exampleSentences,
                level: level,
                wordType: wordType,
                isBookmarked: isBookmarked,
                isMastered: isMastered,
                repetitions: repetitions,
                easeFactor: easeFactor,
                interval: interval,
                nextReview: nextReview,
                needsSync: needsSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabsTableTable,
      VocabDbModel,
      $$VocabsTableTableFilterComposer,
      $$VocabsTableTableOrderingComposer,
      $$VocabsTableTableAnnotationComposer,
      $$VocabsTableTableCreateCompanionBuilder,
      $$VocabsTableTableUpdateCompanionBuilder,
      (
        VocabDbModel,
        BaseReferences<_$AppDatabase, $VocabsTableTable, VocabDbModel>,
      ),
      VocabDbModel,
      PrefetchHooks Function()
    >;
typedef $$CharactersTableTableCreateCompanionBuilder =
    CharactersTableCompanion Function({
      required String char,
      required List<String> strokes,
      Value<int?> hskLevel,
      Value<String?> radical,
      Value<int?> strokeCount,
      Value<String?> pinyin,
      Value<String?> pinyinNormalized,
      Value<String?> definition,
      Value<String?> definitionVi,
      Value<int> rowid,
    });
typedef $$CharactersTableTableUpdateCompanionBuilder =
    CharactersTableCompanion Function({
      Value<String> char,
      Value<List<String>> strokes,
      Value<int?> hskLevel,
      Value<String?> radical,
      Value<int?> strokeCount,
      Value<String?> pinyin,
      Value<String?> pinyinNormalized,
      Value<String?> definition,
      Value<String?> definitionVi,
      Value<int> rowid,
    });

class $$CharactersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTableTable> {
  $$CharactersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get strokes => $composableBuilder(
    column: $table.strokes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get hskLevel => $composableBuilder(
    column: $table.hskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionVi => $composableBuilder(
    column: $table.definitionVi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTableTable> {
  $$CharactersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strokes => $composableBuilder(
    column: $table.strokes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hskLevel => $composableBuilder(
    column: $table.hskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionVi => $composableBuilder(
    column: $table.definitionVi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTableTable> {
  $$CharactersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get char =>
      $composableBuilder(column: $table.char, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get strokes =>
      $composableBuilder(column: $table.strokes, builder: (column) => column);

  GeneratedColumn<int> get hskLevel =>
      $composableBuilder(column: $table.hskLevel, builder: (column) => column);

  GeneratedColumn<String> get radical =>
      $composableBuilder(column: $table.radical, builder: (column) => column);

  GeneratedColumn<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get pinyinNormalized => $composableBuilder(
    column: $table.pinyinNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definitionVi => $composableBuilder(
    column: $table.definitionVi,
    builder: (column) => column,
  );
}

class $$CharactersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTableTable,
          CharacterDbModel,
          $$CharactersTableTableFilterComposer,
          $$CharactersTableTableOrderingComposer,
          $$CharactersTableTableAnnotationComposer,
          $$CharactersTableTableCreateCompanionBuilder,
          $$CharactersTableTableUpdateCompanionBuilder,
          (
            CharacterDbModel,
            BaseReferences<
              _$AppDatabase,
              $CharactersTableTable,
              CharacterDbModel
            >,
          ),
          CharacterDbModel,
          PrefetchHooks Function()
        > {
  $$CharactersTableTableTableManager(
    _$AppDatabase db,
    $CharactersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> char = const Value.absent(),
                Value<List<String>> strokes = const Value.absent(),
                Value<int?> hskLevel = const Value.absent(),
                Value<String?> radical = const Value.absent(),
                Value<int?> strokeCount = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> pinyinNormalized = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> definitionVi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersTableCompanion(
                char: char,
                strokes: strokes,
                hskLevel: hskLevel,
                radical: radical,
                strokeCount: strokeCount,
                pinyin: pinyin,
                pinyinNormalized: pinyinNormalized,
                definition: definition,
                definitionVi: definitionVi,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String char,
                required List<String> strokes,
                Value<int?> hskLevel = const Value.absent(),
                Value<String?> radical = const Value.absent(),
                Value<int?> strokeCount = const Value.absent(),
                Value<String?> pinyin = const Value.absent(),
                Value<String?> pinyinNormalized = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> definitionVi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersTableCompanion.insert(
                char: char,
                strokes: strokes,
                hskLevel: hskLevel,
                radical: radical,
                strokeCount: strokeCount,
                pinyin: pinyin,
                pinyinNormalized: pinyinNormalized,
                definition: definition,
                definitionVi: definitionVi,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTableTable,
      CharacterDbModel,
      $$CharactersTableTableFilterComposer,
      $$CharactersTableTableOrderingComposer,
      $$CharactersTableTableAnnotationComposer,
      $$CharactersTableTableCreateCompanionBuilder,
      $$CharactersTableTableUpdateCompanionBuilder,
      (
        CharacterDbModel,
        BaseReferences<_$AppDatabase, $CharactersTableTable, CharacterDbModel>,
      ),
      CharacterDbModel,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabsTableTableTableManager get vocabsTable =>
      $$VocabsTableTableTableManager(_db, _db.vocabsTable);
  $$CharactersTableTableTableManager get charactersTable =>
      $$CharactersTableTableTableManager(_db, _db.charactersTable);
}
