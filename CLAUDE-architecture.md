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

## AppStore (Shared App-Wide State)

For state that needs to be shared across views and survive view lifecycles — typically modelling a feature domain (claims, contracts, payments) rather than a single screen's state. Backed by the `AppStateContainer` module.

- Conform to `AppStore` (which inherits from `ObservableObject`)
- Mark the class `@MainActor` and apply the `@PersistableStore` macro to opt into on-disk persistence
- State as `@Published` properties; mark anything that should NOT be persisted with `@Transient` (errors, loading flags, etc.)

```swift
@MainActor
@PersistableStore
public final class SomeStore: AppStore {
    @Inject private var client: SomeClientProtocol

    @Published public internal(set) var items: [Item] = []

    @Transient @Published public private(set) var isFetching: Bool = false
    @Transient @Published public private(set) var fetchError: String?

    public init() {}

    public func fetchItems() async {
        isFetching = true
        do {
            items = try await client.getItems()
            fetchError = nil
        } catch {
            fetchError = error.localizedDescription
        }
        isFetching = false
    }
}
```

Reading a store from a SwiftUI view: `@AppObservedObject var store: SomeStore` (acts like `@StateObject`, but resolves the shared instance from `globalAppStateContainer`).

Reading a store from a ViewModel or non-View context: `@AppState private var store: SomeStore` (non-observing accessor) or `let store: SomeStore = globalAppStateContainer.get()`.

Persistence is opt-in via `@PersistableStore`: the macro synthesises a `Snapshot` type from non-`@Transient` `@Published` properties and writes a debounced JSON blob to Application Support. Call `globalAppStateContainer.clearPersistence()` to wipe (e.g. on logout) and `globalAppStateContainer.reset()` to drop in-memory store instances.

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
- **OctopusImplementation** — lives in `Projects/App/Sources/Service/OctopusClientsImplementation/`
- **DemoImplementation** — lives in the feature module at `Service/DemoImplementation/`

```swift
// Protocol (feature module):
@MainActor
public protocol SomeClientProtocol {
    func getItems() async throws -> [Item]
}

// OctopusImplementation (App module):
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

> **Note:** Some modules (Claims, Addons, Profile) have local `OctopusImplementation/` directories containing service wrappers/logging facades — these are not the actual GraphQL client implementations (those live in the App module).

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