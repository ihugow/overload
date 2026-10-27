import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';

class WorkoutSnapshot {
  const WorkoutSnapshot(this.session, this.sets, this.pendingOperations);
  final WorkoutSession? session;
  final List<WorkoutSet> sets;
  final int pendingOperations;
  bool get isActive => session != null && session!.endedAt == null;
}

class WorkoutRepository {
  WorkoutRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final AppDatabase db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  Stream<WorkoutSnapshot> watch() => db
      .customSelect(
        'SELECT COUNT(*) AS total FROM workout_sessions '
        'LEFT JOIN workout_sets ON workout_sets.session_id = workout_sessions.id',
        readsFrom: {db.workoutSessions, db.workoutSets, db.outboxEntries},
      )
      .watch()
      .asyncMap((_) => read());

  Future<WorkoutSnapshot> read() async {
    final query = db.select(db.workoutSessions)
      ..orderBy([
        (s) => OrderingTerm.desc(s.startedAt),
        (s) => OrderingTerm.desc(s.id),
      ])
      ..limit(1);
    final session = await query.getSingleOrNull();
    final sets = session == null
        ? <WorkoutSet>[]
        : await (db.select(db.workoutSets)
                ..where((s) => s.sessionId.equals(session.id))
                ..orderBy([
                  (s) => OrderingTerm.asc(s.completedAt),
                  (s) => OrderingTerm.asc(s.id),
                ]))
              .get();
    final pending = await db.select(db.outboxEntries).get();
    return WorkoutSnapshot(session, List.unmodifiable(sets), pending.length);
  }

  Future<void> _enqueue(
    String type,
    String id,
    Map<String, Object?> payload,
  ) async {
    await db
        .into(db.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            operationId: _uuid.v4(),
            entityId: id,
            entityType: type,
            payload: jsonEncode(payload),
            createdAt: _clock().toUtc(),
          ),
        );
  }

  Future<String> start() => db.transaction(() async {
    final active = await (db.select(
      db.workoutSessions,
    )..where((s) => s.endedAt.isNull())).getSingleOrNull();
    if (active != null) return active.id;
    final id = _uuid.v4();
    final now = _clock().toUtc();
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            name: 'Treino de teste — Push',
            startedAt: now,
          ),
        );
    await _enqueue('session', id, {
      'id': id,
      'name': 'Treino de teste — Push',
      'started_at': now.toIso8601String(),
    });
    return id;
  });

  Future<void> logSet({
    required String sessionId,
    required int weightGrams,
    required int reps,
  }) async {
    if (weightGrams < 0 || weightGrams > 1000000 || reps < 1 || reps > 1000) {
      throw ArgumentError(
        'Informe carga de 0 a 1.000 kg e 1 a 1.000 repetições.',
      );
    }
    await db.transaction(() async {
      final session = await (db.select(
        db.workoutSessions,
      )..where((s) => s.id.equals(sessionId))).getSingle();
      if (session.endedAt != null) {
        throw StateError('Este treino já foi finalizado.');
      }
      final id = _uuid.v4();
      final now = _clock().toUtc();
      final rest = now.add(const Duration(seconds: 90));
      await db
          .into(db.workoutSets)
          .insert(
            WorkoutSetsCompanion.insert(
              id: id,
              sessionId: sessionId,
              exerciseName: 'Supino reto com barra',
              weightGrams: weightGrams,
              reps: reps,
              completedAt: now,
            ),
          );
      await _enqueue('set', id, {
        'id': id,
        'session_id': sessionId,
        'exercise_name': 'Supino reto com barra',
        'weight_grams': weightGrams,
        'reps': reps,
        'completed_at': now.toIso8601String(),
      });
      await (db.update(db.workoutSessions)
            ..where((s) => s.id.equals(sessionId)))
          .write(WorkoutSessionsCompanion(restEndsAt: Value(rest)));
      await _enqueue('session', sessionId, {
        'id': sessionId,
        'rest_ends_at': rest.toIso8601String(),
      });
    });
  }

  Future<void> finish(String sessionId) => db.transaction(() async {
    final session = await (db.select(
      db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).getSingle();
    if (session.endedAt != null) return;
    final now = _clock().toUtc();
    await (db.update(
      db.workoutSessions,
    )..where((s) => s.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        endedAt: Value(now),
        restEndsAt: const Value(null),
      ),
    );
    await _enqueue('session', sessionId, {
      'id': sessionId,
      'ended_at': now.toIso8601String(),
      'rest_ends_at': null,
    });
  });
}

/// Parses kg without binary floating-point rounding. At most 3 decimal places.
int? parseWeightGrams(String input) {
  final match = RegExp(
    r'^(\d{1,4})(?:[.,](\d{1,3}))?$',
  ).firstMatch(input.trim());
  if (match == null) return null;
  final value =
      int.parse(match[1]!) * 1000 +
      int.parse((match[2] ?? '').padRight(3, '0'));
  return value <= 1000000 ? value : null;
}

String formatKg(int grams) => (grams / 1000)
    .toStringAsFixed(3)
    .replaceFirst(RegExp(r'\.?0+$'), '')
    .replaceAll('.', ',');
