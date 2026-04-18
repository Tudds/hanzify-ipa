import 'package:drift/drift.dart';
// Stub AppDatabase for web platform.
// Provides only the type so code-gen / providers can reference it.
// On web, appDatabaseProvider is never actually used — it's overridden
// in main.dart with VocabWebDataSourceImpl instead.

class AppDatabase {
  AppDatabase() {
    throw UnsupportedError(
      'AppDatabase (native drift) is not available on the web platform.',
    );
  }

  // Dummy members to satisfy analyzer for platform-agnostic code
  dynamic select(dynamic table) => throw UnimplementedError();
  dynamic selectOnly(dynamic table) => throw UnimplementedError();
  dynamic batch(Function(dynamic) action) => throw UnimplementedError();
  dynamic get vocabsTable => throw UnimplementedError();
  dynamic get charactersTable => throw UnimplementedError();
  dynamic get grammarPointsTable => throw UnimplementedError();
  dynamic get conversationsTable => throw UnimplementedError();
  dynamic get into => throw UnimplementedError();
  Future<void> forceSeed() => throw UnimplementedError();
}

class GrammarPointDbModel {
  String get id => '';
  String get title => '';
  String get structure => '';
  String get explanation => '';
  int get level => 1;
  String get category => '';
  dynamic get examples => null;
  dynamic get relatedGrammar => null;
  bool get isBookmarked => false;
  bool get isMastered => false;
  dynamic get formulaParts => null;
  dynamic get usages => null;
  dynamic get exampleTags => null;
}

class VocabDbModel {
  String get id => '';
  String get hanzi => '';
  String get pinyin => '';
  String get pinyinNormalized => '';
  dynamic get characters => null;
  dynamic get meanings => null;
  String get meaning => '';
  dynamic get exampleSentences => null;
  int get level => 1;
  String get wordType => '';
  bool get isBookmarked => false;
  bool get isMastered => false;
  int get repetitions => 0;
  double get easeFactor => 2.5;
  int get interval => 0;
  DateTime get nextReview => DateTime.fromMillisecondsSinceEpoch(0);
  bool get needsSync => false;
}

class CharacterDbModel {
  String get char => '';
  dynamic get strokes => null;
  int? get hskLevel => null;
  String? get radical => null;
  int? get strokeCount => null;
  String? get pinyin => null;
  String? get pinyinNormalized => null;
  String? get definition => null;
  String? get definitionVi => null;
}

class GrammarPointsTableCompanion {
  static dynamic insert({
    required dynamic id,
    required dynamic title,
    required dynamic structure,
    required dynamic explanation,
    required dynamic level,
    required dynamic category,
    dynamic examples,
    dynamic relatedGrammar,
    dynamic isBookmarked,
    dynamic isMastered,
    dynamic formulaParts,
    dynamic usages,
    dynamic exampleTags,
  }) => throw UnimplementedError();
}

class VocabsTableCompanion {
  static dynamic insert({
    required dynamic id,
    required dynamic hanzi,
    required dynamic pinyin,
    required dynamic pinyinNormalized,
    required dynamic characters,
    required dynamic meanings,
    required dynamic meaning,
    required dynamic exampleSentences,
    required dynamic level,
    required dynamic wordType,
    dynamic isBookmarked,
    dynamic isMastered,
    dynamic repetitions,
    dynamic easeFactor,
    dynamic interval,
    required dynamic nextReview,
    dynamic needsSync,
  }) => throw UnimplementedError();
}

class CharactersTableCompanion {
  static dynamic insert({
    required dynamic char,
    required dynamic strokes,
    dynamic hskLevel,
    dynamic radical,
    dynamic strokeCount,
    dynamic pinyin,
    dynamic pinyinNormalized,
    dynamic definition,
    dynamic definitionVi,
  }) => throw UnimplementedError();
}

class ConversationDbModel {
  String get id => '';
  String get title => '';
  String get titleZh => '';
  String get titlePinyin => '';
  String get description => '';
  int get level => 1;
  String get category => '';
  String get icon => '';
  dynamic get lines => null;
  dynamic get vocabulary => null;
  dynamic get speakers => null;
  dynamic get relatedGrammar => null;
  String get cultureTip => '';
  bool get isBookmarked => false;
  bool get isMastered => false;
}

class ConversationsTableCompanion {
  static dynamic insert({
    required dynamic id,
    required dynamic title,
    required dynamic titleZh,
    required dynamic titlePinyin,
    required dynamic description,
    required dynamic level,
    required dynamic category,
    required dynamic icon,
    required dynamic lines,
    required dynamic vocabulary,
    required dynamic speakers,
    required dynamic relatedGrammar,
    required dynamic cultureTip,
    dynamic isBookmarked,
    dynamic isMastered,
  }) => throw UnimplementedError();
}



class $VocabsTableTable extends Table {}
class $CharactersTableTable extends Table {}
class $GrammarPointsTableTable extends Table {}
class $ConversationsTableTable extends Table {}


