# Testing Guidelines

## Framework

- **XCTest** with async test methods
- All test classes must be annotated with `@MainActor`
- Import pattern: `@preconcurrency import XCTest`, `@testable import ModuleName`
- Tests live in `Projects/<Module>/Tests/`

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

- **Register**: `Dependencies.shared.add(module: Module { () -> ProtocolType in service })`
- **Clean up in tearDown**: `Dependencies.shared.remove(for: ProtocolType.self)`

## Memory Leak Detection

Every test class must use `weak var sut` and assert nil in tearDown:

```swift
@MainActor
final class SomeTests: XCTestCase {
    weak var sut: MockSomeService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: SomeClientProtocol.self)
        try await Task.sleep(seconds: 0.0000001)  // duration varies across tests
        XCTAssertNil(sut)
    }

    func testSomething() async {
        let mockService = MockData.createMockSomeService(fetchItems: { items })
        sut = mockService
        // ...
    }
}
```

## ViewModel Testing

ViewModels use `@Inject` to resolve services from DI. In tests, register mock services before creating the ViewModel, then verify state and event tracking.

```swift
func testFetchItemsSuccess() async {
    let expected: [Item] = [.init(id: "1", name: "Test")]
    let mockService = MockData.createMockMyService(fetchItems: { expected })
    sut = mockService

    let vm = SomeViewModel()
    await vm.fetchItems()

    XCTAssertEqual(vm.items, expected)
    XCTAssertEqual(mockService.events, [.getItems])
}
```

## Store Testing

`AppStore` instances are plain `@MainActor` `ObservableObject`s — test them by constructing the store, awaiting the async methods, and reading `@Published` properties directly.

Reset persistence in setUp so cross-test state doesn't leak via on-disk snapshots:

```swift
override func setUp() async throws {
    try await super.setUp()
    globalAppStateContainer.clearPersistence()
}
```

Drive the store via its async methods and assert on the properties:

```swift
let mockService = MockData.createMockSomeService(fetchItems: { expectedItems })
sut = mockService

let store = SomeStore()
await store.fetchItems()

XCTAssertEqual(store.items, expectedItems)
XCTAssertNil(store.fetchError)
XCTAssertEqual(mockService.events, [.getItems])
```

## Full Example

```swift
@preconcurrency import XCTest
import hCore

@testable import MyModule

@MainActor
final class MyViewModelTests: XCTestCase {
    weak var sut: MockMyService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MyClientProtocol.self)
        try await Task.sleep(seconds: 0.0000001)
        XCTAssertNil(sut)
    }

    func testFetchSuccess() async {
        let expected: [Item] = [.init(id: "1", name: "Test")]
        let mockService = MockData.createMockMyService(fetchItems: { expected })
        sut = mockService

        let vm = MyViewModel()
        await vm.fetchItems()

        XCTAssertEqual(vm.items, expected)
        XCTAssertEqual(mockService.events, [.getItems])
    }

    func testFetchFailure() async {
        let mockService = MockData.createMockMyService(
            fetchItems: { throw MyError.failed }
        )
        sut = mockService

        let vm = MyViewModel()
        do {
            await vm.fetchItems()
            XCTFail("Should throw")
        } catch {
            assert(error is MyError)
        }
        XCTAssertEqual(mockService.events, [.getItems])
    }
}
```

## What to Test

- **ViewModels**: Inject mock services via DI, call methods, verify state changes and event tracking
- **Services**: Mock the client protocol, verify returned data and event tracking
- **Stores**: Call the store's async methods directly and assert on its `@Published` properties; reset `globalAppStateContainer.clearPersistence()` in setUp
- **Not views directly**: UI is not unit tested

## When to Write Tests

- New ViewModels: every public method that changes state
- New service implementations: verify data flow and error handling
- Bug fixes: write a test that reproduces the bug before fixing
- Modified behavior: update existing tests to match new expectations

## Test Naming Conventions

Test methods use `func test<Subject><Scenario>` — describe what is being tested and what outcome is expected.

**Naming rules:**
- Start with `test` (required by XCTest)
- Include the action or method name: `FetchActiveClaims`, `SubmitAddons`, `ConfirmRemoval`
- End with the outcome: `Success`, `Failure`, `Error`
- For state/selection tests, describe the behaviour: `SelectableAddonSelection`, `ToggleableAddonSelection`
- No underscores — use camel case throughout

## ViewModel Tests vs Store Tests

| | ViewModel | AppStore |
|---|---|---|
| Setup | Register mock via DI, create VM | Register mock via DI, `globalAppStateContainer.clearPersistence()`, instantiate store |
| Trigger | `await vm.method()` | `await store.method()` |
| Assert | `XCTAssertEqual(vm.property, expected)` | `XCTAssertEqual(store.property, expected)` |
| Use for | Screen-local state | Shared/persisted state used across screens |
