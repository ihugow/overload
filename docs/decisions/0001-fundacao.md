# 0001 — Fundação do primeiro incremento

Status: aceito no início da implementação do plano aprovado.

- Flutter e Dart; Android como primeiro alvo de aparelho.
- Riverpod para composição de dependências e estado.
- Drift/SQLite para persistência, com transação única para dado e outbox.
- Interface de repositório separada da interface gráfica.
- Neste incremento, um perfil local de desenvolvimento, sem apresentar login ou sincronização remota fictícios. Este perfil não é a conta convidada de produção: o uso real com dados pessoais depende da etapa de autenticação e isolamento por conta.
- Uma sessão ativa de teste, exercícios e séries com IDs estáveis; retomada após fechar processo.
- Outbox persistida, mas sem consumir operações antes da implementação do protocolo remoto.
- Valores de carga em gramas inteiras, exibidos em kg; evitar arredondamento binário em gravação.
- Supabase/Auth e aplicação remota idempotente constituem o próximo incremento. “Salvo no dispositivo” nunca deve ser apresentado como “sincronizado”.

A primeira tela funcional é um laboratório do fluxo de registro, não uma implementação completa da home do Figma. O design aprovado será integrado quando fichas e métricas reais estiverem disponíveis.
