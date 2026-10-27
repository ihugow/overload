# Estado da implementação

Atualizado em 13/10/2026.

## Primeiro incremento — núcleo local

Implementados bootstrap Android/Flutter, composição Riverpod, banco Drift, sessão de desenvolvimento, confirmação de série, fila transacional, timer por horário persistido e finalização. IDs são UUIDs e cargas usam gramas inteiras.

A fila é uma outbox preliminar: ainda não possui consumidor, conta autenticada, revisão base, tombstones ou cursor remoto. Seu contrato será migrado na P2 antes de sincronizar dados reais. Não confundir gravação local atômica com sincronização idempotente já concluída.

## Etapas

- P0: parcialmente concluída. SDK Flutter pronto, dependências fixadas, Git inicializado e decisão registrada. Android cmdline-tools/licenças e identificador definitivo pendentes.
- P1: não concluída. Tema provisório do laboratório; home e fluxos finais ainda não implementados.
- P2: parte local implementada e coberta por testes. Auth, isolamento por conta, protocolo remoto e testes entre dispositivos pendentes.
- P3–P7: não iniciadas.

## Verificação

`flutter analyze`: sem problemas. `flutter test`: 5 testes aprovados (validação numérica, reabertura do banco, rollback atômico, rejeição de entrada inválida e copiar/confirmar na interface). Ainda sem build APK e teste em aparelho. O SDK local foi obtido do canal stable oficial, revisão `abaf9c5237`.

## Próximo incremento

1. Completar configuração Android e validar o ciclo de encerramento/retomada em aparelho ou emulador.
2. Configurar um ambiente Supabase de desenvolvimento explicitamente identificado.
3. Introduzir autenticação, bancos isolados por conta e protocolo transacional com idempotência/revisão/log remoto.
4. Testar reenvio após resposta perdida e conflitos entre dois dispositivos.
5. Substituir o exercício fixo por catálogo/fichas e evoluir a UI com o design aprovado.
