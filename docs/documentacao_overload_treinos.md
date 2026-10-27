# Documentação de Especificação e Arquitetura do Sistema
## Overload — Aplicativo de Registro e Monitoramento de Treinos de Musculação

**Revisão:** 13/10/2026 — ampliação funcional e ajustes de arquitetura.
**Repositório previsto:** `/home/hugostoso/Dev/Projects/Personal/overload/`.
**Nome do produto:** Overload, conforme definido pelo autor do projeto.

---

## 1. Visão Geral do Projeto

O **Overload** é um aplicativo mobile desenvolvido em **Flutter** focado em praticantes de musculação que desejam controlar suas rotinas de treino, registrar cargas, repetições e evolução de forma consistente e consultar demonstrações em vídeo/animação da execução correta dos exercícios em tempo real.

O backend e a infraestrutura de dados utilizam o ecossistema **Supabase** (PostgreSQL, Supabase Auth, Row Level Security e Supabase Storage). Dado o cenário comum de perda de sinal de rede em academias, a arquitetura do cliente adota a abordagem **Offline-First**, utilizando um banco local embarcado (Isar/Drift) sincronizado bidirecionalmente com o Supabase.

### 1.1. Direção de Produto

A experiência central é registrar treinos com poucos toques, preservar cada registro e explicar a evolução usando comparações equivalentes. A interface prioriza o treino ativo, a confirmação rápida dos dados anteriores e a recuperação após interrupções.

O app deve reconhecer progresso além do aumento de carga, como mais repetições com o mesmo peso. Demonstrações ficam disponíveis sob demanda, com download dos vídeos da ficha para uso offline. Progressão automática e análises avançadas entram após validação do fluxo principal com pessoas treinando na academia.

---

## 2. Requisitos do Sistema

### 2.1. Requisitos Funcionais (RF)

| ID | Nome | Descrição | Prioridade |
| :--- | :--- | :--- | :--- |
| **RF01** | Catálogo Global de Exercícios | Catálogo com exercícios classificados por grupo muscular primário/secundário e equipamento. | Essencial |
| **RF02** | Exercícios Customizados | Criação e edição de exercícios com nome, grupos musculares, equipamento, modalidade de registro e notas. | Essencial |
| **RF03** | Demonstração sob Demanda | Player leve e mudo, aberto pelo usuário sem interromper áudio externo; opção de baixar os vídeos de uma ficha para acesso offline. | Alta |
| **RF04** | Montagem de Fichas (Rotinas) | Criação de divisões de treino (ex: Push, Pull, Legs; Treino A, B, C) com reordenação manual (*drag and drop*). | Essencial |
| **RF05** | Configuração de Séries Alvo | Definição de metas de séries, faixas de repetições (ex: 8-12 reps) e descanso padrão em segundos por exercício. | Essencial |
| **RF06** | Tipos Especiais de Séries | Identificação de séries de aquecimento (*warmup*), trabalho (*working set*), *feeder*, *drop-set* e *rest-pause*. Falha é um indicador independente, aplicável a diferentes tipos de série. | Alta |
| **RF07** | Execução de Treino Ativo | Interface de registro em tempo real para registrar as métricas aplicáveis ao exercício por série com checkbox de confirmação. | Essencial |
| **RF08** | Carga de Referência Anterior | Exibição em tempo real do histórico da última carga/reps registradas para o mesmo exercício antes da execução da série. | Essencial |
| **RF09** | Timer de Descanso Automático | Cronômetro de descanso disparado ao marcar uma série como concluída, com notificações sonoras/vibratórias. | Alta |
| **RF10** | Histórico e Gráficos de Evolução | Histórico básico no MVP; posteriormente, gráficos de carga, 1RM estimada em registros elegíveis, volume externo e consistência. Comparações respeitam exercício, equipamento e convenção de carga. | Alta |
| **RF11** | Indicador de Recorde Pessoal (PR) | Destaque visual e sonoro imediato quando o usuário supera a maior carga registrada para uma faixa de repetições. | Média |
| **RF12** | Calculadora de Anilhas | Utilitário para cálculo instantâneo das anilhas necessárias de cada lado da barra com base no peso total desejado. | Baixa |
| **RF13** | Registro de RPE / RIR | Preferência por RPE ou RIR, com campos distintos: RPE de 1 a 10 (passos de 0,5); RIR inteiro de 0 a 10. São escalas independentes, sem conversão automática ou limite universal de RIR em 4. | Média |
| **RF14** | Autenticação de Usuário | Login/Cadastro via Supabase Auth (Email/Senha, OAuth Google/Apple). | Essencial |
| **RF15** | Preenchimento com um Toque | Copiar carga, repetições e demais métricas elegíveis da série anterior; copiar não conclui a série. | Essencial |
| **RF16** | Recuperação Automática | Retomar sessão, séries, notas e descanso após fechamento, falha ou reinício do celular. | Essencial |
| **RF17** | Substituição Durante o Treino | Trocar exercício por alternativa cadastrada, escolhendo entre alterar só a sessão ou também a ficha. Históricos permanecem separados. | Alta |
| **RF18** | Equipamentos e Convenção de Carga | Identificar máquinas, salvar regulagens e definir peso total ou por halter; preservar essas informações na sessão. | Alta |
| **RF19** | Superséries e Circuitos | Agrupar exercícios, alternar séries e configurar descanso entre exercícios e entre voltas. | Alta |
| **RF20** | Importação e Exportação CSV | Importar histórico com prévia e mapeamento de colunas; exportar registros com unidades e contexto explícitos. | Alta |
| **RF21** | Backup Restaurável | Exportar e restaurar backup versionado das fichas, exercícios, equipamentos e histórico. | Alta |
| **RF22** | Comparação Contextual | Comparar sessões equivalentes e reconhecer repetições adicionais com carga igual, mostrando a base da comparação. | Alta |
| **RF23** | Progressão Configurável | Avaliar uma regra definida pelo usuário e sugerir alteração de meta, com explicação e confirmação explícita. | Segunda etapa |
| **RF24** | Modalidades de Registro | Suportar carga e repetições, repetições com peso corporal, carga adicional, assistência e duração. | Essencial |

