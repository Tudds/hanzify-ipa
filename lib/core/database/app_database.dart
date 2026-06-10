import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('SrsCardDbModel')
class SrsCardsTable extends Table {
  TextColumn get id => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get cardType => text()();
  TextColumn get state => text()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  RealColumn get stability => real().nullable()();
  RealColumn get difficulty => real().nullable()();
  IntColumn get elapsedDays => integer().withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get syncPending => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SrsReviewLogDbModel')
class SrsReviewLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text().references(SrsCardsTable, #id)();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt => dateTime()();
  TextColumn get algorithm => text()();
  TextColumn get clientReviewId => text().nullable().unique()();
  RealColumn get stabilityBefore => real().nullable()();
  RealColumn get difficultyBefore => real().nullable()();
  RealColumn get stabilityAfter => real().nullable()();
  RealColumn get difficultyAfter => real().nullable()();
}

@DataClassName('LearningUnitProgressDbModel')
class LearningUnitProgressTable extends Table {
  TextColumn get unitId => text()();
  TextColumn get unitKind => text()();
  TextColumn get stageId => text()();
  TextColumn get moduleId => text()();
  TextColumn get status => text()();
  IntColumn get score => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get syncPending => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {unitId};
}

@DriftDatabase(
  tables: [SrsCardsTable, SrsReviewLogsTable, LearningUnitProgressTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(srsCardsTable, srsCardsTable.updatedAt);
        await migrator.addColumn(srsCardsTable, srsCardsTable.syncPending);
        await migrator.addColumn(
          srsReviewLogsTable,
          srsReviewLogsTable.clientReviewId,
        );
        await migrator.addColumn(
          learningUnitProgressTable,
          learningUnitProgressTable.updatedAt,
        );
        await migrator.addColumn(
          learningUnitProgressTable,
          learningUnitProgressTable.syncPending,
        );
      }
    },
  );
}
