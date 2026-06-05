# File-a-Claim AppIntent — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Siri/Shortcuts AppIntent that opens the existing "Start a new claim" flow, including resilient handling of logged-out and token-expiry scenarios.

**Architecture:** A single `FileClaimAppIntent` (App target, `openAppWhenRun = true`) writes a pending action into `PendingAppIntentService`. A dispatcher on `ApplicationState` transition to `.loggedIn` consumes the action and posts a `.startNewClaim` notification — observed by `HomeNavigationViewModel`, which sets `claimsAutomationStartInput`. The existing `forceLogoutHook` is extended to call `recoverInFlight()` before tearing down session state, so the intent survives token expiry across the re-auth boundary.

**Tech Stack:** Swift 5.10+, SwiftUI, iOS 16+, Apple AppIntents framework, Tuist project generation, XCTest, Combine, Datadog SDK.

**Working branch:** `feature/app-intent-file-claim` (already created).

**Spec reference:** `docs/superpowers/specs/2026-06-05-app-intent-file-claim-design.md`

---

## File Structure

**New files (App target):**
- `Projects/App/Sources/AppIntents/PendingAppIntentAction.swift` — action enum
- `Projects/App/Sources/AppIntents/PendingAppIntentServiceProtocol.swift` — protocol
- `Projects/App/Sources/AppIntents/PendingAppIntentService.swift` — implementation
- `Projects/App/Sources/AppIntents/PendingAppIntentDispatcher.swift` — listens to ApplicationState, drains the service, posts the notification
- `Projects/App/Sources/AppIntents/FileClaimAppIntent.swift` — the intent
- `Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift` — `AppShortcutsProvider`
- `Projects/App/Sources/Resources/AppShortcuts.xcstrings` — localized phrase catalog

**New test files (App tests target):**
- `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`
- `Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift`

**Modified files:**
- `Projects/App/Sources/AppDelegate+DI.swift` — register service
- `Projects/App/Sources/AppDelegate.swift:213-228` — extend `forceLogoutHook` with `recoverInFlight()`
- `Projects/App/Sources/Navigation/MainNavigation.swift` — instantiate dispatcher; trigger on state transition
- `Projects/Home/Sources/Navigation/HomeNavigation.swift:22-43` — add observer for `.startNewClaim`
- `Projects/hCore/Sources/Notifications/` (new) or existing notification names file — declare `Notification.Name.startNewClaim`

---

## Task 1: Add `Notification.Name.startNewClaim`

**Files:**
- Find: existing notification name declarations (likely in `Projects/hCore/Sources/` — search before creating)
- Create or modify: a file extending `Notification.Name`

- [ ] **Step 1: Locate existing notification name declarations**

Run: `grep -rn "extension Notification.Name" /Users/sladannimcevic/Hedvig/ugglan/Projects --include="*.swift" -l`

If `.openChat` is defined somewhere obvious (e.g. `Projects/hCore/Sources/Notifications.swift`), add the new name there. Otherwise create `Projects/hCore/Sources/AppIntentNotifications.swift`.

- [ ] **Step 2: Add the notification name**

Add to the existing file (or create new):

```swift
import Foundation

extension Notification.Name {
    public static let startNewClaim = Notification.Name("startNewClaim")
}
```

If creating a new file, ensure it's included in the hCore framework target (Tuist `Project.framework` auto-globs `Sources/**/*.swift` so no Project.swift change is needed).

- [ ] **Step 3: Verify build**

Run: `tuist generate && xcodebuild -workspace Hedvig.xcworkspace -scheme hCore -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/hCore/Sources/
git commit -m "feat(hCore): add startNewClaim notification name"
```

---

## Task 2: Create `PendingAppIntentAction` enum

**Files:**
- Create: `Projects/App/Sources/AppIntents/PendingAppIntentAction.swift`

- [ ] **Step 1: Create the AppIntents directory**

```bash
mkdir -p /Users/sladannimcevic/Hedvig/ugglan/Projects/App/Sources/AppIntents
```

- [ ] **Step 2: Create the action enum**

```swift
import Foundation

public enum PendingAppIntentAction: Equatable, Sendable {
    case fileNewClaim
}
```