---

### 2.2. Requisitos Não Funcionais (RNF)

* **RNF01 — Arquitetura Offline-First:** Toda operação de leitura e gravação de treinos e fichas deve ser executada primariamente no banco de dados local. A sincronização com o Supabase ocorre assincronamente com fila transacional persistente, operações idempotentes, controle de versão e exclusões lógicas. Conflitos não são resolvidos somente pelo relógio do celular; ver seção 5.
* **RNF02 — Performance e Taxa de Quadros:** A UI do Flutter deve manter consistentemente 60 a 120 FPS em transições e listas, sem janks causados pela renderização de múltiplos vídeos simultâneos. Os mini players devem utilizar cache agressivo de arquivos locais e reciclagem de instâncias de players.
* **RNF03 — Consumo Energético e Áudio Seguro:** O mini player deve reproduzir mídia estritamente muda (sem tracks de áudio) utilizando `AudioSession` configurada para não roubar o foco de áudio do sistema operacional, permitindo ao usuário ouvir músicas sem interrupções.
* **RNF04 — Otimização de Entrada Numérica:** Interfaces de digitação devem utilizar `FocusNode` sequencial automático (ir do peso diretamente para reps ao pressionar "Próximo") e botões rápidos de incremento (+1kg, +2kg, +5kg).
* **RNF05 — Segurança de Dados (RLS):** Toda tabela no Supabase PostgreSQL deve ter Row Level Security (RLS) estritamente ativado, com políticas testadas para isolar dados privados e impedir referências a registros privados de outro usuário. O catálogo global permite leitura autenticada e escrita apenas administrativa.

* **RNF06 — Persistência e Recuperação:** Alterações e fila de sincronização são gravadas na mesma transação local. Sessão e timer devem sobreviver ao encerramento do processo.
* **RNF07 — Observabilidade de Sync:** Mostrar estados salvo no dispositivo, sincronizando, sincronizado e erro com nova tentativa, sem bloquear o registro do treino.
* **RNF08 — Entrada e Acessibilidade:** Alvos de toque confortáveis, contraste adequado, leitor de tela e opção de desativar sons. Incrementos configuráveis por equipamento e unidade.
* **RNF09 — Portabilidade:** CSV documentado e backup com versão de formato; restauração validada antes de qualquer alteração persistente.

---

## 3. Modelagem do Banco de Dados (Supabase / PostgreSQL)

### 3.1. Diagrama Lógico / Estrutura Relacional

```text
auth.users
 ├─ profiles
 ├─ exercises (user_id NULL = catálogo global)
 ├─ equipment_profiles
 ├─ workout_templates
 │   ├─ template_groups
 │   └─ template_exercises
 └─ workout_sessions
     ├─ session_groups
     └─ session_exercises (snapshot da configuração usada no dia)
         └─ session_sets
```

