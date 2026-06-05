# File-a-Claim AppIntent — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Siri/Shortcuts AppIntent that opens the existing "Start a new claim" flow, including resilient handling of logged-out and token-expiry scenarios.

**Architecture:** A single `FileClaimAppIntent` (App target, `openAppWhenRun = true`) writes a pending action into `PendingAppIntentService` (protocol in hCore, impl in App). `HomeNavigationViewModel` — which is only instantiated once the user is logged in — uses `@Inject` to access the service and drains any pending action from its `init`, setting `claimsAutomationStartInput` to launch the existing claim flow. This avoids timing/race issues because the VM's `init` is guaranteed to run after the `.loggedIn` state transition. The existing `forceLogoutHook` is extended to call `recoverInFlight()` before tearing down session state, so the intent survives token expiry across the re-auth boundary.

**Tech Stack:** Swift 5.10+, SwiftUI, iOS 16+, Apple AppIntents framework, Tuist project generation, XCTest, Combine, Datadog SDK.

**Working branch:** `feature/app-intent-file-claim` (already created).

**Spec reference:** `docs/superpowers/specs/2026-06-05-app-intent-file-claim-design.md`

---

## File Structure

**New files (hCore target):**
- `Projects/hCore/Sources/AppIntents/PendingAppIntentAction.swift` — action enum
- `Projects/hCore/Sources/AppIntents/PendingAppIntentServiceProtocol.swift` — protocol

**New files (App target):**
- `Projects/App/Sources/AppIntents/PendingAppIntentService.swift` — implementation
- `Projects/App/Sources/AppIntents/FileClaimAppIntent.swift` — the intent
- `Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift` — `AppShortcutsProvider`
- `Projects/App/Sources/Resources/AppShortcuts.xcstrings` — localized phrase catalog

**New test files (App tests target):**
- `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`
- `Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift`

**Modified files:**
- `Projects/App/Sources/AppDelegate+DI.swift` — register service
- `Projects/App/Sources/AppDelegate.swift:213-228` — extend `forceLogoutHook` with `recoverInFlight()`
- `Projects/Home/Sources/Navigation/HomeNavigation.swift:19-43` — `@Inject` service + drain on `init`

---

## Task 1: Create `PendingAppIntentAction` enum in hCore

**Files:**
- Create: `Projects/hCore/Sources/AppIntents/PendingAppIntentAction.swift`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p /Users/sladannimcevic/Hedvig/ugglan/Projects/hCore/Sources/AppIntents
```

- [ ] **Step 2: Create the action enum**

```swift
import Foundation

public enum PendingAppIntentAction: Equatable, Sendable {
    case fileNewClaim
}
```

- [ ] **Step 3: Regenerate workspace + verify build**

```bash
tuist generate
xcodebuild -workspace Hedvig.xcworkspace -scheme hCore -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/hCore/Sources/AppIntents/PendingAppIntentAction.swift
git commit -m "feat(hCore): add PendingAppIntentAction enum"
```

---

## Task 2: Define `PendingAppIntentServiceProtocol` in hCore

**Files:**
- Create: `Projects/hCore/Sources/AppIntents/PendingAppIntentServiceProtocol.swift`

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

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme hCore -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/hCore/Sources/AppIntents/PendingAppIntentServiceProtocol.swift
git commit -m "feat(hCore): add PendingAppIntentServiceProtocol"
```

---

## Task 3: Write failing test — store + consume happy path

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
import hCore

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

Host module: `Ugglan` (confirmed from `Projects/App/Project.swift:148`); test target: `AppTests` (line 171).

- [ ] **Step 3: Run test — verify it fails**

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests/testStoreThenConsumeReturnsAction 2>&1 | tail -30
```

Expected: FAIL with "Cannot find 'PendingAppIntentService' in scope".

- [ ] **Step 4: Do not commit yet — implementation is in Task 4**

---

## Task 4: Implement `PendingAppIntentService` — store + consume

**Files:**
- Create: `Projects/App/Sources/AppIntents/PendingAppIntentService.swift`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p /Users/sladannimcevic/Hedvig/ugglan/Projects/App/Sources/AppIntents
```

- [ ] **Step 2: Write the implementation**

```swift
import Foundation
import hCore

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
        if let expiry = inFlightExpiry, clock() >= expiry {
            inFlight = nil
            inFlightExpiry = nil
        }

        guard let p = pending else { return nil }
        pending = nil

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

- [ ] **Step 3: Run test — verify it passes**

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests/testStoreThenConsumeReturnsAction 2>&1 | tail -20
```

Expected: TEST SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppIntents/PendingAppIntentService.swift Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "feat(App): implement PendingAppIntentService store+consume"
```

---

## Task 5: Cover TTL + nil-consume cases

**Files:**
- Modify: `Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift`

- [ ] **Step 1: Add tests**

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

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests 2>&1 | tail -30
```