- [ ] **Step 3: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppIntents/PendingAppIntentAction.swift
git commit -m "feat(App): add PendingAppIntentAction enum"
```

---

## Task 3: Define `PendingAppIntentServiceProtocol`

**Files:**
- Create: `Projects/App/Sources/AppIntents/PendingAppIntentServiceProtocol.swift`

- [ ] **Step 1: Write the protocol**

```swift
import Foundation

@MainActor
public protocol PendingAppIntentServiceProtocol: AnyObject {
    func store(_ action: PendingAppIntentAction)
    func consume() -> PendingAppIntentAction?
    func recoverInFlight()
}
```

- [ ] **Step 2: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/PendingAppIntentServiceProtocol.swift
git commit -m "feat(App): add PendingAppIntentServiceProtocol"
```

---

## Task 4: Write failing test — store + consume happy path

**Files:**
- Create: `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`

- [ ] **Step 1: Create test directory**

```bash
mkdir -p /Users/sladannimcevic/Hedvig/ugglan/Projects/App/Tests/AppIntents
```

- [ ] **Step 2: Write the first test**

```swift
@testable import Ugglan
import XCTest

@MainActor
final class PendingAppIntentServiceTests: XCTestCase {
    func testStoreThenConsumeReturnsAction() {
        let clock = TestClock(now: Date(timeIntervalSince1970: 1_000_000))
        let service = PendingAppIntentService(clock: clock.now)

        service.store(.fileNewClaim)

        XCTAssertEqual(service.consume(), .fileNewClaim)
    }
}

private final class TestClock {
    var now: Date
    init(now: Date) { self.now = now }
}
```

The host module is `Ugglan` (confirmed from `Projects/App/Project.swift:148`); the test target is `AppTests` (line 171).

- [ ] **Step 3: Run test — verify it fails**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests/testStoreThenConsumeReturnsAction 2>&1 | tail -30`

Expected: FAIL with "Cannot find 'PendingAppIntentService' in scope".

(If `-only-testing` target name doesn't match, run all tests and check output for the relevant case.)

- [ ] **Step 4: Do not commit yet — implementation is in Task 5**

---

## Task 5: Implement `PendingAppIntentService` — store + consume

**Files:**
- Create: `Projects/App/Sources/AppIntents/PendingAppIntentService.swift`

- [ ] **Step 1: Write minimal implementation**

```swift
import Foundation

@MainActor
public final class PendingAppIntentService: PendingAppIntentServiceProtocol {
    public static let pendingTTL: TimeInterval = 5 * 60
    public static let inFlightAutoClearAfter: TimeInterval = 5

    private struct Pending {
        let action: PendingAppIntentAction
        let timestamp: Date
    }

    private var pending: Pending?
    private var inFlight: PendingAppIntentAction?
    private var inFlightExpiry: Date?

    private let clock: () -> Date

    public init(clock: @escaping () -> Date = Date.init) {
        self.clock = clock
    }

    public func store(_ action: PendingAppIntentAction) {
        pending = Pending(action: action, timestamp: clock())
    }

    public func consume() -> PendingAppIntentAction? {
        // Drop expired in-flight first
        if let expiry = inFlightExpiry, clock() >= expiry {
            inFlight = nil
            inFlightExpiry = nil
        }

        guard let p = pending else { return nil }
        pending = nil

        // TTL check
        if clock().timeIntervalSince(p.timestamp) > Self.pendingTTL {
            return nil
        }

        inFlight = p.action
        inFlightExpiry = clock().addingTimeInterval(Self.inFlightAutoClearAfter)
        return p.action
    }

    public func recoverInFlight() {
        guard let action = inFlight else { return }
        inFlight = nil
        inFlightExpiry = nil
        pending = Pending(action: action, timestamp: clock())
    }
}
```

- [ ] **Step 2: Update test to use the real clock injection**

Edit `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`:

```swift
@testable import Ugglan
import XCTest

@MainActor
final class PendingAppIntentServiceTests: XCTestCase {
    private var now: Date!

