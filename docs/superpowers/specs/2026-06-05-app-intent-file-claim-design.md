# Design: Siri AppIntent — File a New Claim

**Date:** 2026-06-05
**Status:** Approved (design); implementation plan to follow
**Scope:** iOS app only; iOS 16+

## Goal

Let members trigger the existing "Start a new claim" flow via Siri voice commands and the Shortcuts app. Example: *"Hey Siri, file a claim with Hedvig"* launches the app and lands on the same screen as tapping the in-app **Start new claim** button.

## Non-Goals

- Parameterized intents (e.g. *"file a glass damage claim"*). The intent is generic; the user picks the claim type in-app, just like tapping the in-app button.
- Voice triggers for other flows (view claims, contracts, payment). Single-intent v1.
- Interactive widgets, Control Center controls, Action Button integration. Pure Siri/Shortcuts/Spotlight surface only.
- An Intents extension target. The intent runs in-process via `openAppWhenRun = true`.

## Design

### Components

Four new types, all in the **App** target.

| Type | Path | Responsibility |
|---|---|---|
| `FileClaimAppIntent` | `Projects/App/Sources/AppIntents/FileClaimAppIntent.swift` | The intent. `openAppWhenRun = true`. `perform()` stores `.fileNewClaim` in the pending service and returns `.result()`. |
| `HedvigAppShortcuts` | `Projects/App/Sources/AppIntents/HedvigAppShortcuts.swift` | `AppShortcutsProvider` declaring localized phrases. |
| `PendingAppIntentServiceProtocol` | `Projects/App/Sources/Service/Protocols/PendingAppIntentServiceProtocol.swift` | `@MainActor` protocol: `store`, `consume`, `recoverInFlight`. |
| `PendingAppIntentServiceImpl` | `Projects/App/Sources/Service/PendingAppIntentServiceImpl.swift` | Real impl, registered in `AppDelegate+DI.swift`. |

Supporting enum:

```swift
enum PendingAppIntentAction: Equatable {
    case fileNewClaim
}
```

A `Demo` implementation is **not** needed — the service has no UI surface and isn't consumed by SwiftUI previews.

### `PendingAppIntentService` — state machine

Two slots:

- **`pending`** — `(action, timestamp)?`. Written by `perform()`. Drained by post-launch and auth-success hooks.
- **`inFlight`** — `action?`. Set when `consume()` returns the action; auto-clears 5 seconds later if nothing recovers it.

```swift
@MainActor
protocol PendingAppIntentServiceProtocol {
    func store(_ action: PendingAppIntentAction)
    func consume() -> PendingAppIntentAction?  // moves pending → inFlight
    func recoverInFlight()                     // moves inFlight → pending (fresh timestamp)
}
```

**TTLs:**
- `pending` expires after **5 minutes** — `consume()` returns `nil` past TTL.
- `inFlight` auto-clears after **5 seconds** without recovery.

Both timers driven by an injected clock for deterministic tests.

### Auth integration

Three hook points. Exact file locations are an open item for the implementation plan.

| Hook | What it does |
|---|---|
| Post-launch / scene-ready | `if authState == .loggedIn, let action = service.consume() { dispatch(action) }` |
| Auth-success (login completion) | Same `consume` + `dispatch`. Runs on every successful login — cold and re-auth. |
| Auth-expiry / forced logout (401 handler) | `service.recoverInFlight()` **before** the logout state change. |

`dispatch(action)` for `.fileNewClaim` invokes the **same call site** as the in-app *Start new claim* button. The intent layer does not duplicate any claim-start logic, eligibility checks, or no-contracts UX.

### Three runtime scenarios

**1. Logged in, stays logged in**

```
"Hey Siri, file a claim" → app launches → perform() stores .fileNewClaim
  → post-launch hook consumes → dispatch → claim screen
```

**2. Logged out at launch**

```
... perform() stores .fileNewClaim ...
  → post-launch hook: authState == .loggedOut → consume() returns action but
    it's RE-STORED into pending (TTL preserved)
  → login screen shown
  → auth-success hook fires → consume → dispatch → claim screen
```

