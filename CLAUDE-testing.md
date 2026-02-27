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
        try await Task.sleep(seconds: 0.0000001)
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

## Store Testing (Legacy)

> **Note:** PresentableStore is legacy. New code should use ViewModels with `@Inject` services directly. Existing store tests are still valid but new tests should follow the ViewModel pattern above.

For tests involving `PresentableStore`, reset persistence in setUp:

```swift
override func setUp() async throws {
    try await super.setUp()
    globalPresentableStoreContainer.deletePersistanceContainer()
}
```

Use `store.sendAsync(.action)` and `waitUntil(description:closure:)` to assert async state changes:

```swift
let store = SomeStore()
await store.sendAsync(.fetchData)
try await waitUntil(description: "check state") {
    store.state.items == expectedItems && mockService.events.count == 1
}
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
- **Stores (legacy)**: Test actions and resulting state changes via `sendAsync` + `waitUntil`
- **Not views directly**: UI is not unit tested