    override func setUp() {
        super.setUp()
        now = Date(timeIntervalSince1970: 1_000_000)
    }

    private func makeService() -> PendingAppIntentService {
        PendingAppIntentService(clock: { [weak self] in self?.now ?? Date() })
    }

    func testStoreThenConsumeReturnsAction() {
        let service = makeService()
        service.store(.fileNewClaim)
        XCTAssertEqual(service.consume(), .fileNewClaim)
    }
}
```

- [ ] **Step 3: Run test — verify it passes**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests/testStoreThenConsumeReturnsAction 2>&1 | tail -20`

Expected: TEST SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppIntents/PendingAppIntentService.swift Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "feat(App): implement PendingAppIntentService store+consume"
```

---

## Task 6: Add `consume` returns nil after TTL test + verify

**Files:**
- Modify: `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`

- [ ] **Step 1: Add failing test for TTL**

Append to `PendingAppIntentServiceTests`:

```swift
func testConsumeReturnsNilAfterPendingTTLExpired() {
    let service = makeService()
    service.store(.fileNewClaim)
    now = now.addingTimeInterval(PendingAppIntentService.pendingTTL + 1)
    XCTAssertNil(service.consume())
}

func testConsumeReturnsNilWhenNothingStored() {
    let service = makeService()
    XCTAssertNil(service.consume())
}

func testSecondConsumeReturnsNil() {
    let service = makeService()
    service.store(.fileNewClaim)
    _ = service.consume()
    XCTAssertNil(service.consume())
}
```

- [ ] **Step 2: Run tests**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests 2>&1 | tail -30`

Expected: all 4 tests PASS (implementation already covers these — sanity check).

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "test(App): cover pending-TTL + nil-consume cases"
```

---

## Task 7: Add `recoverInFlight` tests + verify

**Files:**
- Modify: `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`

- [ ] **Step 1: Add tests**

Append:

```swift
func testRecoverInFlightMovesActionBackToPending() {
    let service = makeService()
    service.store(.fileNewClaim)
    XCTAssertEqual(service.consume(), .fileNewClaim)

    service.recoverInFlight()

    XCTAssertEqual(service.consume(), .fileNewClaim)
}

func testRecoverInFlightIsNoOpWhenNothingInFlight() {
    let service = makeService()
    service.recoverInFlight()
    XCTAssertNil(service.consume())
}

func testRecoverInFlightResetsTTL() {
    let service = makeService()
    service.store(.fileNewClaim)
    XCTAssertEqual(service.consume(), .fileNewClaim)

    // Advance past original TTL
    now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
    service.recoverInFlight()
    // Recovered with fresh timestamp; should still be consumable
    now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
    XCTAssertEqual(service.consume(), .fileNewClaim)
}

func testInFlightAutoClearsAfterWindow() {
    let service = makeService()
    service.store(.fileNewClaim)
    XCTAssertEqual(service.consume(), .fileNewClaim)

    // Advance past the in-flight auto-clear window
    now = now.addingTimeInterval(PendingAppIntentService.inFlightAutoClearAfter + 1)
    // Trigger expiry check by attempting another consume
    _ = service.consume()

    // recoverInFlight should now be a no-op
    service.recoverInFlight()
    XCTAssertNil(service.consume())
}
```

- [ ] **Step 2: Run tests**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests 2>&1 | tail -30`

Expected: all 8 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "test(App): cover recoverInFlight + auto-clear behavior"
```

---

## Task 8: Register the service in DI

**Files:**
- Modify: `Projects/App/Sources/AppDelegate+DI.swift`

- [ ] **Step 1: Read current DI registrations**

Read `Projects/App/Sources/AppDelegate+DI.swift` and locate the block where module-agnostic clients are registered (around lines 29-38, before the demo/staging branch). The new registration should be placed near the top — alongside `FeatureFlags`, `URLOpener`, `DateService` — since this service is environment-independent.

- [ ] **Step 2: Add the registration**

In `AppDelegate+DI.swift`, after the `DateService` registration (around line 38):

```swift
Dependencies.shared.add(module: Module { () -> PendingAppIntentServiceProtocol in PendingAppIntentService() })
```

- [ ] **Step 3: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppDelegate+DI.swift
git commit -m "feat(App): register PendingAppIntentService in DI"
```

