# Overload

App Flutter de registro de musculação com persistência local. Este repositório contém o primeiro incremento funcional do plano aprovado.

## Implementado

- Projeto Android e base Flutter + Riverpod + Drift.
- Iniciar ou recuperar uma sessão de teste.
- Registrar carga total e repetições do supino; copiar a última série sem concluí-la automaticamente.
- Persistir série, horário de descanso e operações pendentes em uma transação SQLite.
- Recuperar sessão após reabrir o banco e finalizar treino sem apagar séries.
- Testes de persistência, rollback, validação numérica e interação com a tela.

Esta tela é um laboratório funcional do núcleo local. Não é a home final do Figma. Usa um banco de desenvolvimento único, sem autenticação. Ainda não há sincronização com Supabase, catálogo/fichas completos, notificações em segundo plano ou edição de séries. O timer se recompõe pelo horário persistido, mas não agenda avisos locais nesta etapa. A fila permanece pendente até o próximo incremento.

## Ambiente

Versões utilizadas: Flutter **3.47.7**, Dart **3.13.5**. Dependências fixadas em `pubspec.yaml` e resolução em `pubspec.lock`.

O SDK usado nesta máquina está em `work/tooling/flutter`, fora do versionamento. Em outra máquina, instale a mesma versão e use `flutter` no PATH ou defina `OVERLOAD_FLUTTER_SDK` apontando para a pasta do SDK. O wrapper abaixo também detecta a instalação local do projeto.

```bash
./scripts/flutterw pub get
./scripts/flutterw pub run build_runner build
./scripts/flutterw analyze
./scripts/flutterw test
./scripts/flutterw devices
./scripts/flutterw run -d ID_DO_DISPOSITIVO
```

Android: identificador provisório `dev.overload.overload`, gerado pelo bootstrap. Definir o identificador definitivo antes de distribuição. O diagnóstico inicial encontrou Android SDK 36, mas ferramentas `cmdline-tools` ausentes e licenças sem verificação. Não há APK ou validação em aparelho nesta entrega.

## Teste manual esperado

1. Iniciar o treino de teste.
2. Informar `30,5` kg e `10` repetições; confirmar.
3. Conferir a série na lista e o descanso de 90 segundos.
4. Copiar a última série; conferir que a lista não cresce.
5. Encerrar e reabrir o app; conferir os dados e o horário de descanso.
6. Finalizar o treino; conferir que o último treino segue acessível.

Os testes automatizados comprovam reabertura do banco, não substituem o teste de encerramento do processo pelo sistema operacional em aparelho real.

## Documentação

- [Plano de implementação](docs/PLANO_IMPLEMENTACAO.md)
- [Especificação](docs/documentacao_overload_treinos.md)
- [Decisão de fundação](docs/decisions/0001-fundacao.md)
- [Estado da implementação](docs/STATUS.md)
- [Home aprovada](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=69-2)
