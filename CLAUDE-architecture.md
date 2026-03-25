# Architecture Patterns

## ViewModel Pattern (Primary)

`@MainActor` classes conforming to `ObservableObject`. Services injected with `@Inject`; state exposed via `@Published` properties. Views bind with `@StateObject` (owning) or `@ObservedObject` (non-owning).

```swift
@MainActor
public class SomeViewModel: ObservableObject {
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

Navigation ViewModels hold both a router and `@Published` navigation state, passed down as `@ObservedObject`.

## PresentableStore (Legacy — Do Not Use for New Features)

State/Action/Store pattern. Document only for reading existing code.

- **State** conforms to `StateProtocol`
- **Action** conforms to `ActionProtocol`
- **Store** extends `StateStore<State, Action>`

```swift
public final class SomeStore: StateStore<SomeState, SomeAction> {
    @Inject var client: SomeClientProtocol

    override public func effects(_ getState: @escaping () -> SomeState, _ action: SomeAction) async {
        // Side effects: API calls, async work. Dispatch results via send() / sendAsync().
    }

    override public func reduce(_ state: SomeState, _ action: SomeAction) async -> SomeState {
        // Pure state mutations. Return new state.
    }
}
```

Legacy store access: `let store: SomeStore = globalPresentableStoreContainer.get()`

## Navigation

Two navigation systems exist. Code is migrating from Router to hNavigationStack.

### hNavigationStack + NavigationRouter (New)

Wraps SwiftUI `NavigationStack` with `NavigationRouter` for programmatic navigation:

```swift
@StateObject private var router = NavigationRouter()

hNavigationStack(router: router, tracking: self) {
    RootView()
}
```

### RouterHost + Router (Legacy)

Custom `Router` from `hCoreUI`. Navigation enums conform to `TrackingViewNameProtocol`.

```swift
RouterHost(router: router, tracking: SomeDetentType.root) {
    RootView()
        .routerDestination(for: SomeRouterType.self) { route in
            switch route { ... }
        }
}
```

Pushing and presenting:
```swift
router.push(SomeRoute.detail(id: "123"))           // Push onto stack
.modally(item: $vm.showDetail) { item in ... }     // Full-screen modal
.detent(item: $vm.showSheet, ...) { ... }          // Bottom sheet
```

Navigation enums must conform to `TrackingViewNameProtocol`.

## Service Layer

Every service follows the **Protocol + OctopusImplementation + DemoImplementation** triple.

- **Protocol** — lives in the feature module at `Service/Protocols/`
- **OctopusImplementation** — lives in `Projects/hGraphQL/GraphQL/Octopus/` (NOT per-module)
- **DemoImplementation** — lives in the feature module at `Service/DemoImplementation/`

```swift
// Protocol (feature module):
@MainActor
public protocol SomeClientProtocol {
    func getItems() async throws -> [Item]
}

// OctopusImplementation (hGraphQL):
class SomeClientOctopus: SomeClientProtocol {
    @Inject var octopus: hOctopus
    func getItems() async throws -> [Item] {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.SomeQuery())
        return data.items.map { Item(fragment: $0.fragments.itemFragment) }
    }
}

// DemoImplementation (feature module):
public class SomeClientDemo: SomeClientProtocol {
    public func getItems() async throws -> [Item] { [] }
}
```

> **Note:** Some modules (Claims, Addons, Profile, App) still have local `OctopusImplementation/` directories — these are wrongly placed and should be migrated to hGraphQL.

## Dependency Injection

Uses `@Inject` property wrapper (from `hCore`) and `Dependencies.shared`.

```swift
@Inject var client: SomeClientProtocol                                           // Usage
Dependencies.shared.add(module: Module { () -> SomeClientProtocol in Impl() })   // Register
Dependencies.shared.remove(for: SomeClientProtocol.self)                         // Teardown
```

## GraphQL

Apollo iOS client. `.graphql` files live in `Projects/hGraphQL/GraphQL/Octopus/<Feature>/`. Generated types in `Projects/hGraphQL/Sources/Derived/`.

**To add a new query or mutation:**

1. Create a `.graphql` file under `Projects/hGraphQL/GraphQL/Octopus/<Feature>/`
2. Run Codegen project (`scripts/post-checkout.sh` or Codegen scheme in Xcode)
3. Use the generated type in your OctopusImplementation

Never edit files in `Sources/Derived/` — they are generated and will be overwritten.