---

## Task 9: Create `PendingAppIntentDispatcher`

The dispatcher consumes the service and posts `.startNewClaim` when ApplicationState becomes `.loggedIn`.

**Files:**
- Create: `Projects/App/Sources/AppIntents/PendingAppIntentDispatcher.swift`

- [ ] **Step 1: Write the dispatcher**

```swift
import Foundation
import hCore

@MainActor
public final class PendingAppIntentDispatcher {
    private let service: PendingAppIntentServiceProtocol
    private let notificationCenter: NotificationCenter

    public init(
        service: PendingAppIntentServiceProtocol,
        notificationCenter: NotificationCenter = .default
    ) {
        self.service = service
        self.notificationCenter = notificationCenter
    }

    /// Call when the app reaches a state where the home tab is mounted and ready
    /// to receive navigation signals (i.e. after `ApplicationState.state == .loggedIn`
    /// and the root scene has finished launch).
    public func drainAndDispatch() {
        guard ApplicationState.currentState == .loggedIn else { return }
        guard let action = service.consume() else { return }

        switch action {
        case .fileNewClaim:
            log.info("AppIntent dispatch: fileNewClaim", error: nil, attributes: nil)
            notificationCenter.post(name: .startNewClaim, object: nil)
        }
    }
}
```

- [ ] **Step 2: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/PendingAppIntentDispatcher.swift
git commit -m "feat(App): add PendingAppIntentDispatcher"
```

---

## Task 10: Wire dispatcher into `MainNavigationViewModel` state transition

**Files:**
- Modify: `Projects/App/Sources/Navigation/MainNavigation.swift` (around lines 108-139 — the `state` `didSet`)

- [ ] **Step 1: Read the current didSet block**

Read `Projects/App/Sources/Navigation/MainNavigation.swift` lines 100-150 to see the current `state` `didSet` implementation.

- [ ] **Step 2: Add dispatcher property + invocation**

Inside the `MainNavigationViewModel` class:

```swift
@Inject private var pendingAppIntentService: PendingAppIntentServiceProtocol
private lazy var pendingAppIntentDispatcher = PendingAppIntentDispatcher(service: pendingAppIntentService)
```

In the `state` `didSet`, after the existing handling for the `.loggedIn` case (where `ApplicationContext.shared.setValue(to: true)`, fetches start, etc.), add **after a short delay to let HomeNavigationViewModel finish mounting**:

```swift
if state == .loggedIn {
    // ... existing code ...

    Task { @MainActor in
        // Give HomeNavigationViewModel a moment to instantiate and register
        // its `.startNewClaim` observer before we post the notification.
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        self.pendingAppIntentDispatcher.drainAndDispatch()
    }
}
```

- [ ] **Step 3: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Also drain on cold launch when already logged in**

In `MainNavigationViewModel.init()` (or `viewDidAppear`-equivalent — find the place where `hasLaunchFinished` flips to true), trigger the same drain if `state == .loggedIn`:

```swift
// in MainNavigationViewModel, after the existing post-launch handling:
if ApplicationState.currentState == .loggedIn {
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s, larger margin on cold launch
        self.pendingAppIntentDispatcher.drainAndDispatch()
    }
}
```

(If `hasLaunchFinished` is the gate, hook in there instead so the home tab is definitely mounted.)

- [ ] **Step 5: Verify build again**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 6: Commit**

```bash
git add Projects/App/Sources/Navigation/MainNavigation.swift
git commit -m "feat(App): drain pending AppIntent on loggedIn transitions"
```

---

## Task 11: Add `.startNewClaim` observer in `HomeNavigationViewModel`

**Files:**
- Modify: `Projects/Home/Sources/Navigation/HomeNavigation.swift` (around lines 22-43)

- [ ] **Step 1: Read current observers**

Read `Projects/Home/Sources/Navigation/HomeNavigation.swift` lines 18-68 to see the existing `.openChat` and `.openCrossSell` observer pattern.

- [ ] **Step 2: Add the observer**

Inside `HomeNavigationViewModel.init()`, after the existing `.openCrossSell` observer block (around line 68):

```swift
NotificationCenter.default.addObserver(forName: .startNewClaim, object: nil, queue: nil) {
    [weak self] _ in
    Task { @MainActor in
        self?.claimsAutomationStartInput = .init(sourceMessageId: nil)
    }
}
```

The existing `deinit` already calls `NotificationCenter.default.removeObserver(self)` so cleanup is handled.

- [ ] **Step 3: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/Home/Sources/Navigation/HomeNavigation.swift
git commit -m "feat(Home): observe startNewClaim notification"
```