Não existe uma tabela separada `user_exercises`: exercícios globais e personalizados compartilham `exercises`. Exercícios de sessão são instâncias, permitindo repetir o mesmo exercício em posições diferentes sem misturar séries.

As tabelas abaixo são a base relacional. Antes da primeira migração de produção, implementar também o contrato de sincronização, os snapshots e as validações de propriedade descritos nas seções 3.3 e 5.

### 3.2. DDL Base de Tabelas e Políticas

```sql
-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabela de Perfis de Usuário
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    avatar_url TEXT,
    preferred_unit TEXT DEFAULT 'kg' CHECK (preferred_unit IN ('kg', 'lbs')),
    effort_scale TEXT DEFAULT 'rir' CHECK (effort_scale IN ('rpe', 'rir')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabela de Exercícios (Catálogo Global + Customizados por Usuário)
CREATE TABLE public.exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL se for do catálogo padrão do app
    name TEXT NOT NULL,
    muscle_group TEXT NOT NULL, -- Peitoral, Dorsal, Quadríceps, etc.
    secondary_muscles TEXT[],
    equipment TEXT NOT NULL, -- Barra, Halter, Polia, Máquina, Peso Corporal
    tracking_mode TEXT NOT NULL DEFAULT 'load_reps'
        CHECK (tracking_mode IN ('load_reps', 'bodyweight_reps', 'added_load_reps', 'assisted_reps', 'duration')),
    media_url TEXT, -- URL no Supabase Storage para MP4/WebP
    thumbnail_url TEXT,
    instructions TEXT,
    is_custom BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Equipamentos pessoais: máquinas diferentes têm identidades diferentes.
CREATE TABLE public.equipment_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location_label TEXT,
    settings_notes TEXT,
    load_convention TEXT NOT NULL DEFAULT 'total' CHECK (load_convention IN ('total', 'per_implement')),
    implement_count INT NOT NULL DEFAULT 1 CHECK (implement_count > 0),
    increment_kg NUMERIC(6, 2) CHECK (increment_kg > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Fichas de Treino (Templates)
CREATE TABLE public.workout_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- Ex: "Treino A - Push / Peito e Tríceps"
    description TEXT,
    color_hex TEXT DEFAULT '#3B82F6',
    order_index INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.template_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES public.workout_templates(id) ON DELETE CASCADE,
    name TEXT,
    group_type TEXT NOT NULL CHECK (group_type IN ('superset', 'circuit')),
    rest_between_exercises_seconds INT NOT NULL DEFAULT 0 CHECK (rest_between_exercises_seconds >= 0),
    rest_between_rounds_seconds INT NOT NULL DEFAULT 90 CHECK (rest_between_rounds_seconds >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Exercícios vinculados à Ficha (Template)
CREATE TABLE public.template_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES public.workout_templates(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE RESTRICT,
    order_index INT NOT NULL,
    equipment_profile_id UUID REFERENCES public.equipment_profiles(id) ON DELETE SET NULL,
    group_id UUID REFERENCES public.template_groups(id) ON DELETE SET NULL,
    target_sets INT NOT NULL DEFAULT 3 CHECK (target_sets > 0),
    min_reps INT,
    max_reps INT,
    rest_time_seconds INT DEFAULT 90,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Sessão de Treino Concluída ou em Andamento
CREATE TABLE public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.workout_templates(id) ON DELETE SET NULL,
    name TEXT NOT NULL, -- Ex: "Treino A - Push"
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    rest_started_at TIMESTAMPTZ,
    rest_ends_at TIMESTAMPTZ,
    timezone_name TEXT NOT NULL DEFAULT 'UTC',
    total_volume_kg NUMERIC(12, 2), -- Cache derivado; NULL se indisponível.
    duration_seconds INT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.session_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    name TEXT,
    group_type TEXT NOT NULL CHECK (group_type IN ('superset', 'circuit')),
    rest_between_exercises_seconds INT NOT NULL CHECK (rest_between_exercises_seconds >= 0),
    rest_between_rounds_seconds INT NOT NULL CHECK (rest_between_rounds_seconds >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Instância do exercício no dia. O snapshot não muda ao editar a ficha.
CREATE TABLE public.session_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE RESTRICT,
    template_exercise_id UUID REFERENCES public.template_exercises(id) ON DELETE SET NULL,
    equipment_profile_id UUID REFERENCES public.equipment_profiles(id) ON DELETE SET NULL,
    group_id UUID REFERENCES public.session_groups(id) ON DELETE SET NULL,
    replaced_session_exercise_id UUID REFERENCES public.session_exercises(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'replaced', 'skipped')),
    order_index INT NOT NULL,
    exercise_name_snapshot TEXT NOT NULL,
    equipment_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    target_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    tracking_mode TEXT NOT NULL CHECK (tracking_mode IN ('load_reps', 'bodyweight_reps', 'added_load_reps', 'assisted_reps', 'duration')),
    load_convention TEXT NOT NULL DEFAULT 'total' CHECK (load_convention IN ('total', 'per_implement')),
    implement_count INT NOT NULL DEFAULT 1 CHECK (implement_count > 0),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Séries planejadas ou executadas na sessão.
CREATE TABLE public.session_sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_exercise_id UUID NOT NULL REFERENCES public.session_exercises(id) ON DELETE CASCADE,
    set_order INT NOT NULL CHECK (set_order >= 0),
    round_index INT CHECK (round_index >= 0),
    parent_set_id UUID REFERENCES public.session_sets(id) ON DELETE SET NULL,
    set_type TEXT NOT NULL DEFAULT 'working' CHECK (set_type IN ('warmup', 'feeder', 'working', 'dropset', 'restpause')),
    weight_kg NUMERIC(8, 3) CHECK (weight_kg >= 0),
    assistance_kg NUMERIC(8, 3) CHECK (assistance_kg >= 0),
    reps_completed INT CHECK (reps_completed >= 0),
    duration_seconds INT CHECK (duration_seconds >= 0),
    bodyweight_kg_snapshot NUMERIC(8, 3) CHECK (bodyweight_kg_snapshot > 0),
    rpe_score NUMERIC(3, 1) CHECK (rpe_score BETWEEN 1 AND 10 AND MOD(rpe_score, 0.5) = 0),
    rir_score INT CHECK (rir_score BETWEEN 0 AND 10),
    reached_failure BOOLEAN NOT NULL DEFAULT FALSE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    is_personal_record BOOLEAN NOT NULL DEFAULT FALSE, -- Cache recalculável.
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (rpe_score IS NULL OR rir_score IS NULL),
    CHECK (is_completed = (completed_at IS NOT NULL))
);

-- 3.3. Configuração de Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.template_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.template_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_exercises ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso
CREATE POLICY "Usuários acessam apenas seu próprio perfil"
    ON public.profiles FOR ALL USING (auth.uid() = id);

CREATE POLICY "Exercícios públicos ou criados pelo próprio usuário"
    ON public.exercises FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Inserção de exercícios próprios"
    ON public.exercises FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Atualização de exercícios próprios"
    ON public.exercises FOR UPDATE USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Equipamentos pertencem ao proprietário"
    ON public.equipment_profiles FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Grupos da ficha pertencem ao proprietário"
    ON public.template_groups FOR ALL USING (
        EXISTS (SELECT 1 FROM public.workout_templates t WHERE t.id = template_groups.template_id AND t.user_id = auth.uid())
    );

CREATE POLICY "Grupos da sessão pertencem ao proprietário"
    ON public.session_groups FOR ALL USING (
        EXISTS (SELECT 1 FROM public.workout_sessions s WHERE s.id = session_groups.session_id AND s.user_id = auth.uid())
    );

CREATE POLICY "Exercícios da sessão pertencem ao proprietário"
    ON public.session_exercises FOR ALL USING (
        EXISTS (SELECT 1 FROM public.workout_sessions s WHERE s.id = session_exercises.session_id AND s.user_id = auth.uid())
    );

CREATE POLICY "Templates pertencem ao proprietário"
    ON public.workout_templates FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Template exercises associados a templates do proprietário"
    ON public.template_exercises FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.workout_templates t
            WHERE t.id = template_exercises.template_id AND t.user_id = auth.uid()
        )
    );

CREATE POLICY "Sessões pertencem ao proprietário"
    ON public.workout_sessions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Séries pertencem a sessões do proprietário"
    ON public.session_sets FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.workout_sessions s
            JOIN public.session_exercises se ON se.session_id = s.id
            WHERE se.id = session_sets.session_exercise_id AND s.user_id = auth.uid()
        )
    );
```

