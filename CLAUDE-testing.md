# Testing Guidelines

## Framework

- **Swift Testing** (`import Testing`) for all unit tests
- Import pattern: `import Testing`, `import TestDependencies` (for `waitUntil` / `recordingErrors`), `@testable import ModuleName`
- Suites are `@MainActor final class`es; a per-test `init()` replaces `setUp`
- Tests are `@Test func`s, assertions are `#expect(...)`, unwrapping/preconditions are `try #require(...)`
- Expected errors: `#expect(throws: SomeError.self) { ... }`, or `await #expect(throws: SomeError.self) { try await ... }`
- Tests live in `Projects/<Module>/Tests/`, a module gets a test target by declaring `.tests` in its `Project.swift`
- UI tests (`Projects/App/Tests/UITests`, the `AppUITests` target) stay on XCTest / XCUITest

## Suite Layout and Shared State

Swift Testing creates a fresh suite instance per test and runs suites **in parallel in one process**. Anything
process-wide — `Dependencies.shared`, the global `log`, `globalAppStateContainer`, `Localization.Locale.currentLocale`
— is shared between suites, so one suite's `remove(for:)` can land inside another's `await`.

Modules whose tests touch shared globals nest every such suite under one serialized parent, `<Module>DependencySuite`:

```swift
// Projects/MyModule/Tests/MyModuleDependencySuite.swift
import Testing

@Suite(.serialized)
struct MyModuleDependencySuite {
    // Why these suites share state, so the next reader knows what must stay nested.
}
```

```swift
extension MyModuleDependencySuite {
    @MainActor
    final class MyViewModelTests {
        // ...
    }
}
```

`.serialized` only orders a suite's own children, so nesting is what keeps the suites apart. Suites that only build
values (pure model tests) share nothing and stay top level, where they keep running in parallel.

## Mock Pattern

Use a `MockData` factory struct per module with `@discardableResult` static methods. Each method creates a mock service, registers it in DI, and returns it.

```swift
@MainActor
struct MockData {
    @discardableResult
    static func createMockSomeService(
        fetchItems: @escaping FetchItems = { [.init(id: "id")] },
        deleteItem: @escaping DeleteItem = {}
    ) -> MockSomeService {
        let service = MockSomeService(fetchItems: fetchItems, deleteItem: deleteItem)
        Dependencies.shared.add(module: Module { () -> SomeClientProtocol in service })
        return service
    }
}
```

Mock services track calls via an `events: [Event]` enum:

```swift
class MockSomeService: SomeClientProtocol {
    var events = [Event]()
    var fetchItems: FetchItems

    enum Event {
        case getItems
        case deleteItem
    }

    func getItems() async throws -> [Item] {
        events.append(.getItems)
        return try await fetchItems()
    }
}
```

## DI in Tests

- **Register**: `Dependencies.shared.add(module: Module { () -> ProtocolType in service })` (via `MockData`)
- **Clean up** at the end of every test, in the closing `expect…Released()` helper: `Dependencies.shared.remove(for: ProtocolType.self)`
- Restore any global you swap (e.g. `log`): save it in `init`, put it back in the closing helper

## Teardown and Memory Leak Detection

There is no `tearDown`. `deinit` cannot replace it for this work: it is synchronous and nonisolated, while teardown
is main-actor work that often has to suspend before reading the weak reference. Instead every test ends by calling a
private closing helper:

1. Keep the object under test in a `private weak var sut` (or `store`, `vm`)
2. Scope the test body so its locals are gone before the check — a `do {}` block, or `await recordingErrors {}` when
   the body throws (see below)
3. After the scope, `await expect…Released()`: remove DI registrations, restore globals, give pending tasks a moment,
   then `#expect(sut == nil, ...)`
