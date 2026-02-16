# Ugglan — Hedvig iOS App

Tuist-managed iOS monorepo. Latest Swift, targeting iOS 16+.

## Build & Run

```bash
scripts/post-checkout.sh   # Full setup after fresh clone (generates workspace, codegen, etc.)
tuist generate              # Regenerate Xcode workspace after module changes
```

- **"Ugglan"** scheme for dev builds, **"Hedvig"** for production.

## Project Structure

Modules: Addons, App, Authentication, Campaign, ChangeTier, Chat, Claims, Codegen, Contracts, CrossSell, EditCoInsured, ExampleUtil, Forever, hCore, hCoreUI, hGraphQL, Home, InsuranceEvidence, Market, MoveFlow, NotificationService, Payment, Profile, SubmitClaim, SubmitClaimChat, TerminateContracts, Testing, TestingUtil, TravelCertificate

Standard module layout:
```
Projects/<Module>/Sources/
  Models/                     # Data models
  Views/                      # SwiftUI views + ViewModels
  Service/
    Protocols/                # Service protocol definitions
    OctopusImplementation/    # GraphQL/API implementations
    DemoImplementation/       # Mock implementations for previews
```

Core modules: **hCore** (shared utilities, state management), **hCoreUI** (design system), **hGraphQL** (API layer).

## ViewModel Pattern (Primary)

ViewModels use `@Inject` to access services directly and expose state via `@Published` properties.

```swift
@MainActor
class SomeViewModel: ObservableObject {
    @Inject var someClient: SomeClientProtocol
    @Published var items: [Item] = []
    @Published var isLoading = false

    func fetchItems() async {
        isLoading = true
        do {
            items = try await someClient.getItems()
        } catch {
            // handle error
        }
        isLoading = false
    }
}
```

Views bind with `@StateObject` or `@ObservedObject`.

## State Management — PresentableStore (Legacy)

> **Do not use PresentableStore for new features.** Use the ViewModel pattern above instead. This section documents the legacy pattern found in existing code.

**State** conforms to `StateProtocol`, **Action** conforms to `ActionProtocol`, **Store** extends `StateStore<State, Action>`.

```swift
public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {
    @Inject var fetchClaimsClient: hFetchClaimsClient

    override public func effects(_ getState: @escaping () -> ClaimsState, _ action: ClaimsAction) async {
        // Side effects: API calls, async work. Dispatch results via send() / sendAsync().
    }

    override public func reduce(_ state: ClaimsState, _ action: ClaimsAction) async -> ClaimsState {
        // Pure state mutations. Return new state.
    }
}
```

Legacy store access: `let store: ClaimsStore = globalPresentableStoreContainer.get()`

## Navigation — Router System

Custom `Router` from hCoreUI. Each navigation enum conforms to `TrackingViewNameProtocol`.

```swift
RouterHost(router: router, tracking: self) {
    RootView()
        .routerDestination(for: SomeRoute.self) { route in ... }
}

router.push(SomeRoute.detail(id: "123"))              // Push
.modally(item: $vm.showDetail) { item in ... }        // Modal
.detent(item: $vm.showSheet, transitionType: ...) { } // Bottom sheet
```

## Service Layer

Every service follows the **Protocol + OctopusImplementation + DemoImplementation** triple:

```swift
// Protocol (Service/Protocols/):
@MainActor
public protocol hFetchClaimsClient {
    func getActiveClaims() async throws -> [ClaimModel]
}

// OctopusImplementation (Service/OctopusImplementation/): real GraphQL calls
// DemoImplementation (Service/DemoImplementation/): mocks for previews/tests
```

## Dependency Injection

```swift
@Inject var client: hFetchClaimsClient                                          // Usage
Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in Impl() })  // Register
Dependencies.shared.remove(for: hFetchClaimsClient.self)                        // Teardown
```

## UI Components — hCoreUI Design System

Always use the design system instead of raw SwiftUI equivalents:

| Use this         | Instead of              |
|------------------|-------------------------|
| `hForm`          | `Form` / `ScrollView`   |
| `hSection`       | `Section`               |
| `hRow`           | List row                |
| `hButton`        | `Button`                |
| `hText`          | `Text`                  |
| `hField`         | `TextField` wrapper     |
| `hPill`          | Tag / badge             |

- **Colors**: `hTextColor.Opaque.primary`, `hSignalColor.Green.element`, `hFillColor.Opaque.disabled`
- **Spacing**: `.padding6`, `.padding8`, `.padding16`
- **Corner radius**: `.cornerRadiusXS`

## Localization

All user-facing strings via generated `L10n` constants:
```swift
L10n.ClaimStatus.title
L10n.General.errorBody
```

## GraphQL

Apollo iOS client. `.graphql` files live in the hGraphQL module. Code generation via the Codegen project.

## Code Style

- **Line length**: 120 characters
- **Indentation**: 4 spaces
- **Sorted imports** (enforced by SwiftLint)
- SwiftLint scans `Projects/`, excludes `Projects/*/Sources/Derived`
- swift-format configured in `.swift-format`

## Don'ts

1. **Do NOT use PresentableStore (State/Action/Store) for new features** — use ViewModels with `@Inject` services
2. **Do NOT use `@Observable`** — use `@MainActor class VM: ObservableObject` with `@Published`
3. **Do NOT use `NavigationStack` / `NavigationLink`** — use `Router`, `RouterHost`, `.routerDestination`
4. **Do NOT use raw SwiftUI `Form`/`Section`/`Text`/`Button`** — use `hForm`/`hSection`/`hText`/`hButton`
5. **Do NOT use TCA / ComposableArchitecture**
6. **Do NOT omit `@MainActor`** on ViewModels, Store subclasses, and service protocols
7. **Do NOT hardcode user-facing strings** — use `L10n.X.Y.z`
8. **Do NOT create services without the Protocol + OctopusImplementation + DemoImplementation triple**
9. **Do NOT skip `TrackingViewNameProtocol`** on navigation enums
10. **When requirements are unclear, ask** — do not assume
