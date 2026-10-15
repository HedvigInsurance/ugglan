# Architecture Patterns

## ViewModel Pattern (Primary)

`@MainActor @Observable` classes. Services injected with `@Inject`; state is plain stored properties. A view owns its view model with `@State`, takes an injected one with `@Bindable` (or a plain `let` when it needs no bindings), and reads a shared one with `@Environment(T.self)`.

Mark a stored property `@ObservationIgnored` when a view should not re-render for it — services, cancellables, delegates and child view models. `@Observable` tracks every stored property, so anything that is not view state needs saying so explicitly.

```swift
@MainActor
@Observable
public class SomeViewModel {
    @ObservationIgnored @Inject var someClient: SomeClientProtocol
    var items: [Item] = []
    var isLoading = false

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

Navigation ViewModels hold both a router and navigation state, passed down with `@Bindable` or through `@Environment`. Because `@Environment` has no projected value, a view that needs `$model.someProperty` off an injected model opens its `body` with a local `@Bindable var model = model`.

Nothing in the repo uses `ObservableObject`, `@Published` or `objectWillChange`.

Observation has no `combineLatest`, `removeDuplicates` or `debounce`, so when a chain needs them, bridge the property instead of reimplementing the chain:

```swift
store.publisher(for: \.activeContracts)
    .combineLatest(featureFlags.publisher(for: \.data))
    .removeDuplicates()
    .sink { ... }
```

`publisher(for:)` replays the current value on subscribe, as `@Published` did, so an existing `dropFirst()` still means what it meant.

### Watching an observable from outside a view

SwiftUI tracks property reads inside `body` on its own. Anywhere else — a view model reacting to another view model — use `ObservationWatcher` from hCore and hold it like an `AnyCancellable`:

```swift
tabWatcher = ObservationWatcher { [weak self] in
    _ = self?.selectedTab
} onChange: { [weak self] in
    self?.updateBadge()
}
```

`withObservationTracking` fires once and then stops, so the watcher re-arms itself after every change. Its callback runs on the next main-actor turn, because observation reports a change *before* it is applied and the new value is not readable yet. That also means it cannot catch a value that is set and cleared within one turn; something that transient needs a hook in the setter itself.

### Observation in a class hierarchy

`@Observable` only transforms the properties of the class it is attached to, so a subclass's own stored properties stop updating the UI, and nothing fails to compile. `ClaimIntentStepHandler` therefore conforms to `Observable` by hand: the base holds an `ObservationRegistrar` its subclasses share, and each observable property is computed over a private backing store.

```swift
@ObservationIgnored private var _selectedOption: String?
var selectedOption: String? {
    get {
        observationRegistrar.access(self, keyPath: \SubmitClaimFileUploadStep.selectedOption)
        return _selectedOption
    }
    set {
        observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFileUploadStep.selectedOption) {
            _selectedOption = newValue
        }
    }
}
```

A property that had `willSet` or `didSet` keeps that logic inline in the setter, capturing `oldValue` before the mutation. Prefer composition over a new observable base class; this pattern exists because the hierarchy was already there.

## AppStore (Shared App-Wide State)

For state that needs to be shared across views and survive view lifecycles — typically modelling a feature domain (claims, contracts, payments) rather than a single screen's state. Backed by the `AppStateContainer` module.

- Conform to `AppStore` (which inherits from `Observable`)
- Mark the class `@MainActor` and apply the `@PersistableStore` macro to opt into on-disk persistence
- State as plain stored properties; mark anything that should NOT be persisted with `@Transient` (errors, loading flags, etc.)

```swift
@MainActor
@PersistableStore
public final class SomeStore: AppStore {
    @Inject private var client: SomeClientProtocol

    public internal(set) var items: [Item] = []

    @Transient public private(set) var isFetching: Bool = false
    @Transient public private(set) var fetchError: String?

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

Reading a store from a SwiftUI view: `@AppObservedObject var store: SomeStore` (holds it in `@State`, resolved from `globalAppStateContainer`; `$store.property` gives a binding).

Reading a store from a ViewModel or non-View context: `@AppState private var store: SomeStore` (non-observing accessor) or `let store: SomeStore = globalAppStateContainer.get()`.

Persistence is opt-in via `@PersistableStore`: the macro synthesises a `Snapshot` type from non-`@Transient` stored properties and writes a debounced JSON blob to Application Support. Call `globalAppStateContainer.clearPersistence()` to wipe (e.g. on logout) and `globalAppStateContainer.reset()` to drop in-memory store instances.

## Navigation

Two navigation systems exist. Code is migrating from Router to hNavigationStack.

### hNavigationStack + NavigationRouter (New)

Wraps SwiftUI `NavigationStack` with `NavigationRouter` for programmatic navigation:

```swift
@State private var router = NavigationRouter()

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