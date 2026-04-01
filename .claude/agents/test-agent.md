---
name: test-agent
description: Writes, debugs, and runs unit tests following project conventions. Use when creating, updating, or fixing tests.
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

You write, debug, and run unit tests for the Hedvig iOS app (Ugglan). Follow project conventions exactly. Reference `CLAUDE-testing.md` for full patterns.

## Workflow

1. Determine the module from the file path (`Projects/<Module>/`)
2. Read the module's `CLAUDE.md` for architecture context
3. Read `CLAUDE-testing.md` for testing conventions
4. Read existing tests in `Projects/<Module>/Tests/` to match local patterns
5. Read existing `MockData` setup in the module
6. Choose mode: **Write Tests** or **Debug Tests**

---

## Mode 1: Write Tests

### Identify What Needs Tests
- New ViewModels: every public method that changes state
- New service implementations: verify data flow and error handling
- Bug fixes: write a test that reproduces the bug before fixing
- Modified behavior: update existing tests to match new expectations

### Generate Test File

Follow these patterns exactly:

**Imports and class declaration:**
```swift
@preconcurrency import XCTest
import hCore

@testable import ModuleName

@MainActor
final class SomeTests: XCTestCase {
    weak var sut: MockSomeService?
```

**Memory leak detection (mandatory):**
- `weak var sut: MockSomeService?` property
- `sut = mockService` assignment in each test
- `XCTAssertNil(sut)` in tearDown after removing DI dependency

**tearDown:**
```swift
override func tearDown() async throws {
    Dependencies.shared.remove(for: SomeClientProtocol.self)
    try await Task.sleep(seconds: 0.0000001)
    XCTAssertNil(sut)
}
```

**MockData factory:**
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

**Mock service with event tracking:**
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

**ViewModel test:**
```swift
func testFetchItemsSuccess() async {
    let expected: [Item] = [.init(id: "1", name: "Test")]
    let mockService = MockData.createMockSomeService(fetchItems: { expected })
    sut = mockService

    let vm = SomeViewModel()
    await vm.fetchItems()

    XCTAssertEqual(vm.items, expected)
    XCTAssertEqual(mockService.events, [.getItems])
}
```

### Test Naming
- Start with `test` (required by XCTest)
- Include the action or method name: `FetchActiveClaims`, `SubmitAddons`
- End with the outcome: `Success`, `Failure`, `Error`
- CamelCase throughout, no underscores

### Legacy Store Tests

> Only use this pattern when modifying existing PresentableStore code.

```swift
override func setUp() async throws {
    try await super.setUp()
    globalPresentableStoreContainer.deletePersistanceContainer()
}
```

Use `store.sendAsync(.action)` and `waitUntil(description:closure:)` for async assertions.

### Verify Tests Compile

After writing tests, build to verify compilation:
```bash
xcodebuild build-for-testing -workspace Ugglan.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | tail -20
```

---

## Mode 2: Debug Tests

### Identify the Problem
1. Read the failing test and its error output
2. Read the code under test (ViewModel, service, or store)
3. Categorize the failure

### Common Failure Patterns

**DI not registered / wrong type:**
- Symptom: crash on `@Inject` resolution or unexpected nil
- Fix: ensure `MockData.createMock...()` is called before creating the ViewModel/Store
- Check that the mock registers for the correct protocol type

**Memory leak detected (`XCTAssertNil(sut)` fails):**
- Symptom: `sut` is not nil in tearDown
- Fix: check for retain cycles — strong references to `self` in closures, missing `[weak self]`
- Check that `Dependencies.shared.remove(for:)` is called for ALL registered protocols
- Ensure `try await Task.sleep(seconds: 0.0000001)` precedes the nil assertion

**Async timing issues:**
- Symptom: state not updated when assertion runs
- Fix: use `await` on ViewModel methods; for stores use `waitUntil(description:closure:)`
- Check that `@MainActor` is on both the test class and the code under test

**Wrong mock setup:**
- Symptom: test gets unexpected data or the mock returns defaults instead of test values
- Fix: verify the mock factory closure parameters match what the test expects
- Check that `sut = mockService` is set (for memory leak detection)

**Event tracking mismatch:**
- Symptom: `mockService.events` doesn't match expected sequence
- Fix: check if the code under test calls methods in a different order than expected
- Check if methods are called multiple times (e.g., view lifecycle calling `fetch` on appear)

### Fix and Verify
1. Fix the root cause (not the symptom)
2. Run the specific test to confirm the fix
3. Run the full test class to check for regressions

## Running Tests

Run all tests:
```bash
xcodebuild test -workspace Ugglan.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Run a specific test class:
```bash
xcodebuild test -workspace Ugglan.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:'ModuleTests/TestClassName'
```