### 3.3. Complementos Obrigatórios da Modelagem

O DDL acima não representa sozinho uma migração pronta para produção. A implementação deve incluir:

* `deleted_at TIMESTAMPTZ` e `revision BIGINT NOT NULL DEFAULT 1` em cada tabela sincronizada, além de `updated_at NOT NULL`. Atualizar `updated_at` e `revision` no servidor a cada mutação; `DEFAULT NOW()` sozinho não atualiza registros editados.
* Índices para proprietários, chaves estrangeiras e consultas de histórico. A ordenação entre itens ativos usa `order_index` e UUID como desempate durante conflitos de sincronização.
* Validar no servidor que equipamento pertence ao usuário; exercício é global ou do usuário; grupo pertence à mesma ficha/sessão; série pai pertence ao mesmo exercício da sessão; e referências de substituição pertencem à mesma sessão. Uma chave estrangeira isolada não verifica essas condições.
* Validar faixa de repetições (`min_reps <= max_reps`), descansos não negativos e métricas obrigatórias de uma série concluída de acordo com `tracking_mode`. Rascunhos podem ter valores ausentes. Assistência usa campo próprio, nunca carga negativa.
* Validar snapshots com esquema versionado: nome/configuração do equipamento, unidade de entrada, convenção de carga, metas de séries/repetições/duração e descanso. Não depender de JSON sem contrato.
* `is_custom` deve ser consistente com `user_id IS NOT NULL`; implementar constraint ou derivar a informação, evitando duas fontes de verdade.
* Escritas de produção passam por endpoint/RPC transacional com validação de proprietário, versão e idempotência. Restringir escrita direta para impedir contornar esse contrato; testar as permissões efetivas além de habilitar RLS. Credenciais administrativas nunca vão para o cliente.
* Exclusões normais são lógicas. Os `ON DELETE` do DDL tratam purga administrativa e remoção de conta, não substituem a propagação de exclusões para dispositivos offline.
* Volume e PR são derivados das séries elegíveis, recalculados após edição, exclusão, importação ou resolução de conflito. Não confiar nesses valores enviados pelo cliente.
* Regras de progressão, na segunda etapa, terão tabela própria com proprietário, exercício da ficha, escopo de equipamento, faixa de repetições, incremento, quantidade de sessões exigidas, versão e metadados de sync. Sugestões guardam a regra e os registros que as originaram.