Expected: all 4 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "test(App): cover pending-TTL + nil-consume cases"
```

---

## Task 6: Cover `recoverInFlight` + in-flight auto-clear

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

    now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
    service.recoverInFlight()
    now = now.addingTimeInterval(PendingAppIntentService.pendingTTL - 1)
    XCTAssertEqual(service.consume(), .fileNewClaim)
}

func testInFlightAutoClearsAfterWindow() {
    let service = makeService()
    service.store(.fileNewClaim)
    XCTAssertEqual(service.consume(), .fileNewClaim)

    now = now.addingTimeInterval(PendingAppIntentService.inFlightAutoClearAfter + 1)
    _ = service.consume()

    service.recoverInFlight()
    XCTAssertNil(service.consume())
}
```

- [ ] **Step 2: Run tests**

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/PendingAppIntentServiceTests 2>&1 | tail -30
```

Expected: all 8 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/PendingAppIntentServiceTests.swift
git commit -m "test(App): cover recoverInFlight + auto-clear behavior"
```

---

## Task 7: Register the service in DI

**Files:**
- Modify: `Projects/App/Sources/AppDelegate+DI.swift`

- [ ] **Step 1: Read current DI registrations**

Read `Projects/App/Sources/AppDelegate+DI.swift` around lines 29-38 — the registrations of `FeatureFlags`, `URLOpener`, `AuthenticationClient`, `DateService` happen before the demo/staging branch. Add the new registration alongside them since it's environment-independent.

- [ ] **Step 2: Add the registration**

After the `DateService` registration (around line 38):

```swift
Dependencies.shared.add(module: Module { () -> PendingAppIntentServiceProtocol in PendingAppIntentService() })
```

- [ ] **Step 3: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppDelegate+DI.swift
git commit -m "feat(App): register PendingAppIntentService in DI"
```

---

## Task 8: Drain pending action from `HomeNavigationViewModel.init`

**Files:**
- Modify: `Projects/Home/Sources/Navigation/HomeNavigation.swift` (lines 19-43)

- [ ] **Step 1: Read current init**

Read `Projects/Home/Sources/Navigation/HomeNavigation.swift` lines 18-68 to confirm the existing init structure (notification observers for `.openChat` and `.openCrossSell`).

- [ ] **Step 2: Add `@Inject` property + drain call**

In `HomeNavigationViewModel`, add the injected service as a property, and add a drain call at the end of `init`:

```swift
@MainActor
public class HomeNavigationViewModel: ObservableObject {
    public static var isChatPresented = false

    @Inject private var pendingAppIntentService: PendingAppIntentServiceProtocol

    public init() {
        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            // ... existing body unchanged ...
        }

        NotificationCenter.default.addObserver(forName: .openCrossSell, object: nil, queue: nil) {
            // ... existing body unchanged ...
        }

        // Drain any pending AppIntent action that arrived while we weren't mounted
        // (cold launch via Siri, or recovered across forced re-auth).
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let action = self.pendingAppIntentService.consume() {
                switch action {
                case .fileNewClaim:
                    self.claimsAutomationStartInput = .init(sourceMessageId: nil)
                }
            }
        }
    }
    // ... rest of class unchanged ...
}
```

The `Task { @MainActor }` wrapper ensures the consume runs on the next runloop tick — guaranteeing `@Published` observers (the SwiftUI views observing `claimsAutomationStartInput`) are attached before the value flips.

`@Inject` is the property wrapper defined in `Projects/hCore/Sources/Dependencies/Dependencies.swift:49`. `hCore` is already imported in this file.

- [ ] **Step 3: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/Home/Sources/Navigation/HomeNavigation.swift
git commit -m "feat(Home): drain pending AppIntent on VM init"
```

---

## Task 9: Extend `forceLogoutHook` with `recoverInFlight`

**Files:**
- Modify: `Projects/App/Sources/AppDelegate.swift` (lines 213-228)

- [ ] **Step 1: Read current hook**

Read `Projects/App/Sources/AppDelegate.swift` lines 200-230 to confirm the current `forceLogoutHook` body.

- [ ] **Step 2: Add `recoverInFlight` call**

Modify the `forceLogoutHook` closure (current lines 213-228) to call `recoverInFlight` BEFORE the state change:

```swift
forceLogoutHook = { [weak self] in
    if ApplicationState.currentState != .notLoggedIn {
        // Preserve any in-flight AppIntent so it survives forced re-auth.
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

`Dependencies.shared.resolve()` is the codebase's imperative DI API (definition: `Projects/hCore/Sources/Dependencies/Dependencies.swift:49`; example: `AppDelegate+Tracking.swift:37`).

- [ ] **Step 3: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add Projects/App/Sources/AppDelegate.swift
git commit -m "feat(App): recover pending AppIntent before forced logout"
```

---

## Task 10: Implement `FileClaimAppIntent`

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

`log` is the global Datadog logger declared in `AppDelegate.swift:204`. `Dependencies.shared.resolve()` is the standard imperative DI lookup.

- [ ] **Step 2: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/FileClaimAppIntent.swift
git commit -m "feat(App): add FileClaimAppIntent"
```

---

## Task 11: Smoke test for `FileClaimAppIntent.perform()`

**Files:**
- Create: `Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift`

- [ ] **Step 1: Write the test**

```swift
@testable import Ugglan
import XCTest
import hCore

