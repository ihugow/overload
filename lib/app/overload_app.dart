import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/active_workout/workout_repository.dart';

final repositoryProvider = Provider<WorkoutRepository>(
  (ref) => throw UnimplementedError('Configure o banco local.'),
);
final workoutProvider = StreamProvider<WorkoutSnapshot>(
  (ref) => ref.watch(repositoryProvider).watch(),
);

class OverloadApp extends StatelessWidget {
  const OverloadApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Overload',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0E0E12),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFCCFF00),
        brightness: Brightness.dark,
        primary: const Color(0xFFCCFF00),
        onPrimary: const Color(0xFF101010),
        surface: const Color(0xFF1F1F23),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      ),
    ),
    home: const WorkoutScreen(),
  );
}

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final weight = TextEditingController();
  final reps = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  String? error;
  Timer? ticker;
  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    weight.dispose();
    reps.dispose();
    super.dispose();
  }

  Future<void> perform(Future<void> Function() operation) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Não foi possível salvar. Seus registros anteriores foram preservados. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> finish(String id) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar treino?'),
        content: const Text(
          'As séries registradas serão mantidas no dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      await perform(() => ref.read(repositoryProvider).finish(id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'OVERLOAD',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: SafeArea(
      child: ref
          .watch(workoutProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível ler o treino.'),
                  TextButton(
                    onPressed: () => ref.invalidate(workoutProvider),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
            data: (snapshot) => ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'PRIMEIRO INCREMENTO · AMBIENTE LOCAL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFCEACEF),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  snapshot.isActive ? 'Treino em andamento' : 'Vamos treinar?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fluxo de teste: supino reto com barra. As séries ficam salvas neste dispositivo.',
                ),
                const SizedBox(height: 20),
                if (!snapshot.isActive)
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () => perform(() async {
                            await ref.read(repositoryProvider).start();
                            weight.clear();
                            reps.clear();
                          }),
                    child: const Text('INICIAR TREINO DE TESTE'),
                  ),
                if (snapshot.isActive) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supino reto com barra',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text('Carga total da barra + anilhas'),
                          const SizedBox(height: 20),
                          Form(
                            key: formKey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: weight,
                                    enabled: !busy,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Carga (kg)',
                                      hintText: 'Ex.: 30',
                                    ),
                                    validator: (v) =>
                                        parseWeightGrams(v ?? '') == null
                                        ? 'Use 0 a 1.000 kg'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: reps,
                                    enabled: !busy,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Repetições',
                                      hintText: 'Ex.: 10',
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse(v ?? '');
                                      return n == null || n < 1 || n > 1000
                                          ? 'Use 1 a 1.000'
                                          : null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (snapshot.sets.isNotEmpty)
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      weight.text = formatKg(
                                        snapshot.sets.last.weightGrams,
                                      );
                                      reps.text = snapshot.sets.last.reps
                                          .toString();
                                    },
                              child: const Text(
                                'Copiar última série deste treino',
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final grams = parseWeightGrams(
                                      weight.text,
                                    )!;
                                    final repetitions = int.parse(reps.text);
                                    perform(
                                      () => ref
                                          .read(repositoryProvider)
                                          .logSet(
                                            sessionId: snapshot.session!.id,
                                            weightGrams: grams,
                                            reps: repetitions,
                                          ),
                                    );
                                  },
                            child: Text(busy ? 'SALVANDO…' : 'CONFIRMAR SÉRIE'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _restLabel(snapshot),
                            key: const Key('rest_label'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => finish(snapshot.session!.id),
                    child: const Text('Finalizar treino'),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  snapshot.isActive ? 'Séries registradas' : 'Último treino',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (snapshot.sets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nenhuma série registrada ainda.'),
                  ),
                for (var i = 0; i < snapshot.sets.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(
                      '${formatKg(snapshot.sets[i].weightGrams)} kg × ${snapshot.sets[i].reps} reps',
                    ),
                    subtitle: Text(snapshot.sets[i].exerciseName),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                const Divider(height: 32),
                const Text(
                  'Salvo no dispositivo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${snapshot.pendingOperations} operações na fila local. Sincronização remota ainda não conectada.',
                ),
              ],
            ),
          ),
    ),
  );

  String _restLabel(WorkoutSnapshot snapshot) {
    final end = snapshot.session?.restEndsAt;
    if (end == null) return 'O descanso começa ao confirmar uma série.';
    final remaining = end.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 'Descanso concluído';
    return 'Descanso · ${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}';
  }
}
