# Overload — Design system e telas

Atualizado em 16/10/2026.

## Referências no Figma

- [Home revisada aprovada](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=69-2).
- [Fundamentos e componentes criados](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=80-173).
- Página `01 · Overload — Design system` (`79:2`).
- Página `02 · Overload — Telas e estados` (`79:3`), com 14 telas principais e 7 estados de apoio.
- [Fichas](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=91-28).
- [Treino ativo](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=91-222).
- [Entrada](https://www.figma.com/design/qH5jM5xt7MBvPSqTwwAAqI/dashboard?node-id=90-2).

## Implementado no arquivo de design

44 variáveis, distribuídas entre as coleções `Overload / Primitivos` e `Overload / Interface`. As cores semânticas referenciam as primitivas por aliases. Inclui espaçamentos, raios e dimensões de toque/botão.

8 estilos de texto: Display, Title, Heading, Body, Label, Caption, Button e Metric. Famílias: Montserrat, Manrope e Space Grotesk, seguindo a home aprovada.

7 conjuntos, com 26 variantes de componentes: Button (tipo e estado), Field, Item, Chip, SetRow, Banner e Navigation. Os conteúdos têm propriedades de texto editáveis.

### Cores principais

| Papel | Valor |
| --- | --- |
| Fundo | `#0E0E12` |
| Superfície | `#1F1F23` |
| Superfície de destaque | `#1B1723` |
| Seleção | `#352044` |
| Ação principal | `#CCFF00` |
| Texto principal | `#FAFAFC` |
| Texto secundário | `#B9B9C3` |
| Texto de destaque | `#CEACEF` |
| Borda | `#37333F` |
| Borda de destaque | `#593378` |

Espaçamentos: 0, 4, 8, 12, 16, 20, 24, 32 e 48. Raios: 8, 12, 16 e 999. Área mínima de toque: 48. Botão: 52.

## Telas criadas

1. Entrar, criar conta e recuperar senha.
2. Lista de fichas, detalhe e edição da ficha.
3. Catálogo com busca/filtros, detalhe do exercício e exercício personalizado.
4. Treino ativo: valores anteriores, carga/repetições, confirmação individual de série, descanso e RIR opcional.
5. Resumo do treino concluído.
6. Histórico e detalhe da sessão.
7. Perfil e preferências.
8. Estados: nenhuma ficha, nenhum treino, busca sem resultados, erro de acesso, recuperação enviada, offline/sincronização pendente e confirmação de abandono.

Usar largura de 390 px, auto-layout, instâncias dos componentes e variáveis semânticas. Preservar a home aprovada. Copiar valores anteriores não deve concluir a série. Distinguir RIR de RPE. Só apresentar sincronização concluída quando esse estado for verdadeiro.

## Validação e limites do protótipo

O acesso foi restabelecido e as 21 composições foram criadas e inspecionadas visualmente. A biblioteca também foi validada após a correção dos textos multilinha. Foram corrigidas a posição da navegação inferior e a legibilidade dos rótulos das séries.

As telas contêm 103 instâncias da biblioteca e 23 ligações de navegação entre telas. O protótipo cobre parte das transições; não simula autenticação, digitação, cronômetro, cálculos ou persistência. Preferências aparecem como entradas no perfil, sem telas individuais de configuração. Conteúdos, recordes e status de sincronização são dados ilustrativos.

As telas longas representam o conteúdo completo para implementação com rolagem. A home aprovada permanece preservada na página original.

O arquivo `figma-design-system.json` registra os recursos da biblioteca; `figma-screens.json` registra as telas e seus IDs. Próximo passo: revisar as composições com o usuário e implementar o fluxo aprovado no app.