---

## Task 12: Extend `forceLogoutHook` with `recoverInFlight`

**Files:**
- Modify: `Projects/App/Sources/AppDelegate.swift:213-228`

- [ ] **Step 1: Read current hook**

Read `Projects/App/Sources/AppDelegate.swift` lines 200-230 to confirm the current `forceLogoutHook` body.

- [ ] **Step 2: Add `recoverInFlight` call**

Modify the `forceLogoutHook` closure (current lines 213-228) to call `recoverInFlight` BEFORE the state change:

```swift
forceLogoutHook = { [weak self] in
    if ApplicationState.currentState != .notLoggedIn {
        // Preserve any in-flight AppIntent so it survives forced re-auth
        let pendingService: PendingAppIntentServiceProtocol = Dependencies.shared.resolve()
        pendingService.recoverInFlight()

        self?.dismissAllVCs()
        DispatchQueue.main.async {
            ApplicationState.preserveState(.notLoggedIn)
            ApplicationState.state = .notLoggedIn
            self?.logout()

            let toast = ToastBar(
                type: .neutral,
                text: L10n.forceLogoutMessageTitle
            )
            Toasts.shared.displayToastBar(toast: toast)
        }
    }
}
```

Note: `forceLogoutHook` is annotated `@MainActor`. The `@MainActor` requirement on `PendingAppIntentServiceProtocol` is already satisfied.

`Dependencies.shared.resolve()` is the codebase's imperative DI API — same one used in `AppDelegate+Tracking.swift:37`.

- [ ] **Step 3: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppDelegate.swift
git commit -m "feat(App): recover pending AppIntent before forced logout"
```

---

## Task 13: Implement `FileClaimAppIntent`

**Files:**
- Create: `Projects/App/Sources/AppIntents/FileClaimAppIntent.swift`

- [ ] **Step 1: Write the intent**

```swift
import AppIntents
import Foundation
import hCore

@available(iOS 16.0, *)
public struct FileClaimAppIntent: AppIntent {
    public static let title: LocalizedStringResource = "File a claim"
    public static let description = IntentDescription(
        "Start a new insurance claim with Hedvig."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        let service: PendingAppIntentServiceProtocol = Dependencies.shared.resolve()
        service.store(.fileNewClaim)
        log.info("AppIntent fired: fileNewClaim", error: nil, attributes: nil)
        return .result()
    }
}
```

`Dependencies.shared.resolve()` is the codebase's imperative DI API (defined in `Projects/hCore/Sources/Dependencies/Dependencies.swift:49`; example usages in `AppDelegate+Tracking.swift:37`, `LoggedInNavigation.swift:150`).

- [ ] **Step 2: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/FileClaimAppIntent.swift
git commit -m "feat(App): add FileClaimAppIntent"
```

---

## Task 14: Smoke test for `FileClaimAppIntent.perform()`

**Files:**
- Create: `Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift`

- [ ] **Step 1: Write the test**

```swift
@testable import Ugglan
import XCTest

@MainActor
final class FileClaimAppIntentTests: XCTestCase {
    func testPerformStoresFileNewClaim() async throws {
        let stub = StubPendingAppIntentService()
        // Replace DI binding for the duration of the test.
        Dependencies.shared.add(module: Module { () -> PendingAppIntentServiceProtocol in stub })

        let intent = FileClaimAppIntent()
        _ = try await intent.perform()

        XCTAssertEqual(stub.stored, [.fileNewClaim])
    }
}

@MainActor
private final class StubPendingAppIntentService: PendingAppIntentServiceProtocol {
    var stored: [PendingAppIntentAction] = []
    func store(_ action: PendingAppIntentAction) { stored.append(action) }
    func consume() -> PendingAppIntentAction? { nil }
    func recoverInFlight() {}
}
```