---

## 4. Arquitetura do Aplicativo Flutter

### 4.1. Stack Tecnológica

* **Framework:** Flutter (versão 3.x+)
* **Gerenciamento de Estado:** `flutter_bloc` (Cubit / Bloc) ou `Riverpod`
* **Banco Local (Offline Cache):** `drift` (SQLite tipado e reativo) ou `isar`
* **Player de Mídia:** `video_player` com controle de foco de áudio nativo ou `cached_video_player_plus`
* **Cliente Backend:** `supabase_flutter`
* **Injeção de Dependências:** `get_it` + `injectable`

### 4.2. Estrutura de Pastas (Clean Architecture Simplificada)

```text
lib/
├── core/
│   ├── constants/          # Constantes de tema, endpoints e rotas
│   ├── database/           # Configuração do banco local (Drift/SQLite)
│   ├── network/            # Interceptors e sincronizador Supabase Sync Engine
│   └── utils/              # Calculadoras (PlateCalculator, 1RM, Timer)
├── features/
│   ├── auth/               # Login, Cadastro, Recuperação de Senha
│   ├── exercises/          # Catálogo, Busca, Mini Player, Vídeos
│   ├── workouts/           # Criação e Edição de Fichas (Templates)
│   ├── active_session/     # Treino em Andamento, Timer de Séries, Input de Carga
│   ├── analytics/          # Gráficos de Progressão, PRs, Calendário
├── shared/
│   ├── widgets/            # MiniVideoPlayer, PlateInput, RestTimerDialog
│   └── theme/              # Dark Theme otimizado para academias (OLED friendly)
└── main.dart
```

---

## 5. Estratégia de Offline-First e Sincronização

O banco local é a fonte de leitura da interface. Persistência offline e sincronização fazem parte da fundação, não de uma etapa final. Supabase é o backend remoto; uma fila e o monitor de conectividade, isoladamente, não completam o protocolo de sincronização.

### 5.1. Escrita Local e Fila

Na mesma transação local, gravar a alteração e sua operação pendente. Gerar UUIDs no dispositivo para identificar entidades mesmo offline. A fila deve conter ao menos:

```sql
CREATE TABLE sync_queue (
    operation_id TEXT PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('UPSERT', 'SOFT_DELETE')),
    base_revision INTEGER NOT NULL,
    payload_json TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    attempt_count INTEGER NOT NULL DEFAULT 0,
    next_attempt_at INTEGER,
    last_error TEXT
);
```

A fila e o banco são separados por conta. Nunca enviar alterações locais de um usuário após login de outro. No logout, alertar se há dados ainda não sincronizados antes de uma ação que os apagaria.

### 5.2. Envio e Repetição Segura

* Processar dependências antes dos filhos: ficha antes dos seus itens, sessão antes de exercícios e séries.
* Enviar `operation_id` e `base_revision` a um endpoint autenticado. A mesma operação reenviada deve retornar o resultado anterior sem duplicar dados; registrar deduplicação e mutação na mesma transação do servidor.
* Só remover a operação local após confirmação persistente do servidor. Se a resposta se perder, reenviar com o mesmo identificador.
* Usar tentativas com espera progressiva e variação aleatória; diferenciar falhas temporárias, autenticação expirada, validação e conflito.
* Conectividade indica possibilidade de rede, não disponibilidade da API. Tentar também ao abrir/retomar o app e por ação manual. Execução em background é uma otimização, não condição para preservar dados.

### 5.3. Recebimento e Exclusões

* Consumir um log de mudanças por usuário com cursor emitido pelo servidor e ordenação estável que não perca transações por ordem de commit. Não usar exclusivamente o maior `updated_at` observado no celular.
* O log inclui exclusões lógicas. Persistir mudanças recebidas e o cursor na mesma transação local, sem sobrescrever operações locais pendentes.
* Manter tombstones durante a janela de retenção definida. Dispositivos com cursor expirado fazem ressincronização completa, preservando e reconciliando sua fila antes de publicar alterações.

### 5.4. Conflitos

* Séries diferentes têm identidades próprias e não competem pelo mesmo registro.
* Se a mesma entidade foi alterada em dois dispositivos, comparar a revisão base. Preservar as duas versões e sinalizar conflito quando não houver combinação segura.
* Uma exclusão concorrente com edição não pode ressuscitar o registro silenciosamente; oferecer revisão/restauração explícita.
* Não usar `Last Write Wins` pelo relógio do dispositivo como política geral. Uma política mais simples pode ser adotada para preferências sem impacto no histórico, desde que documentada.
* A interface continua permitindo treinar enquanto conflitos anteriores aguardam resolução.

### 5.5. Recuperação de Sessão e Timer

Persistir status da sessão, exercício atual, séries, notas e `rest_ends_at`. Ao retomar o app, calcular o restante a partir do horário final; não depender de um contador em memória. Usar relógio monotônico durante a execução quando disponível e reconciliar mudanças do relógio ao retomar. Agendar aviso local quando permitido, com opção de som/vibração e atualização ao editar ou pular o descanso.

Uma sessão recuperada não deve confirmar séries automaticamente. Caso o descanso já tenha acabado, mostrar seu término sem iniciar outro timer.

---

## 6. Otimização do Mini Player de Execução

Para garantir fluidez e evitar travamentos na renderização da lista de exercícios:

1. **Formato de Mídia:** Arquivos `.mp4` comprimidos em H.264, resolução 480p ou 720p em 30 FPS, sem canal de áudio embutido (*strip audio track*), com tamanho médio de 500KB a 1.5MB por exercício.
2. **Armazenamento:** Supabase Storage (Bucket público `exercise-videos`).
3. **Cache de Mídia:** Utilização de caching local (ex: via `flutter_cache_manager`) para que o vídeo seja baixado uma única vez e executado a partir do disco local nas visualizações posteriores.
4. **Gerenciamento de Recursos:** Abrir demonstrações por ação do usuário e manter apenas um player ativo. Pausar ao sair da tela ou colocar o app em segundo plano; liberar controllers sem uso.
5. **Download de Ficha:** Permitir baixar todas as demonstrações de uma ficha, mostrando tamanho estimado, progresso, falhas e opção de remover downloads. Vídeos baixados explicitamente ficam fixados até remoção pelo usuário; o cache automático pode ser descartado.
6. **Atualização e Fallback:** Versionar mídia para invalidar cache; exibir thumbnail e instruções quando não houver vídeo disponível. O registro de séries nunca depende de baixar mídia.

---

## 7. Roadmap de Implementação

### Fase 1 — Fundação e Primeiro Fluxo Offline

