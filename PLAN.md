# Plano — Polimento do onboarding e build de verificação

## Stack
- 100% Português brasileiro nas strings de UI
- Swift + SwiftUI + SwiftData (sem React Native, sem Supabase)
- Paleta travada (hex):
  - Sage `#7A9E7E`
  - Terracota `#E8A598`
  - Areia `#F4EDE4`
  - Charcoal `#1A1A1A`
  - Cinza `#6B6B6B`

## Já entregue

A maior parte do checklist está implementada no código Swift atual:

- **Paleta travada** nos hex acima (`Utilities/Theme.swift`).
- **Home**: anel de progresso com semana atual, contador de dias em terracota, card "Marco da semana", card de comunidade ("X mães na semana Y"), dicas com bullets sage. A linha "Ações rápidas" foi removida.
- **Diário**: emoji picker de 5 estados, notas multilinha, segmented Peso/Humor/Sono/Náusea com gráfico em sage e degradê areia.
- **Agenda**: hora em cada cartão, borda colorida por tipo (consulta/ultrassom/vacina/exame), toque para editar, toggle de lembrete, botão "Adicionar ao calendário", seções Próximas e Passadas.
- **Contrações**: três estados (Iniciar / Pausar+Parar / Iniciar nova), feedback háptico, gramática correta no resumo, banner terracota com padrão 5-1-1, exportação CSV.
- **Perfil**: rebuild completo com cartão de usuário, dados pessoais editáveis, gravidez editável, preferências, exportações, resetar onboarding e apagar tudo com confirmação.

## Onboarding emocional — status

- [x] **Indicador de progresso**: `OnboardingProgressDots(total: 5, current: ...)` presente nas telas 2–5.
- [x] **Constelação**: botão + `DragGesture` (arraste para cima > 80pt) avançam, com offset elástico, háptica e capsule destacando conforme o gesto.
- [x] **Carta pessoal**: conteúdo dentro de `ScrollView` com hint e dots fixos no rodapé — nada corta no iPhone SE.
- [x] **Respiração**: dispara via `@AppStorage("onboardingEmotionalComplete")` em `ContentView`; o "Resetar onboarding" do Perfil zera essa chave e a tela reaparece.

## Validação

- [x] Build iOS verde via `runChecks` (PR #1 mergeado em `main`, `cd73b3c`).

## Fora de escopo

- Migração para React Native (o app é nativo Swift por decisão explícita).
- Integração com Supabase (persistência fica local em SwiftData).