- [ ] **Step 2: Run the test**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/FileClaimAppIntentTests 2>&1 | tail -20`

Expected: TEST SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift
git commit -m "test(App): smoke test FileClaimAppIntent.perform"
```

---

## Task 15: Create `AppShortcuts.xcstrings`

**Files:**
- Create: `Projects/App/Sources/Resources/AppShortcuts.xcstrings`

Markets confirmed: only `sv_SE` and `en_SE` per `Projects/hCore/Sources/Localization.swift:7-10`. Initial localization is EN + SV.

- [ ] **Step 1: Create the directory**

```bash
mkdir -p /Users/sladannimcevic/Hedvig/ugglan/Projects/App/Sources/Resources
```

- [ ] **Step 2: Create the String Catalog**

Write `Projects/App/Sources/Resources/AppShortcuts.xcstrings` with this exact JSON:

```json
{
  "sourceLanguage": "en",
  "strings": {
    "File a claim": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "File a claim" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Anmäl en skada" } }
      }
    },
    "Start a new insurance claim with Hedvig.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Start a new insurance claim with Hedvig." } },
        "sv": { "stringUnit": { "state": "translated", "value": "Påbörja en ny skadeanmälan med Hedvig." } }
      }
    },
    "File a claim with ${applicationName}": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "File a claim with ${applicationName}" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Anmäl en skada med ${applicationName}" } }
      }
    },
    "Start a ${applicationName} claim": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Start a ${applicationName} claim" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Starta en ${applicationName}-skadeanmälan" } }
      }
    },
    "Report a claim with ${applicationName}": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Report a claim with ${applicationName}" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Rapportera en skada med ${applicationName}" } }
      }
    },
    "New ${applicationName} claim": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "New ${applicationName} claim" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Ny ${applicationName}-skadeanmälan" } }
      }
    },
    "File Claim": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "File Claim" } },
        "sv": { "stringUnit": { "state": "translated", "value": "Anmäl skada" } }
      }
    }
  },
  "version": "1.0"
}
```

Swedish translations above are a first pass — flag them in the PR for the localization team to review and correct.

- [ ] **Step 3: Declare the resource in Tuist**

Read `Projects/App/Project.swift` and find the App target's `resources:` declaration. Confirm it globs `Sources/Resources/**` (or similar). If not, add an explicit resource entry for `AppShortcuts.xcstrings`. Re-run `tuist generate`.

Run: `tuist generate`

Expected: workspace regenerates without errors.

- [ ] **Step 4: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED.

- [ ] **Step 5: Commit**

```bash
git add Projects/App/Sources/Resources/AppShortcuts.xcstrings Projects/App/Project.swift
git commit -m "feat(App): add AppShortcuts string catalog (EN + SV)"
```

---

## Task 16: Implement `HedvigAppShortcuts` provider

**Files:**
- Create: `Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift`

- [ ] **Step 1: Write the provider**

```swift
import AppIntents

@available(iOS 16.0, *)
public struct HedvigAppShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FileClaimAppIntent(),
            phrases: [
                "File a claim with \(.applicationName)",
                "Start a \(.applicationName) claim",
                "Report a claim with \(.applicationName)",
                "New \(.applicationName) claim",
            ],
            shortTitle: "File Claim",
            systemImageName: "exclamationmark.bubble"
        )
    }
}
```

`AppShortcut` requires `\(.applicationName)` in every phrase — already satisfied. `LocalizedStringResource` resolution against `AppShortcuts.xcstrings` happens automatically because the catalog's keys match the literal string values.

- [ ] **Step 2: Verify build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20`

Expected: BUILD SUCCEEDED. The Xcode log may contain a one-time note about AppShortcuts metadata being extracted.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift
git commit -m "feat(App): add HedvigAppShortcuts provider"
```

---

## Task 17: End-to-end build + run

