# Ugglan — Hedvig iOS App

Tuist-managed iOS monorepo. Latest Swift, targeting iOS 17+.

## Build & Run

Generated Xcode projects (`project.xcproj`, JSON format, Xcode 27.2+) and codegen output (`Derived/`) are
committed — a fresh clone opens and builds directly. Tuist manifests remain the source of truth: never hand-edit
`project.xcproj`; change `Project.swift` / `Tuist/` and regenerate, then commit the generated diff.

```bash
scripts/install-tuist.sh   # One-time: installs mise + tuist (mise is required by swiftgen.sh)
scripts/post-checkout.sh   # Regenerate everything (workspace, swiftgen, GraphQL codegen) — commit the result
scripts/generate.sh         # Regenerate Xcode workspace after module changes — commit the result
```

- Use `scripts/generate.sh`, not a bare `tuist generate`: it also rewrites the schemes into the form Xcode saves
  (`scripts/normalize-schemes.py`), otherwise Xcode rewrites them on the next reload and leaves a diff.
- Don't commit a generation made in local-umbrella mode or with `TUIST_ENABLE_REVEAL=1`.
- `Package.resolved` isn't committed: Swift packages resolve from the version rules in the Tuist manifests, so
  builds can pick up newer versions within those rules.
- CI builds the committed files as is; the `Verify generated files` job fails if Tuist/SwiftGen output is stale
  (GraphQL isn't checked — it depends on the live dev schema).
- The same job runs `scripts/check-claude-docs.py`, which fails if a CLAUDE.md, agent or rule references a file that
  no longer exists. When you rename or delete a file, update the docs that mention it.

- **"Ugglan"** scheme for dev builds, **"Hedvig"** for production.

## Documentation

- **[CLAUDE-architecture.md](CLAUDE-architecture.md)** — ViewModel pattern, AppStateContainer stores, navigation,
  service layer, DI, GraphQL
- Per-module docs at `Projects/<Module>/CLAUDE.md` — architecture, entry points, dependencies, gotchas. They load
  automatically when Claude works on files in that module.
- Path-scoped rules in `.claude/rules/` load automatically for matching files:
  - `testing.md` (test files) — Swift Testing patterns, MockData, memory leak detection, naming
  - `design-system.md` and `accessibility.md` (view code) — hCoreUI components and tokens, accessibility CI rules
- Skills in `.claude/skills/` for multi-step jobs (Claude picks them up, or run `/<name>`):
  - `add-service` — GraphQL query → client protocol, service, demo, Octopus client, DI in all three blocks, mocks
  - `new-flow` — `.handleX(input:)` coordinator, navigation ViewModel and routes, hNavigationStack, App wiring
  - `new-module` — new module or Core/UI split: manifests, App wiring, `scripts/generate.sh`, docs

## Module Index

| Module | Description |
|--------|-------------|
| AddonsCore | Addon models, client protocol, service wrapper and demo data (UI-free) |
| AddonsUI | SwiftUI views, navigation and ViewModels for addon purchase and removal (built on AddonsCore) |
| App | Main app entry point, navigation hub, deep linking |
| AuthenticationCore | Auth protocols, service wrapper, shared state (`OTPState`, `SEBankIDState`) |
| AuthenticationUI | BankID + OTP login views and tracking conformance |
| CampaignCore | Discounts/referrals models, service protocol, and root ViewModel (UI-free) |
| CampaignUI | SwiftUI views and navigation for the discounts/referrals screen (built on CampaignCore) |
| ChangeTierCore | Tier change models, client protocol, service wrapper and demo client (UI-free) |
| ChangeTierUI | SwiftUI tier upgrade/downgrade flow, navigation and ViewModels (built on ChangeTierCore) |
| Chat | Customer support messaging |
| Claims | Claims list, status tracking, claim details |
| Codegen | GraphQL code generation tooling |
| ContractsCore | Contract models, `ContractStore`, client protocols, pet chip id service and demo clients (UI-free) |
| ContractsUI | Insurance contract list, details and actions (built on ContractsCore) |
| CrossSellCore | Cross-sell models, client protocol, service, store, tracking and demo data (UI-free) |
| CrossSellUI | SwiftUI views for cross-sell offers and addon banners (built on CrossSellCore) |
| EditStakeholdersCore | Stakeholder (co-insured/co-owner) models, client protocol and service (UI-free) |
| EditStakeholdersUI | Co-insured and co-owner management flow and ViewModels (built on EditStakeholdersCore) |
| Forever | Referral program |
| hCore | Core utilities, DI container, state management, extensions |
| hCoreUI | Design system: components, colors, spacing, typography |
| hGraphQL | Apollo GraphQL client, queries, mutations, fragments |
| Home | Home screen dashboard, important messages |
| InsuranceEvidence | Insurance evidence/certificate display |
| Market | Market/country selection |
| MoveFlowCore | Address change models, client protocol and inputs, demo client (UI-free) |
| MoveFlowUI | Address change flow, navigation and ViewModels (built on MoveFlowCore) |
| NotificationService | Push notification handling |
| Onboarding | One-time post-login onboarding flow (phone, missing co-insured/pet chip ids, payment, cross-sell) |
| Payment | Payment methods, payment history, direct debit |
| Profile | User profile, settings, app info |
| SubmitClaimChat | Claims submission flow (current, chat-based) |
| TerminateContractsCore | Termination models, client protocol, service wrapper and demo client (UI-free) |
| TerminateContractsUI | SwiftUI contract cancellation flow, navigation and ViewModels (built on TerminateContractsCore) |
| TravelCertificate | Travel insurance certificate generation |

## Project Structure

Typical feature module layout (varies by module — some use `Screens/` instead of `Views/`, not all directories are
present):
```
Projects/<Module>/Sources/
  Models/
  Views/ or Screens/          # SwiftUI views + ViewModels
  Service/
    Protocols/                # Service protocol definitions
    DemoImplementation/       # Mock implementations for previews
  Navigation/                 # Route definitions
```

OctopusImplementation (GraphQL API client implementations) lives in
`Projects/App/Sources/Service/OctopusClientsImplementation/`. GraphQL `.graphql` query/mutation files live in
`Projects/hGraphQL/GraphQL/Octopus/<Feature>/`.

Core modules: hCore (shared utilities), hCoreUI (design system), hGraphQL (API layer).

## UI Components — hCoreUI Design System

Always use the design system instead of raw SwiftUI equivalents:

| Use this | Instead of |
|----------|------------|
| `hForm` | `Form` / `ScrollView` |
| `hSection` | `Section` |
| `hRow` | List row |
| `hButton` | `Button` |
| `hText` | `Text` |
| `hFloatingTextField` | `TextField` wrapper |
| `hPill` | Tag / badge |

- **Colors**: `hTextColor.Opaque.primary`, `hSignalColor.Green.element`, `hFillColor.Opaque.disabled`
- **Spacing**: `.padding6`, `.padding8`, `.padding16`
- **Corner radius**: `.cornerRadiusXS`

The full component catalog and tokens are in `.claude/rules/design-system.md`, which loads with view files.

## Localization

All user-facing strings via generated `L10n` constants:
```swift
L10n.ClaimStatus.title
L10n.General.errorBody
```

Keys come from Lokalise: `scripts/translations.sh` (run by the weekday `UpdateLocalization` workflow) overwrites
`Localizable.strings`, so a key added there by hand disappears on the next pull. Add new keys in Lokalise; on
prototype branches use `"literal"  //L10n.key` until the key exists.

## Code Style

- **Line length**: 120 characters
- **Indentation**: 4 spaces
- **Sorted imports** (enforced by SwiftLint)
- SwiftLint scans `Projects/`, excludes `Projects/*/Sources/Derived`
- swift-format configured in `.swift-format`

## Working Style

- When a step doesn't need input, keep going, and put status notes in the same message as the next action. Stop and
  ask only when you can't continue without an answer (unclear requirements included — don't guess), or before anything
  destructive or outside this repo: deleting data, force-pushing, changing shared config.
