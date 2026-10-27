import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overload/core/database/app_database.dart';
import 'package:overload/features/active_workout/workout_repository.dart';

void main() {
  test('carga decimal preserva gramas e rejeita entradas inválidas', () {
    expect(parseWeightGrams('32,125'), 32125);
    expect(parseWeightGrams('32.5'), 32500);
    expect(parseWeightGrams('-1'), isNull);
    expect(parseWeightGrams('3.1234'), isNull);
    expect(parseWeightGrams('1001'), isNull);
    expect(formatKg(0), '0');
    expect(formatKg(30000), '30');
  });

  test('reabrir banco preserva sessão, séries, timer e fila', () async {
    final dir = await Directory.systemTemp.createTemp('overload-test-');
    final file = File('${dir.path}/db.sqlite');
    final instant = DateTime.utc(2026, 10, 13, 20);
    var db = AppDatabase.file(file);
    var repo = WorkoutRepository(db, clock: () => instant);
    try {
      final id = await repo.start();
      expect(await repo.start(), id);
      expect((await repo.read()).pendingOperations, 1);
      await repo.logSet(sessionId: id, weightGrams: 32125, reps: 10);
      await db.close();
      db = AppDatabase.file(file);
      repo = WorkoutRepository(db, clock: () => instant);
      final recovered = await repo.read();
      expect(recovered.session!.id, id);
      expect(recovered.sets.single.weightGrams, 32125);
      expect(recovered.pendingOperations, 3);
      expect(
        recovered.session!.restEndsAt!.toUtc(),
        instant.add(const Duration(seconds: 90)),
      );
      await repo.finish(id);
      await repo.finish(id);
      expect((await repo.read()).pendingOperations, 4);
      expect((await repo.read()).isActive, false);
      await expectLater(
        repo.logSet(sessionId: id, weightGrams: 30000, reps: 10),
        throwsStateError,
      );
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('falha na fila reverte série e timer na mesma transação', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = WorkoutRepository(db);
    try {
      final id = await repo.start();
      await db.customStatement(
        "CREATE TRIGGER reject_outbox BEFORE INSERT ON outbox_entries BEGIN SELECT RAISE(ABORT, 'simulated storage failure'); END",
      );
      await expectLater(
        repo.logSet(sessionId: id, weightGrams: 30000, reps: 10),
        throwsA(anything),
      );
      final snapshot = await repo.read();
      expect(snapshot.sets, isEmpty);
      expect(snapshot.session!.restEndsAt, isNull);
      expect(snapshot.pendingOperations, 1);
    } finally {
      await db.close();
    }
  });

  test('entrada inválida não altera banco nem fila', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = WorkoutRepository(db);
    try {
      final id = await repo.start();
      await expectLater(
        repo.logSet(sessionId: id, weightGrams: -1, reps: 10),
        throwsArgumentError,
      );
      expect((await repo.read()).pendingOperations, 1);
      expect((await repo.read()).sets, isEmpty);
    } finally {
      await db.close();
    }
  });
}