@MainActor
final class FileClaimAppIntentTests: XCTestCase {
    func testPerformStoresFileNewClaim() async throws {
        let stub = StubPendingAppIntentService()
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

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AppTests/FileClaimAppIntentTests 2>&1 | tail -20
```

Expected: TEST SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Tests/AppIntents/FileClaimAppIntentTests.swift
git commit -m "test(App): smoke test FileClaimAppIntent.perform"
```

---

## Task 12: Create `AppShortcuts.xcstrings`

**Files:**
- Create: `Projects/App/Sources/Resources/AppShortcuts.xcstrings`

Markets confirmed: only `sv_SE` and `en_SE` per `Projects/hCore/Sources/Localization.swift:7-10`.

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

Swedish translations are a first pass — flag them in the PR for the localization team to review.

- [ ] **Step 3: Confirm Tuist resource declaration**

Read `Projects/App/Project.swift` and find the App target's `resources:` declaration. Confirm it globs `Sources/Resources/**` (or similar). If not, add an explicit resource entry for `AppShortcuts.xcstrings`. Re-run `tuist generate`.

```bash
tuist generate
```

Expected: workspace regenerates without errors.

- [ ] **Step 4: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 5: Commit**

```bash
git add Projects/App/Sources/Resources/AppShortcuts.xcstrings Projects/App/Project.swift
git commit -m "feat(App): add AppShortcuts string catalog (EN + SV)"
```

---

## Task 13: Implement `HedvigAppShortcuts` provider

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

- [ ] **Step 2: Verify build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -20
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift
git commit -m "feat(App): add HedvigAppShortcuts provider"
```

---

## Task 14: End-to-end build + run

**Files:** none

- [ ] **Step 1: Full workspace build**

```bash
xcodebuild -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -30
```

Expected: BUILD SUCCEEDED across all targets.

- [ ] **Step 2: Full test pass**

```bash
xcodebuild test -workspace Hedvig.xcworkspace -scheme Ugglan -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -30
```

Expected: all tests PASS (specifically the new `PendingAppIntentServiceTests` and `FileClaimAppIntentTests`).

- [ ] **Step 3: Launch app, verify nothing regressed at runtime**

Open Xcode, launch the **Ugglan** scheme on an iOS 17 or iOS 18 simulator. Confirm:
- App boots normally
- Login flow works
- "Start new claim" button on Home tab still works

---

## Task 15: Manual Siri / Shortcuts verification

**Files:** none (manual checklist — record outcomes in PR description)

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
  1. Trigger token expiry (consult Authentication team for fastest path)
  2. "Hey Siri, file a claim with Hedvig"
  3. App opens, briefly shows home, then `forceLogoutHook` fires → login screen
  4. Complete login
  5. After login, app navigates to claim flow

- [ ] **Phrases appear in Shortcuts app:**
  1. After fresh install, open Shortcuts app → search "Hedvig"
  2. Confirm all 4 phrases are listed

- [ ] **Spotlight discoverability:**
  1. Pull down on home screen → search "claim"
  2. Confirm "File a claim with Hedvig" appears as a suggested action

- [ ] **Swedish locale:**
  1. Set device language to Swedish, restart app
  2. "Hej Siri, anmäl en skada med Hedvig" → app opens to claim flow
  3. Confirm Swedish phrases appear in Shortcuts app

- [ ] **iOS 17 + iOS 18 sanity:**
  1. Repeat "cold launch, logged in" on iOS 17 and iOS 18
  2. Confirm no platform-specific regressions

Record the result of each row in the PR description as ✅ / ❌.

---

## Self-Review Checklist (for the implementer)

Before opening the PR:

- [ ] All 15 tasks completed; all commits on `feature/app-intent-file-claim`
- [ ] No new SwiftLint warnings (`swiftlint` from project root)
- [ ] swift-format passes (`swift format lint -r Projects/App/Sources/AppIntents`)
- [ ] No hardcoded user-facing strings outside `AppShortcuts.xcstrings`
- [ ] No use of legacy `PresentableStore`, raw `Form`/`Section`/`Text`/`Button`, or `@Observable`
- [ ] No push to remote (user reviews local commits first per project convention)
- [ ] PR description includes the manual verification checklist with outcomes
- [ ] Localization team notified about `AppShortcuts.xcstrings` for Swedish translation review

---

## Open Items the Implementer May Need to Resolve

1. **Tuist resource declaration** — confirm `Projects/App/Project.swift` includes `Sources/Resources/**` in the App target's resources. If not, add it explicitly in Task 12 Step 3.
2. **Analytics event** — the spec calls for an analytics event when the claim flow opens via the intent. The codebase doesn't appear to expose a `track(event:)`-style API today; only the Datadog `log.info(...)` path is in use. Once the analytics convention is clarified, emit the event from `HomeNavigationViewModel`'s drain block (Task 8) or from `FileClaimAppIntent.perform()` (Task 10).