- A PostToolUse hook (`.claude/hooks/accessibility-check.sh`) runs the accessibility CI checker on every edited file in
  `Projects/*/Sources/` and reports findings back. Fix them, or explain why one doesn't apply.
- After building or substantially changing a screen, invoke `@accessibility-agent` for the review the checker can't do
  (labels, reading order, focus).
- After writing or modifying feature code, invoke `@test-agent` for test generation and validation.

## Don'ts

1. **Prefer ViewModels over stores for new features** — reach for an `AppStore` (in `AppStateContainer`) only when state
   genuinely needs to be shared across views and survive view lifecycles
2. **Do NOT use `ObservableObject` / `@Published`** — nothing in the repo does. Use `@MainActor @Observable class`. To
   watch one from outside a view use `object.publisher(for: \.property)` (hCore) and hold the `AnyCancellable`
3. **Do NOT use raw SwiftUI `NavigationStack` / `NavigationLink`** — use `hNavigationStack` with
   `NavigationRouter` (the old `RouterHost` / `Router` no longer exists)
4. **Do NOT use raw SwiftUI `Form`/`Section`/`Text`/`Button`** — use `hForm`/`hSection`/`hText`/`hButton`
5. **Do NOT use TCA / ComposableArchitecture**
6. **Do NOT omit `@MainActor`** on ViewModels, `AppStore` types, and service protocols
7. **Do NOT hardcode user-facing strings** — use `L10n.X.Y.z`
8. **Do NOT create services without the Protocol + DemoImplementation + OctopusImplementation triple**
   (OctopusImplementation goes in `Projects/App/Sources/Service/OctopusClientsImplementation/`)
9. **Do NOT skip `TrackingViewNameProtocol`** on navigation enums
10. **Do NOT apply `.withDismissButton()` after `.embededInNavigation(...)`** — it must always come before it in the
    modifier chain, so the dismiss button is part of the content inside the navigation stack
