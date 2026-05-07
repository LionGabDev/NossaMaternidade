# Análise de Estado — Nossa Maternidade (Swift nativo)

> Snapshot técnico em `c77c003` (origin/main após merge do PR #1). Documento de handoff e referência para próximas rodadas. Atualizar quando o estado real mudar.

## Identidade do app

| Campo | Valor |
|-------|-------|
| Nome | Nossa Maternidade (codinome interno "MamaVida") |
| Stack | Swift + SwiftUI + SwiftData (sem RN, sem Supabase) |
| Bundle ID | `br.com.nossamaternidade.app` |
| Marketing version | `1.0.0` |
| Current project version | `1` |
| Code sign | `Automatic`, `DEVELOPMENT_TEAM` em branco no `pbxproj` (preenchido localmente) |
| Repo | `gabrielvesz11-ship-it/NossaMaternidade` |
| Default branch | `main` |
| Orquestração | Rork (`rork.json`) |
| Xcode `objectVersion` | 77 (Xcode 26, `fileSystemSynchronizedGroups` — arquivos novos em `ios/NossaMaternidade/` entram no target sozinhos) |

## Estado git atual

- Working tree clean (exceto `.remember/` que é handoff de sessão e não deve ser commitado).
- `main` em `c77c003` (merge de `PR #1` `cd73b3c "fix(ios): resolve ambiguous '-' operator in ConstellationView"`).
- Sem tags de release.
- Sem `.github/workflows/` — **não há CI no GitHub Actions**. "Build verde via `runChecks`" mencionado em PLAN.md refere-se a verificação fora do GitHub (provável CI da Rork).
- Hook `validate-command.sh` bloqueia push direto na `main` — fluxo é sempre branch + PR.

## PR #2 — superseded

`fix/ios-constellation-opacity-ambiguity` (commit `25c82fc`) propõe a mesma correção de tipo de PR #1 (já mergeado), mais um clamp `[0.0, 1.0]`. Para a faixa garantida pelo `if distance < 120`, o resultado já está em `(0, 0.3]`, então o clamp é overkill defensivo. Resolução: **fechar como superseded by PR #1**.

## Conflito de identidade — atenção

O bundle `br.com.nossamaternidade.app` é o mesmo do projeto Expo `~/Projects/nathalia-app/` (ver `app.config.ts:48` e `android.package` linha 132). São duas implementações da mesma marca disputando a mesma slot de App Store Connect.

A decisão registrada em `PLAN.md` ("o app é nativo Swift por decisão explícita") deixa o Swift como sucessor. Implicações práticas:

- **App Store Connect**: a `app_id` `br.com.nossamaternidade.app` deve ser usada apenas pelo build Swift daqui em diante.
- **EAS / Expo**: o último submit de `production` em `nathalia-app` (4/mai/2026, build `417cd329`) errored no provisioning de Associated Domains — não chegou a publicar. As builds anteriores que entraram no TestFlight estavam em `1.0.0 build 18-24`; o Swift sobe agora como `1.0.0 build 1` (vai colidir com numeração existente).
- **Recomendação**: incrementar `CURRENT_PROJECT_VERSION` no `pbxproj` para um valor superior ao último build_number já submetido pelo Expo (≥ 25 pela margem). Confirmar com o histórico de TestFlight no App Store Connect antes de submit.

## Issues de código priorizados

### 1. CRÍTICO — `DataSeeder` sem guard de DEBUG
Em `ContentView.swift:25` `DataSeeder.seedIfNeeded(context: modelContext)` é chamado em todo `onAppear`. Em build de produção, na primeira execução com `UserProfile` vazio, popula:
- 1 perfil com `userName = "Maria Silva"`, `babyName = "Maria"`, data de nascimento `1990-03-15`
- 30 entradas de sintomas randomizadas
- 5 consultas em hospitais fictícios (Hospital São Lucas, Clínica Maternal, Laboratório Dasa, UBS Centro, Consultório Dra. Silva)
- 8 contrações falsas

Usuário real abriria o app e veria dados de outra pessoa. Ação: envolver a chamada em `#if DEBUG` ou em `if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"` (deixar SwiftUI Preview ainda chamar). Recomendado:

```swift
#if DEBUG
DataSeeder.seedIfNeeded(context: modelContext)
#endif
```

### 2. MÉDIO — `UIScreen.main.bounds` deprecated
Em `ConstellationView.swift:150,156-157` o uso de `UIScreen.main.bounds.{width,height}` está deprecated em iOS 16+. Não quebra runtime, mas gera warning a cada build. Migrar para `GeometryReader` em torno do conteúdo da view e ler `geo.size`.

### 3. MÉDIO — `NotificationService.add(request)` ignora erro
Em `NotificationService.swift:44,53`, `notificationCenter.add(request)` é chamado sem capturar erro. Em iOS 16+ a API tem variante `async throws` — falha de autorização ou trigger inválido some silenciosamente. Sugestão:

```swift
notificationCenter.add(request) { error in
    if let error { /* log/telemetria */ }
}
```

### 4. BAIXO — CSV export sem escape
Em `DataExporter.swift:20,47`, `notes.replacingOccurrences(of: ",", with: " ")` substitui vírgulas mas não escapa aspas, newlines, nem mitiga CSV-injection (`=cmd`). Para um app de saúde maternal o risco é baixo, mas o output pode quebrar parsers terceiros se o usuário colar texto rico. Considerar `.replacingOccurrences(of: "\"", with: "\"\"")` e wrap em aspas + sanitizar `=`/`+`/`@`/`-` no início.

### 5. BAIXO — force unwrap em `tips`
Em `PregnancyCalculator.swift:41` `allTips[24]!`. Defensivo: `allTips[24] ?? []`.

## Bons sinais

- `@Observable` em `NotificationService` (Swift 5.9+ Observation framework) com singleton via `shared`.
- `@Model` em `UserProfile`, `SymptomEntry`, `Appointment`, `Contraction`.
- `enum` para utilities sem estado (`PregnancyCalculator`, `DataExporter`, `DataSeeder`) — Swift idiomático.
- Persistência SwiftData configurada em `NossaMaternidadeApp.swift` com schema explícito.
- Onboarding emocional com 5 telas em `OnboardingFlowView` + flag `@AppStorage("onboardingEmotionalComplete")`.
- Fix de tipo em `ConstellationView` aplicado e mergeado.

## Pontos não verificados

- Build local de fato (não há runtime iOS instalado — confirmação fica para Rork/CI).
- Comportamento em iPhone SE (PLAN.md afirma OK; não validado em device aqui).
- `Config.swift` — citado no `.gitignore` mas não presente no working tree. Se contém secrets (API keys, Sentry DSN), está fora do repo. Confirmar como/onde é gerado em build.
- Privacy manifest (`PrivacyInfo.xcprivacy`) — App Store exige desde mai/2024. Não há indício de que foi adicionado.

## Próximas ações sugeridas (não executadas neste handoff)

1. Aplicar guard `#if DEBUG` no `DataSeeder` antes de qualquer build de TestFlight aberto.
2. Decidir incremento de `CURRENT_PROJECT_VERSION` para evitar colisão com builds Expo prévios em ASC.
3. Adicionar `PrivacyInfo.xcprivacy` ao target principal.
4. Migrar `UIScreen.main.bounds` para `GeometryReader` em `ConstellationView`.
5. Tratar erro do `add(request)` em `NotificationService`.
6. Configurar GitHub Actions com workflow de build iOS (`xcodebuild` em runner macOS) — hoje não há CI no repo.
7. Sanitizar CSV export (`DataExporter`) se houver chance de export ser aberto em Excel.

## Tag de proteção

Para imutabilizar este estado verde, este documento é commitado junto com `PLAN.md` sanitizado em uma branch dedicada e a tag `v1.0.0-build1-snapshot` é colocada no commit `c77c003` (estado pré-doc). Ver commit-message do branch para detalhes.