**Files:** none

- [ ] **Step 1: Full workspace build**

Run: `xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -30`

Expected: BUILD SUCCEEDED across all targets.

- [ ] **Step 2: Full test pass**

Run: `xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -30`

Expected: all tests PASS (specifically the new `PendingAppIntentServiceTests` and `FileClaimAppIntentTests`).

- [ ] **Step 3: Launch app, verify nothing regressed at runtime**

Open Xcode, launch the **Ugglan** scheme on an iOS 17 or iOS 18 simulator. Confirm:
- App boots normally
- Login flow works
- "Start new claim" button on Home tab still works

If any of these regressed, stop and diagnose before moving to manual Siri verification.

---

## Task 18: Manual Siri / Shortcuts verification

**Files:** none (manual checklist — record outcomes in PR description)

Run on a physical device (Siri requires it) or in the simulator with Shortcuts app where possible.

- [ ] **Cold launch via Siri, logged in:**
  1. Install fresh build, log in, kill the app
  2. "Hey Siri, file a claim with Hedvig"
  3. App opens directly to the claim flow

- [ ] **Cold launch via Siri, logged out:**
  1. Log out, kill the app
  2. "Hey Siri, file a claim with Hedvig"
  3. App opens to login screen
  4. Complete login
  5. After login, app navigates to claim flow

- [ ] **Token-expiry mid-launch:**
  1. Trigger token expiry by manipulating the keychain entry or by waiting long enough (consult Authentication team for fastest path)
  2. "Hey Siri, file a claim with Hedvig"
  3. App opens, briefly shows home, then `forceLogoutHook` fires → login screen
  4. Complete login
  5. After login, app navigates to claim flow

- [ ] **Phrases appear in Shortcuts app:**
  1. After fresh install, open Shortcuts app → search "Hedvig"
  2. Confirm all 4 phrases are listed under the Hedvig section

- [ ] **Spotlight discoverability:**
  1. Pull down on home screen → search "claim"
  2. Confirm "File a claim with Hedvig" appears as a suggested action

- [ ] **Swedish locale:**
  1. Set device language to Swedish, restart app
  2. "Hej Siri, anmäl en skada med Hedvig" → app opens to claim flow
  3. Confirm Swedish phrases appear in Shortcuts app

- [ ] **iOS 17 + iOS 18 sanity:**
  1. Repeat the "cold launch, logged in" scenario on iOS 17 and iOS 18 simulator/device
  2. Confirm no platform-specific regressions

Record the result of each row in the PR description as ✅ / ❌.

---

## Self-Review Checklist (for the implementer)

Before opening the PR:

- [ ] All 18 tasks completed; all commits on `feature/app-intent-file-claim`
- [ ] No new SwiftLint warnings (`swiftlint` from project root)
- [ ] swift-format passes (`swift format lint -r Projects/App/Sources/AppIntents`)
- [ ] No hardcoded user-facing strings outside `AppShortcuts.xcstrings`
- [ ] No use of legacy `PresentableStore`, raw `Form`/`Section`/`Text`/`Button`, or `@Observable`
- [ ] No push to remote (user reviews local commits first per project convention)
- [ ] PR description includes the manual verification checklist with outcomes
- [ ] Localization team notified about `AppShortcuts.xcstrings` for Swedish translation review

---

## Open Items the Implementer May Need to Resolve

These were identified during planning but require codebase verification at implementation time:

1. **`hasLaunchFinished` flag in `MainNavigationViewModel`** — exact name and observation point per the explorer report (line ~128). Confirm before wiring Task 10 Step 4.
2. **Tuist resource declaration** — confirm `Projects/App/Project.swift` includes `Sources/Resources/**` in the App target's resources. If not, add it explicitly in Task 15 Step 3.
3. **Analytics event** — the spec calls for an analytics event when the dispatcher posts `.startNewClaim` (e.g. `claim_flow_opened_via_app_intent`). The codebase does not appear to expose a `track(event:)`-style API today; only the Datadog `log.info(...)` path is in use. Once the analytics convention is clarified, extend `PendingAppIntentDispatcher.drainAndDispatch()` to emit the event.
