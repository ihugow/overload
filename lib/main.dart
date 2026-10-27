import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app/overload_app.dart';
import 'core/database/app_database.dart';
import 'features/active_workout/workout_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final db = AppDatabase.file(
      File(p.join(directory.path, 'overload_development.sqlite')),
    );
    final repository = WorkoutRepository(db);
    await repository.read();
    runApp(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const OverloadApp(),
      ),
    );
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível abrir os dados locais. Feche e reabra o app. Não apague os dados do aplicativo.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
