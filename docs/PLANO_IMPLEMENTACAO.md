# Overload — Plano de implementação

Data: 13/10/2026. Status: plano inicial; implementação ainda não iniciada.

## 1. Objetivo e referências

Entregar um app mobile que permita montar uma ficha, registrar o treino com poucos toques, recuperar uma sessão interrompida e consultar evolução com dados confiáveis, inclusive quando a academia estiver sem internet.

- Especificação funcional: `../documentacao_overload_treinos.md`.
- [Home aprovada — frame 69:2](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=69-2).
- [Estados aprovados — frame 70:2](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=70-2).
- O frame original 48:4 é uma referência histórica, não a versão a implementar.

A aprovação visual cobre a home e os exemplos de estados. As demais telas ainda precisam ser desenhadas. Os números, nomes e horários dos frames são dados ilustrativos; não entram como resultados reais de usuários.

Este plano detalha o roadmap da especificação. Escolhas novas abaixo são propostas de implementação, não decisões previamente aprovadas pelo usuário.

## 2. Premissas e decisões propostas

| Tema | Proposta | Motivo / condição |
| --- | --- | --- |
| Plataforma inicial | Validar primeiro em Android; manter projeto Flutter compatível com iOS | Premissa ajustável. Distribuição iOS terá sua própria validação em macOS/Xcode e aparelho. |
| Idioma | Português do Brasil no primeiro lançamento | Textos extraídos para localização futura. |
| Framework | Flutter e Dart, canal estável | Verificar compatibilidade e fixar versão no início, sem adotar um número antigo apenas porque aparece na especificação. |
| Estado e dependências | Riverpod | Usar providers para composição; não adicionar também Bloc e get_it/injectable sem necessidade concreta. |
| Persistência | Drift sobre SQLite | Modelo relacional local, transações e migrações versionadas. |
| Backend | Supabase: PostgreSQL, Auth e Storage | Mantém a escolha da especificação. |
| Navegação | go_router, sujeito à validação de compatibilidade no bootstrap | Abas e rotas de detalhe, recuperação de sessão e retorno de autenticação. |
| Login | Email/senha e recuperação no beta inicial; OAuth depois | Primeiro login exige rede. Usuário já autenticado continua registrando localmente se a sessão remota expirar, com sync pendente até reautenticar. |
| Conta convidada | Fora do beta inicial | Evita acrescentar uma migração de identidade ao núcleo offline. |
| Sincronização | Contrato próprio mínimo com RPC transacional, fila local e log remoto | Provar correção antes de ampliar UI. Se o experimento falhar ou o custo for excessivo, registrar uma decisão comparando alternativas antes de prosseguir. |
| Arquitetura | Organização por funcionalidades; UI → controladores → repositórios → fontes de dados | Regras e persistência independentes dos widgets; evitar camadas sem responsabilidade real. |
| Unidade | kg como padrão, conversão explícita para lb | Armazenamento canônico com precisão definida e contexto por implemento/total. |