The "re-store if not yet authed" step in the post-launch hook is required — otherwise the action is lost during the login transition.

**3. Token expires mid-session (looks logged in, kicked out a sec later)**

```
... post-launch consume succeeds, dispatch starts navigation ...
  → claim screen begins loading → GraphQL 401 → auth-expiry handler fires
  → handler calls service.recoverInFlight() (moves inFlight → pending, fresh TTL)
  → handler triggers logout → login screen
  → auth-success hook fires → consume → dispatch → claim screen
```

Strategy **3b**: the auth-expiry handler is the single touchpoint that knows to preserve the in-flight action. Screens are unaware they were launched via an intent.

### Discoverability — `AppShortcutsProvider`

Declared phrases (English; localized equivalents per market in the String Catalog):

- *"File a claim with Hedvig"*
- *"Start a Hedvig claim"*
- *"Report a claim with Hedvig"*
- *"New Hedvig claim"*

All phrases use `\(.applicationName)` (required by `AppShortcutsProvider`).

The provider also publishes:
- **System image:** `exclamationmark.bubble` (placeholder; design to confirm)
- **Short title:** *"File Claim"*

Appears automatically in the Shortcuts app and Spotlight on install — no user setup required.

### Localization

Phrases and intent metadata (`title`, `description`) are `LocalizedStringResource`, resolved at runtime from a **new String Catalog** at:

`Projects/App/Sources/Resources/AppShortcuts.xcstrings`

Initial locales: **EN, SV, NO, DK** (confirm full market list during planning).

`L10n` is not used because:
- `L10n` returns `String`, computed at runtime against the user's market selection.
- AppIntents/Shortcuts metadata is read by the **system** at install time, possibly before sign-in or market selection.
- The String Catalog approach lets iOS resolve phrases against **device locale**, which is the expected behavior.

Translation workflow: English entries land first; translation team fills in other locales via the standard `.xcstrings` workflow in Xcode.

### Tracking & logging

- **Datadog log** in `perform()`: *"AppIntent fired: fileNewClaim"*.
- **Analytics event** when navigation dispatches: e.g. `claim_flow_opened_via_app_intent`. Exact event name to match existing tracking conventions (open item for the plan).

## Error Handling

- `perform()` cannot fail meaningfully. Always returns `.result()`. If DI can't resolve the service, log and still return success — worst case the user lands on the home screen.
- `pending` TTL expiry → user lands on home screen instead of claim flow. Acceptable.
- Rapid double-trigger of the same intent → second `store` overwrites the first; idempotent.
- No user-facing intent error surfaces; Siri's error UI for soft failures is more confusing than just opening the app.

## Testing

### Unit tests — `PendingAppIntentService`

XCTest cases (using an injected clock):

- `store` → `consume` returns the action exactly once
- `consume` returns `nil` when nothing stored
- Pending action expires after 5 minutes
- `consume` moves pending → inFlight; second `consume` returns `nil`
- `recoverInFlight` moves inFlight back to pending with fresh timestamp
- `recoverInFlight` is a no-op if nothing is in flight
- inFlight auto-clears after the 5-second window

### Unit test — `FileClaimAppIntent.perform()`

Mock the service, call `perform()`, assert `.fileNewClaim` was stored. Smoke test; the body is one line.

### Manual checklist

- Cold launch via *"Hey Siri, file a claim with Hedvig"* → claim screen opens
- Same, but logged out at launch → login → claim screen
- Same, but token expires during navigation → login → claim screen
- Phrases appear in Shortcuts app after fresh install
- Spotlight surfaces the shortcut when searching *"claim"*
- Verify on iOS 17 and iOS 18
- Verify in a non-English market that translated phrases work

## Open items for the implementation plan

1. Exact file/method for the in-app *Start new claim* navigation action.
2. Exact file/method for the post-launch hook, auth-success hook, and auth-expiry handler.
3. Confirm full market list for initial localization (EN, SV, NO, DK assumed).
4. Exact tracking event name(s) to match existing conventions.
5. Confirm iOS deployment target ≥ 16.0 in the App target build settings.