4. When a fire-and-forget `Task` (e.g. a fetch started from a ViewModel's `init`) may still hold the object, poll with
   `waitUntil(description:) { self.vm == nil }` instead of a fixed delay

```swift
private func expectServiceReleased() async {
    Dependencies.shared.remove(for: SomeClientProtocol.self)
    await delay(0.00001)
    #expect(sut == nil, "the mock service must not outlive the test that created it")
}
```

A non-isolated suite whose teardown is synchronous and asserts nothing (e.g. putting a `nonisolated(unsafe)` global
back) can use `deinit` — it runs after every test, including ones that throw.

## Throwing Test Bodies — `recordingErrors`

A test that `throw`s (or fails a `try #require`) exits immediately, skipping the closing helper and leaving mocks
registered for the next suite. Wrap a throwing body in `recordingErrors` (from `TestDependencies`): it records the
error as a test issue instead of propagating it, so teardown still runs.

```swift
@Test
func hideCrossSalesForwardsTheConversationId() async {
    await recordingErrors {
        let client = MockData.createMockConversationClient()
        try await ConversationService(conversationId: "conv-1").hideCrossSales()
        #expect(client.hiddenCrossSalesIds == ["conv-1"])
    }

    await expectServiceReleased()
}
```

## ViewModel Testing

ViewModels use `@Inject` to resolve services from DI. In tests, register mock services before creating the ViewModel, then verify state and event tracking.

```swift
@Test
func fetchItemsSuccess() async {
    do {
        let expected: [Item] = [.init(id: "1", name: "Test")]
        let mockService = MockData.createMockMyService(fetchItems: { expected })
        sut = mockService

        let vm = SomeViewModel()
        await vm.fetchItems()

        #expect(vm.items == expected)
        #expect(mockService.events == [.getItems])
    }

    await expectServiceReleased()
}
```

If the ViewModel's `init` starts a `Task` that resolves a lazy `@Inject`, wait for the ViewModel to be released before
removing the client — removing it first makes `@Inject` fatalError.

## Store Testing

`AppStore` instances are plain `@MainActor` `@Observable` classes — test them by constructing the store, awaiting the async methods, and reading the properties directly.

Reset persistence in `init` so cross-test state doesn't leak via on-disk snapshots, and nest the suite under the
module's `DependencySuite` (the container is process-wide):

```swift
extension PaymentDependencySuite {
    @MainActor
    final class StoreHistoryTests {
        private weak var store: PaymentStore?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        private func expectStoreReleased() {
            #expect(store == nil, "the payment store must not outlive the test that created it")
        }

        @Test
        func getHistorySuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentHistoryData: { historyData })
                let store = PaymentStore()
                self.store = store
                await store.getHistory()

                #expect(store.loadHistoryError == nil)
                #expect(store.paymentHistory == historyData)
                #expect(mockService.events == [.getPaymentHistoryData])
            }

            expectStoreReleased()
        }
    }
}
```

## Full Example

```swift
import TestDependencies
import Testing
import hCore

@testable import MyModule

extension MyModuleDependencySuite {
    @MainActor
    final class MyViewModelTests {
        private weak var sut: MockMyService?

        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: MyClientProtocol.self)
            await delay(0.00001)
            #expect(sut == nil, "the mock service must not outlive the test that created it")
        }

        @Test
        func fetchSuccess() async {
            do {
                let expected: [Item] = [.init(id: "1", name: "Test")]
                let mockService = MockData.createMockMyService(fetchItems: { expected })
                sut = mockService

                let vm = MyViewModel()
                await vm.fetchItems()

                #expect(vm.items == expected)
                #expect(mockService.events == [.getItems])
            }

            await expectServiceReleased()
        }

        @Test
        func fetchFailure() async {
            do {
                let mockService = MockData.createMockMyService(fetchItems: { throw MyError.failed })
                sut = mockService

                await #expect(throws: MyError.self) {
                    try await mockService.getItems()
                }
                #expect(mockService.events == [.getItems])
            }

            await expectServiceReleased()
        }
    }
}
```

## What to Test

- **ViewModels**: Inject mock services via DI, call methods, verify state changes and event tracking
- **Services**: Mock the client protocol, verify returned data and event tracking
- **Stores**: Call the store's async methods directly and assert on its properties; `globalAppStateContainer.clearPersistence()` in `init`
- **Not views directly**: UI is not unit tested

## When to Write Tests

- New ViewModels: every public method that changes state
- New service implementations: verify data flow and error handling
- Bug fixes: write a test that reproduces the bug before fixing
- Modified behavior: update existing tests to match new expectations

## Test Naming Conventions

Test functions use `func <subject><Scenario>` — describe what is being tested and what outcome is expected. `@Test`
marks them, so there is no `test` prefix.

**Naming rules:**
- Start with the action or method name in lower camel case: `fetchActiveClaims`, `submitAddons`, `confirmRemoval`
- End with the outcome: `Success`, `Failure`, `Error`
- For state/selection tests, describe the behaviour: `selectableAddonSelection`, `dismissHidesAndCallsMutation`
- No underscores — use camel case throughout
- Suites keep a `…Tests` class name; one file per suite, grouped in `ViewModelTests/`, `StoreTests/`, `ServiceTests/`,
  `ModelTests/` folders where the module has several kinds

## ViewModel Tests vs Store Tests

| | ViewModel | AppStore |
|---|---|---|
| Setup | Register mock via DI, create VM | Register mock via DI, `globalAppStateContainer.clearPersistence()` in `init`, instantiate store |
| Trigger | `await vm.method()` | `await store.method()` |
| Assert | `#expect(vm.property == expected)` | `#expect(store.property == expected)` |
| Teardown | `await expectServiceReleased()` (or `waitUntil` for `vm == nil`) | `expectStoreReleased()` |
| Use for | Screen-local state | Shared/persisted state used across screens |