O uso de repositórios para coordenar dados locais e remotos está alinhado ao [guia offline do Flutter](https://docs.flutter.dev/app-architecture/design-patterns/offline-first). Drift oferece [transações](https://drift.simonbinder.eu/dart_api/transactions/) e [migrações](https://drift.simonbinder.eu/migrations/), úteis para gravar uma série e sua operação de sync atomicamente e preservar históricos entre versões. Providers podem compor dependências conforme a [documentação do Riverpod](https://riverpod.dev/docs/concepts2/containers).

## 3. Limites de cada entrega

### Primeiro incremento executável

Um usuário de teste abre uma sessão com exercício de exemplo, registra uma série, fecha o app, reabre com a sessão preservada e sincroniza sem duplicação. A interface pode ser mínima, mas utiliza o mesmo caminho de persistência previsto para o produto.

### Beta de uso real

- Cadastro/login/recuperação, preferências e isolamento por conta.
- Catálogo inicial revisado, busca/filtros e exercícios personalizados.
- Fichas com ordem, metas, descanso e convenção de carga.
- Treino ativo com referência anterior, preenchimento rápido, confirmação, correção de série e recuperação automática.
- Modalidades de carga/repetições, peso corporal, carga adicional, assistência e duração.
- Aquecimento e trabalho; esforço RPE ou RIR opcional.
- Timer persistente, avisos locais quando autorizados e funcionamento com tela bloqueada validado no aparelho.
- Histórico, resumo de sessão e comparação básica entre registros equivalentes.
- Home aprovada com dados reais: iniciar/continuar, trocar ficha, consistência semanal, volume, séries e PR básico.
- Sync com repetição segura, exclusões, conflitos e indicação visível de pendências.
- Backup exportável e restaurável antes de depender do app como único registro de treino.
- Instruções por exercício e player sob demanda para o subconjunto com mídia disponível.

Antecipamos consistência, PR básico e comparação simples para sustentar a home aprovada. Gráficos avançados continuam posteriores. Backup também é antecipado em relação ao roadmap geral, para apoiar uso real e migrações.

### Depois do beta

Substituições com atualização opcional da ficha, gestão completa de equipamentos/regulagens, superséries/circuitos, importação/exportação CSV, downloads de vídeos por ficha, gráficos, progressão por regras, feeder/drop-set/rest-pause, calculadora de anilhas e login social. Todas as funções permanecem no roadmap; não precisam chegar juntas ao primeiro beta.

## 4. Etapas, dependências e critérios de saída

| Etapa | Entrega | Depende de | Critério para avançar |
| --- | --- | --- | --- |
| P0 — Preparação | Ambiente verificado, decisões técnicas registradas e contratos iniciais | — | Ferramentas disponíveis, plataforma piloto definida e risco de sincronização delimitado. |
| P1 — Base visual e fluxos | Tokens, navegação, componentes e desenho das telas essenciais | P0 | Caminho de criar ficha → treinar → finalizar → consultar histórico compreensível no protótipo. |
| P2 — Primeiro ciclo confiável | Persistência local, Auth e sync mínimo com recuperação | P0; tema mínimo de P1 | Série sobrevive a encerramento; reenvio não duplica; dados não vazam entre duas contas. |
| P3 — Catálogo e fichas | CRUD, metas e início de sessão por snapshot | P1–P2 | Criar e editar ficha offline funciona; sessão passada não muda ao editar a ficha. |
| P4 — Treino ativo | Registro completo, histórico anterior, timer e retomada | P3 | Um treino completo pode ser realizado em modo avião e retomado após reinício. |
| P5 — Histórico e home | Resumos, métricas e home aprovada com dados reais | P4 | Dados da home batem com séries elegíveis e estados não mostram valores fictícios. |
| P6 — Beta | Backup, mídia inicial, hardening e distribuição de teste | P5 | Cenários críticos passam em aparelho e problemas bloqueadores estão resolvidos. |
| P7 — Expansão | Funcionalidades posteriores em incrementos pequenos | P6 | Cada incremento atende seu aceite sem regressão no registro e no sync. |

P1 e a investigação técnica de P2 podem avançar em paralelo como frentes de trabalho; não dependem de terminar todas as telas antes de validar persistência. Isso não implica criação automática de agentes ou chats.

### P0 — Preparação e decisões

- [ ] Conferir Flutter/Dart, Android SDK, emulador/aparelho, Java e ferramentas para Supabase local.
- [ ] Definir identificador do app, ambientes de desenvolvimento/teste/produção e organização do repositório.
- [ ] Verificar estado de Git e preparar controle de versão sem sobrescrever conteúdo existente.
- [ ] Registrar decisões sobre estado, banco, login e protocolo de sync em documentos curtos.
- [ ] Fixar dependências compatíveis após um build mínimo; guardar lockfile do aplicativo.
- [ ] Transformar o DDL conceitual em contrato revisado antes de usá-lo como migração.

### P1 — Experiência e componentes

- [ ] Extrair do Figma cores, fontes, espaçamentos e estados; usar Montserrat, Space Grotesk e Manrope conforme a referência, validando arquivos/licenças de distribuição.
- [ ] Implementar tema escuro e componentes: botão, card de treino, campo de carga/reps, linha de série, timer, estado vazio e estado de sync.
- [ ] Projetar fichas/lista/editor, catálogo/detalhe, treino ativo, finalização, histórico/detalhe, perfil e autenticação.
- [ ] Navegação: Início, Fichas, Histórico e Perfil; catálogo acessível ao editar ficha e selecionar exercício.
- [ ] Projetar confirmação ao abandonar treino, conflito de sync e erros recuperáveis.
- [ ] Conferir layout em telas pequenas, teclado aberto, fonte ampliada e áreas seguras; navegação inferior fixa no viewport, conteúdo rolável.

A home aprovada mede cerca de 390 × 1068 no canvas; é conteúdo rolável, não uma altura fixa obrigatória de dispositivo. Manter o CTA visível cedo e evitar reintroduzir os blocos de ferramentas removidos.

### P2 — Dados, backend e sincronização

- [ ] Schema local com migrações e banco isolado por conta.
- [ ] Migrations remotas para perfis, exercícios, equipamentos, fichas, sessões e séries; grupos entram quando necessários, com evolução compatível.
- [ ] UUIDs locais, revisão remota, exclusão lógica, fila e registro de operações aplicadas.
- [ ] Contrato explícito de snapshots: metas, equipamento, convenção, unidade e versão do formato.
- [ ] Validar propriedade de todas as referências, constraints e RLS; restringir formas de escrita que contornem o protocolo.
- [ ] Mutation RPC: validar sessão/usuário → detectar operação repetida → verificar revisão → aplicar alteração e log na mesma transação.
- [ ] Definir cursor de leitura sem lacunas por ordem de commit. Um contador sequencial isolado não prova essa garantia; testar concorrência e paginação.
- [ ] Separar o recebimento do catálogo global das mudanças privadas por usuário.
- [ ] Preservar operações locais pendentes ao receber dados remotos; rebasear operações sucessivas da mesma entidade após confirmação de revisão.
- [ ] Determinar retenção de deduplicação/tombstones e protocolo de ressincronização para dispositivos antigos, sem perder a fila.
- [ ] Fluxos de conflito, reautenticação, erro temporário, retry e troca de conta.
- [ ] Resolver sessões simultâneas criadas offline em dois dispositivos sem descartar uma delas silenciosamente.

Teste de viabilidade obrigatório: criar/editar/excluir offline, reconectar, perder a resposta do servidor, reenviar e comparar dois dispositivos. Não ampliar o escopo enquanto esse ciclo perder ou duplicar dados.

### P3 — Catálogo e fichas

- [ ] Catálogo inicial pequeno, suficiente para as fichas piloto; nomes e instruções revisados, mídia com origem e autorização documentadas.
- [ ] Busca por nome, grupo muscular e equipamento; criação/edição de exercício próprio.
- [ ] Criar, duplicar, reordenar e arquivar fichas; configurar séries, reps, descanso e notas.
- [ ] Convenção total/por implemento, quantidade e identificação mínima de equipamento desde o início.
- [ ] Modalidades e metas válidas por exercício; evitar campos obrigatórios sem sentido para duração/peso corporal.
- [ ] Ao iniciar, criar snapshot persistente da ficha; retomadas reutilizam a sessão existente.

### P4 — Execução de treino

- [ ] Registro com teclado numérico, próxima entrada e incrementos configuráveis.
- [ ] Histórico equivalente por série; copiar dados sem copiar esforço/falha nem marcar execução.
- [ ] Confirmar, desfazer confirmação, editar, adicionar e remover série sem perder operações.
- [ ] Timer com horário final persistido, ajustes e pular; reconciliar notificação com alterações e encerramento do treino.
- [ ] RPE/RIR opcional; aquecimento/trabalho e flag de falha separados.
- [ ] Retomar exercício atual, rascunhos e dados confirmados após interrupção.
- [ ] Finalizar com resumo e notas; abandonar com confirmação. Não marcar séries pendentes como executadas.

### P5 — Histórico e home

- [ ] Histórico por data e detalhe editável; recalcular derivados após alterações.
- [ ] Comparação contextual de carga/reps, sem misturar máquinas ou modalidades incompatíveis.
- [ ] Home alterna entre primeiro uso, treino sugerido e sessão ativa; “Trocar treino” escolhe outra ficha.
- [ ] Sugestão inicial de treino: seguir ordem das fichas a partir da última concluída, permitindo escolha manual; não presumir uma agenda diária inexistente.
- [ ] Meta semanal configurada pelo usuário; semana e contagem seguem regra de fuso documentada.
- [ ] Volume externo e séries de trabalho com período explícito; barra somente para meta existente.
- [ ] PR básico por exercício/equipamento/convenção e número de repetições; reclassificar após edição, importação ou exclusão.
- [ ] Estimativa Epley apenas em registros elegíveis, identificada como estimativa e com critérios documentados.
- [ ] Ícones de nuvem e sino devem ter destinos úteis. Sino só permanece se houver central de avisos implementada; não entregar controle sem ação.

### P6 — Qualidade e beta

- [ ] Backup versionado, validação antes da restauração e teste de ida/volta.
- [ ] Player sob demanda, fallback textual e cache; validar reprodução junto com música externa.
- [ ] Testar migração de uma instalação anterior com histórico e fila pendente.
- [ ] Validar aparelho Android de referência: entrada rápida, listas, teclado, bateria, retomada e avisos com tela bloqueada.
- [ ] Medir fluidez em modo profile; definir orçamento compatível com aparelho, evitando prometer 120 FPS em qualquer hardware.
- [ ] Revisar acessibilidade, mensagens de erro e estados sem dados.
- [ ] Preparar build de teste, instruções de instalação, registro de problemas e plano de recuperação.
- [ ] Validar em treinos reais com pequeno grupo, observando quantidade de toques, correções e confiança nos dados.

Publicação pública, infraestrutura paga e distribuição em lojas são marcos próprios; este plano não inicia essas ações. Antes de publicar, preparar suporte, exclusão de conta/dados, política de privacidade e conferir requisitos atuais da plataforma escolhida.

### P7 — Ordem sugerida de expansão

1. Substituições e cadastro completo de equipamentos/regulagens.
2. Superséries/circuitos e seus timers.
3. CSV e gerenciamento de vídeos offline.
4. Gráficos e filtros avançados.
5. Progressão configurável com confirmação.
6. Técnicas avançadas, calculadora de anilhas, OAuth e validação/distribuição iOS.

A prioridade pode mudar conforme uso observado no beta. Identidade de equipamento e snapshots já existem no núcleo; esta fase amplia a interface de gestão.

## 5. Rastreabilidade dos requisitos

| Requisitos | Entrega planejada |
| --- | --- |
| RF01, RF02, RF04, RF05 | P3 |
| RF03 | Player e instruções P6; download da ficha P7 |
| RF06 | Aquecimento/trabalho/falha P4; técnicas avançadas P7 |
| RF07, RF08, RF09, RF13, RF15, RF16, RF24 | P2 valida persistência; P4 entrega fluxo completo |
| RF10, RF11, RF22 | Histórico, PR e comparação básica P5; gráficos P7 |
| RF12 | P7 |
| RF14 | P2 email/senha; OAuth P7 |
| RF17, RF19, RF20, RF23 | P7 |
| RF18 | Semântica e identidade mínima P3; gestão completa P7 |
| RF21 | P6 |
| RNF01, RNF05, RNF06, RNF07 | P2 e regressão nas etapas seguintes |
| RNF02, RNF03, RNF04, RNF08, RNF09 | Implementação nas respectivas features; validação integrada P6 |

## 6. Estrutura proposta do repositório

```text
lib/
  app/                  # Inicialização, rotas e composição de dependências
  core/
    database/           # Drift e migrações locais
    sync/               # Fila, protocolo, conflitos e cursor
    errors/             # Erros de domínio e mensagens recuperáveis
  design_system/        # Tokens e componentes Flutter reutilizáveis
  features/
    auth/
    home/
    exercises/
    equipment/
    workout_templates/
    active_workout/
    history/
    analytics/
    profile/
    portability/
    progression/
supabase/
  migrations/
  tests/
  seed.sql
test/
integration_test/
assets/
docs/
  PLANO_IMPLEMENTACAO.md
  decisions/
```

Criar módulos quando sua etapa começar. Nas funcionalidades, separar apresentação, regras e dados quando isso esclarecer responsabilidades. Repositórios não devem buscar rede a cada renderização: a interface observa o estado local.

## 7. Verificação e definição de concluído

- Unidade: conversão de carga, volume, comparação, PR, transições de sessão e regras do timer.
- Banco: constraints, transação série+fila, migrações e snapshot histórico.
- Backend: permissões reais, referências cruzadas, idempotência, revisão, paginação e log concorrente.
- Widget: copiar vs. confirmar, teclado, validação por modalidade e estados da home.
- Integração/aparelho: login → ficha → treino offline → encerramento → retomada → sincronização → histórico.
- Portabilidade: restauração íntegra e falha sem alteração quando arquivo inválido.

Cada entrega precisa compilar, passar análise estática e os testes relevantes ao risco alterado, ter estados de vazio/erro/offline quando aplicáveis, e ser verificável no aparelho ou protótipo adequado. Acrescentar testes para comportamento crítico, não apenas para repetir o código.

Condições que bloqueiam o beta: perda/duplicação de séries, vazamento entre contas, migração que apaga histórico, timer/retomada que altera execução e métricas incompatíveis apresentadas como equivalentes.

## 8. Dependências externas e riscos

| Item | Tratamento | Momento |
| --- | --- | --- |
| Plataforma/dispositivo piloto | Android é premissa; escolher aparelho e ajustar prioridade se necessário | P0 |
| Projeto Supabase e credenciais de desenvolvimento | Usar ambiente isolado; nunca colocar segredo administrativo no app | P2 |
| Sincronização bidirecional | Experimento com falhas e concorrência antes de expansão | P2 |
| Vídeos e catálogo | Começar com conteúdo autorizado e suficiente para testes; fallback textual | P3/P6 |
| Login social e iOS | Credenciais e ambiente específico antes de distribuir nessas plataformas | P7 |
| Expectativa de prazo | Estimar após bootstrap e experimento de sync, com base em esforço observado | Fim de P2 |

Não há prazo fechado neste plano: disponibilidade de trabalho, dispositivos e resultados da sincronização ainda não foram validados. O acompanhamento será por entregas demonstráveis, com status e bloqueios atualizados a cada etapa.

## 9. Próxima sequência de execução

1. Verificar ferramentas e estabelecer o bootstrap Flutter.
2. Registrar Riverpod + Drift e contrato mínimo de dados/sync como decisões propostas de base.
3. Criar tema e navegação de teste a partir da home aprovada.
4. Implementar sessão e série locais com recuperação após encerramento.
5. Adicionar autenticação e sincronização mínima; provar os cenários de falha.
6. Desenvolver o fluxo de fichas e treino ativo sobre essa base.

O objetivo da primeira demonstração é mostrar uma série registrada que sobrevive ao fechamento do app e chega ao servidor uma única vez. A home completa vem quando houver dados reais para alimentá-la.
