# Ugglan — Hedvig iOS App

Tuist-managed iOS monorepo. Latest Swift, targeting iOS 16+.

## Build & Run

```bash
scripts/post-checkout.sh   # Full setup after fresh clone (generates workspace, codegen, etc.)
tuist generate              # Regenerate Xcode workspace after module changes
```

- **"Ugglan"** scheme for dev builds, **"Hedvig"** for production.

## Documentation

- **[CLAUDE-architecture.md](CLAUDE-architecture.md)** — ViewModel pattern, legacy PresentableStore, navigation, service layer, DI, GraphQL
- **[CLAUDE-testing.md](CLAUDE-testing.md)** — XCTest patterns, MockData, memory leak detection, test naming
- **[CLAUDE-accessibility.md](CLAUDE-accessibility.md)** — VoiceOver, dynamic type, contrast, CI rules, auto-fix
- Per-module docs at `Projects/<Module>/CLAUDE.md` — architecture, key files, dependencies, gotchas

## Module Index

| Module | Description |
|--------|-------------|
| Addons | Insurance addon discovery and purchase |
| App | Main app entry point, navigation hub, deep linking |
| Authentication | Login, logout, auth token management |
| Campaign | Marketing campaign display and redemption |
| ChangeTier | Insurance plan tier upgrades/downgrades |
| Chat | Customer support messaging |
| Claims | Claims list, status tracking, claim details |
| Codegen | GraphQL code generation tooling |
| Contracts | Insurance contract management and details |
| CrossSell | Cross-selling insurance products |
| EditStakeholders | Co-insured and co-owner management |
| ExampleUtil | Development utilities and examples |
| Forever | Referral program |
| hCore | Core utilities, DI container, state management, extensions |
| hCoreUI | Design system: components, colors, spacing, typography |
| hGraphQL | Apollo GraphQL client, queries, mutations, fragments |
| Home | Home screen dashboard, important messages |
| InsuranceEvidence | Insurance evidence/certificate display |
| Market | Market/country selection |
| MoveFlow | Address change flow |
| NotificationService | Push notification handling |
| Payment | Payment methods, payment history, direct debit |
| Profile | User profile, settings, app info |
| SubmitClaimChat | Claims submission flow (current, chat-based) |
| TerminateContracts | Contract cancellation flow |
| Testing | Shared test utilities |
| TestingUtil | Additional test helpers |
| TravelCertificate | Travel insurance certificate generation |

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

See `Projects/hCoreUI/CLAUDE.md` for the full component reference.

## Localization

All user-facing strings via generated `L10n` constants:
```swift
L10n.ClaimStatus.title
L10n.General.errorBody
```

## Code Style

- **Line length**: 120 characters
- **Indentation**: 4 spaces
- **Sorted imports** (enforced by SwiftLint)
- SwiftLint scans `Projects/`, excludes `Projects/*/Sources/Derived`
- swift-format configured in `.swift-format`

## Agent Convention

After writing/modifying SwiftUI view files, invoke `@accessibility-agent` for accessibility review.
After writing/modifying feature code, invoke `@test-agent` for test generation and validation.

## Don'ts

1. **Do NOT use PresentableStore (State/Action/Store) for new features** — use ViewModels with `@Inject` services
2. **Do NOT use `@Observable`** — use `@MainActor class VM: ObservableObject` with `@Published`
3. **Do NOT use raw SwiftUI `NavigationStack` / `NavigationLink`** — use `hNavigationStack` with `NavigationRouter` (new) or `RouterHost` with `Router` (legacy)
4. **Do NOT use raw SwiftUI `Form`/`Section`/`Text`/`Button`** — use `hForm`/`hSection`/`hText`/`hButton`
5. **Do NOT use TCA / ComposableArchitecture**
6. **Do NOT omit `@MainActor`** on ViewModels, Store subclasses, and service protocols
7. **Do NOT hardcode user-facing strings** — use `L10n.X.Y.z`
8. **Do NOT create services without the Protocol + OctopusImplementation + DemoImplementation triple**
9. **Do NOT skip `TrackingViewNameProtocol`** on navigation enums
10. **When requirements are unclear, ask** — do not assume