* Definir as opções ainda abertas da stack, migrations, autenticação e isolamento por conta.
* Implementar banco local, fila transacional, protocolo mínimo de sync, revisões, tombstones e recuperação de sessão.
* Entregar um fluxo completo: iniciar treino, registrar série, fechar o app, reabrir e sincronizar sem duplicação.
* Testar duas contas, perda de rede e perda da resposta do servidor desde esta etapa.

### Fase 2 — MVP de Registro

* Catálogo enxuto, exercícios personalizados, criação/edição/reordenação de fichas.
* Modalidades de registro e convenções de carga explícitas, mesmo que a interface inicial seja simples.
* Treino ativo com dados anteriores, preenchimento com um toque, confirmação explícita, edição e timer persistente.
* Histórico básico, recuperação automática e indicadores de sync.
* Instruções e demonstrações sob demanda; não bloquear o lançamento por falta de vídeos de todo o catálogo.
* Validar o fluxo na academia antes de ampliar funcionalidades.

### Fase 3 — Flexibilidade e Portabilidade

* Substituições na sessão ou ficha, equipamentos com regulagens e identificação de máquinas.
* Superséries/circuitos com descanso por grupo.
* Comparação contextual com o treino anterior.
* CSV com prévia de importação e exportação; backup completo restaurável.
* Download dos vídeos da ficha e gestão de armazenamento.

### Fase 4 — Evolução e Análises

* Gráficos, PRs, consistência semanal e 1RM estimada somente em registros elegíveis.
* Regras de progressão configuradas pelo usuário, com sugestões explicadas e confirmação.
* Tipos avançados de séries e vínculos entre segmentos de drop-set/rest-pause.
* Calculadora de anilhas e demais utilitários após validação de demanda.

---

## 8. Regras de Experiência e Comparação

### 8.1. Preenchimento Rápido

Mostrar os dados anteriores como referência com data e origem. Um toque copia as métricas compatíveis para edição; outro comando explícito confirma a execução. Não copiar esforço percebido ou indicador de falha como se fossem resultados de hoje. Se não houver histórico equivalente, apresentar campos vazios e metas da ficha.

### 8.2. Substituição

Permitir escolher uma alternativa cadastrada pelo usuário. Perguntar no próprio fluxo se a troca vale só hoje ou também para a ficha. Preservar séries já feitas no exercício original, criar nova instância para o substituto e registrar o vínculo da troca. Não transferir cargas ou PRs entre exercícios automaticamente. A alteração na ficha não reescreve sessões anteriores.

### 8.3. Equipamento, Carga e Métricas

* Mostrar junto ao campo se o peso é total ou por implemento. Exemplo: dois halteres de 20 kg são registrados como 20 kg por halter, com quantidade 2; o contexto fica preservado na sessão.
* Guardar cargas em unidade canônica e converter para exibição em kg/lb, evitando arredondamento acumulado. Preservar a unidade de entrada no snapshot.
* Peso corporal pode usar somente repetições; carga adicional e assistência têm semânticas próprias; exercícios por duração não exigem repetições ou carga.
* Volume externo, quando aplicável, é a soma de repetições multiplicadas pela carga externa total. Para carga por implemento, considerar a quantidade conforme a convenção registrada. Repetições unilaterais precisam indicar se são por lado ou totais, sem duplicar contagem.
* Não atribuir zero de desempenho a métricas ausentes, nem somar duração e repetições em uma mesma medida de volume.
* Não comparar diretamente valores de máquinas diferentes ou interpretar assistência como carga levantada. Menor assistência pode representar evolução, mas não equivale a um PR de maior carga.
* Estimativas de 1RM devem mostrar fórmula, versão e critérios de elegibilidade adotados; não apresentar estimativas em modalidades incompatíveis.

### 8.4. Comparação Contextual

Comparar exercício, modalidade, equipamento, convenção de carga e tipos de série equivalentes. Usar séries de trabalho concluídas como padrão; separar aquecimento e técnicas avançadas. Mostrar quando a sessão anterior tiver mais/menos séries ou outra estrutura, evitando conclusões diretas de melhora/piora.

Exemplo elegível, com o mesmo equipamento e três séries de trabalho:

> Último treino: 30 kg — 10/9/8 repetições. Hoje: 30 kg — 10/10/9. Você fez 2 repetições a mais.

A comparação é descritiva, sem transformar um treino isolado em diagnóstico de progresso ou regressão. Mostrar explicitamente quando não houver base comparável.

### 8.5. Superséries e Circuitos

