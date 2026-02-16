---
name: test-agent
description: Writes and runs unit tests following project conventions. Use when creating or updating tests.
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

You write and run unit tests for the Hedvig iOS app (Ugglan). Follow project conventions exactly. Reference CLAUDE-testing.md for full patterns.

## Test File Location

Tests go in `Projects/<Module>/Tests/`. MockData goes in a separate `MockData.swift` in the same directory.

## Required Patterns

### Imports and Class Declaration

```swift
@preconcurrency import XCTest
import hCore

@testable import ModuleName

@MainActor
final class SomeTests: XCTestCase {
    weak var sut: MockSomeService?
```

### Memory Leak Detection (mandatory)

Every test class MUST have:
- `weak var sut: MockSomeService?` property
- `sut = mockService` assignment in each test
- `XCTAssertNil(sut)` in tearDown after removing DI dependency

### tearDown

```swift
override func tearDown() async throws {
    Dependencies.shared.remove(for: SomeClientProtocol.self)
    try await Task.sleep(seconds: 0.0000001)
    XCTAssertNil(sut)
}
```

### MockData Factory

Create a `MockData` struct with `@discardableResult` static factory methods. Each factory:
1. Accepts `@escaping` closures with sensible defaults
2. Creates the mock service
3. Registers it via `Dependencies.shared.add(module: Module { () -> ProtocolType in service })`
4. Returns the mock

```swift
@MainActor
struct MockData {
    @discardableResult
    static func createMockSomeService(
        fetchItems: @escaping FetchItems = { [.init(id: "default")] }
    ) -> MockSomeService {
        let service = MockSomeService(fetchItems: fetchItems)
        Dependencies.shared.add(module: Module { () -> SomeClientProtocol in service })
        return service
    }
}
```

### Mock Service with Event Tracking

```swift
class MockSomeService: SomeClientProtocol {
    var events = [Event]()
    var fetchItems: FetchItems

    enum Event {
        case getItems
    }

    func getItems() async throws -> [Item] {
        events.append(.getItems)
        return try await fetchItems()
    }
}
```

### ViewModel Tests

ViewModels use `@Inject` to resolve services. Register mocks via DI before creating the ViewModel, then call methods and verify state.

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

### Store Tests (Legacy)

> PresentableStore is legacy. New tests should use the ViewModel pattern above.

For PresentableStore tests, add in setUp:
```swift
globalPresentableStoreContainer.deletePersistanceContainer()
```

Use `store.sendAsync(.action)` and `waitUntil` for async assertions.

## Test Methods

- All test methods are `async` (or `async throws`)
- Use `try! await` for success paths
- Use `do/catch` for failure paths
- Verify mock interactions via `mockService.events`
- Use `assert()` or `XCTAssert*` for assertions

## What to Test

- ViewModels: inject mock services via DI, call methods, verify state and event tracking (primary pattern)
- Services: verify data flow and event tracking
- Stores (legacy): verify state changes after actions via PresentableStore
- Do NOT test views directly

## Running Tests

```bash
xcodebuild test -workspace Ugglan.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

To run a specific test class:
```bash
xcodebuild test -workspace Ugglan.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:'ModuleTests/TestClassName'
```
