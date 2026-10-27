import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get restEndsAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseName => text()();
  IntColumn get weightGrams =>
      integer().customConstraint('NOT NULL CHECK (weight_grams >= 0)')();
  IntColumn get reps =>
      integer().customConstraint('NOT NULL CHECK (reps > 0)')();
  DateTimeColumn get completedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class OutboxEntries extends Table {
  TextColumn get operationId => text()();
  TextColumn get entityId => text()();
  TextColumn get entityType => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {operationId};
}

@DriftDatabase(tables: [WorkoutSessions, WorkoutSets, OutboxEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  factory AppDatabase.file(File file) => AppDatabase(NativeDatabase(file));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE UNIQUE INDEX one_active_session ON workout_sessions ((1)) WHERE ended_at IS NULL',
      );
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
