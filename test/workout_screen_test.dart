import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overload/app/overload_app.dart';
import 'package:overload/core/database/app_database.dart';
import 'package:overload/features/active_workout/workout_repository.dart';

void main() {
  testWidgets('confirmar salva; copiar preenche sem criar outra série', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = WorkoutRepository(db);
    addTearDown(db.close);
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const OverloadApp(),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('INICIAR TREINO DE TESTE'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '30,5');
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.tap(find.text('CONFIRMAR SÉRIE'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect((await repository.read()).sets, hasLength(1));
    await tester.tap(find.text('Copiar última série deste treino'));
    await tester.pump();
    expect((await repository.read()).sets, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