Um grupo define a sequência de exercícios, o descanso entre eles e o descanso ao completar uma volta. Registrar `round_index` nas séries. Ao concluir uma série, selecionar o próximo exercício do grupo; ao completar a volta, iniciar seu descanso. Permitir pular um exercício ou registrar quantidades diferentes de séries sem prender o usuário no fluxo.

### 8.6. Progressão Configurável — Segunda Etapa

O usuário define faixa de repetições, incremento e número de sessões equivalentes necessárias. Exemplo de regra configurada: “se todas as três séries de trabalho atingirem o limite superior em duas sessões equivalentes, sugerir o incremento definido”.

A sugestão informa qual regra foi cumprida e quais sessões foram consideradas. O usuário aceita, adia ou rejeita. Aceitar altera a meta futura e nunca o histórico. Não aumentar carga automaticamente nem apresentar a regra como prescrição individual. Mudanças de exercício, equipamento ou estrutura invalidam a comparação até existir base compatível.

---

## 9. Importação, Exportação e Backup

* **CSV:** Exportar dados normalizados com versão de formato, IDs, datas com fuso, exercícios, equipamento, convenção de carga, modalidade, métricas, tipos de série e esforço. Importar com mapeamento de colunas, unidades explícitas e prévia dos registros aceitos/rejeitados.
* **Duplicações:** Detectar reimportações por identificadores de origem e conteúdo; mostrar ambiguidades antes de gravar. Não mesclar registros ambíguos silenciosamente.
* **Backup:** Arquivo versionado com manifesto e dados de exercícios personalizados, equipamentos, fichas, grupos, sessões e séries. Não incluir tokens de acesso. Vídeos remotos podem ser baixados novamente; documentar que não fazem parte do backup inicial.
* **Restauração:** Validar formato, integridade e referências antes de gravar. Oferecer mesclagem com prévia; substituição integral exige confirmação explícita e backup do estado anterior. Aplicar a restauração atomicamente no banco local e gerar operações normais de sincronização.
* **Identidade:** Dados restaurados pertencem à conta autenticada de destino; remapear IDs e referências quando necessário. IDs de proprietário do arquivo não concedem acesso a outras contas.

---

## 10. Critérios de Aceite e Validação

1. **Registro rápido:** Copiar a série anterior não a conclui nem dispara descanso; confirmar grava a série e inicia o timer apropriado.
2. **Persistência:** Encerrar o processo após uma série confirmada e reabrir preserva os dados e recupera a sessão.
3. **Timer:** Retomar antes/depois do horário final apresenta o estado correto, sem duplicar notificações ou reiniciar o descanso.
4. **Offline:** Criar ficha, iniciar treino e concluir séries em modo avião; reconectar preserva IDs e resultados em outro dispositivo.
5. **Idempotência:** Simular resposta perdida e reenviar operações sem duplicar entidades.
6. **Conflitos e exclusões:** Editar a mesma série em dois dispositivos e excluir/editar offline preserva versões para decisão, sem perda silenciosa ou ressurreição automática.
7. **Isolamento:** Testar leitura, escrita e referências cruzadas entre duas contas, inclusive equipamentos, grupos, importação e restauração.
8. **Histórico:** Editar a ficha ou regulagens atuais não modifica os snapshots das sessões antigas.
9. **Substituição:** Trocar um exercício mantém suas séries executadas e não combina seu histórico com o substituto.
10. **Comparação:** Equipamentos ou convenções diferentes não geram comparação direta; o exemplo de 10/9/8 para 10/10/9 resulta em +2 repetições.
11. **Modalidades:** Exercícios por duração funcionam sem peso/repetições; peso corporal e assistência não produzem volume ou 1RM fictícios.
12. **Grupos:** Superséries/circuitos respeitam sequência, voltas, descansos e ações de pular.
13. **Portabilidade:** Exportar e restaurar um backup preserva relações e valores; arquivo inválido não altera dados; importar duas vezes não duplica silenciosamente.
14. **Mídia:** Demonstrar exercícios sem interromper música; vídeos baixados ficam acessíveis offline; falhas de mídia não impedem registrar séries.
15. **Progressão:** Uma regra só gera sugestão quando seus critérios são satisfeitos; nenhuma carga muda sem aceitação.

Na validação com usuários, observar tempo para iniciar um treino e registrar uma série, quantidade de correções, compreensão de peso por halter/total e confiança na recuperação offline. Definir metas quantitativas após obter a linha de base no protótipo.
