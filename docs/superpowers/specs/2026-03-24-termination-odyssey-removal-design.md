# Termination Flow: Odyssey Removal & New Schema Migration

**Date:** 2026-03-24
**Branch:** `eng/removing-odyssey`
**Reference:** Android PR [#2885](https://github.com/HedvigInsurance/android/pull/2885)

## Overview

Migrate the iOS termination flow from the Odyssey server-driven state machine to the new client-driven schema. The new API is stateless: one query fetches survey data upfront, and a single mutation executes the termination or deletion. No more `FlowContext` threading or step-by-step server round-trips.

## New GraphQL Schema (from staging introspection)

### 1. `TerminationSurvey.graphql` — Query

```graphql
query TerminationSurvey($contractId: ID!) {
  terminationSurvey(contractId: $contractId) {
    options {
      id
      title
      feedbackRequired
      subOptions {
        id
        title
        feedbackRequired
        suggestion { ...TerminationSurveyOptionSuggestionFragment }
      }
      suggestion { ...TerminationSurveyOptionSuggestionFragment }
    }
    action {
      ... on TerminationFlowActionTerminateWithDate {
        minDate
        maxDate
        extraCoverage { displayName, displayValue }
      }
      ... on TerminationFlowActionDeleteInsurance {
        extraCoverage { displayName, displayValue }
      }
    }
  }
}

fragment TerminationSurveyOptionSuggestionFragment on TerminationFlowSurveyOptionSuggestion {
  type
  description
  url
}
```

### 2. `TerminateContract.graphql` — Mutation (date-based termination)

```graphql
mutation TerminateContract($input: TerminationFlowTerminateContractInput!) {
  terminateContract(input: $input) {
    contract { id }
    userError { message }
  }
}
```

**Input:** `contractId: ID!`, `terminationDate: Date!`, `terminationSurveyOptionId: ID!`, `terminationComment: String?`

### 3. `DeleteContract.graphql` — Mutation (immediate deletion)

```graphql
mutation DeleteContract($input: TerminationFlowDeleteContractInput!) {
  deleteContract(input: $input) {
    contract { id }
    userError { message }
  }
}
```

**Input:** `contractId: ID!`, `terminationSurveyOptionId: ID!`, `terminationComment: String?`

### 4. `TerminationFlowNotification.graphql` — Query (updated input)

```graphql
query TerminationFlowNotification($input: TerminationFlowNotificationInput!) {
  currentMember {
    terminationFlowNotification(input: $input) {
      message
      type
    }
  }
}
```

**Input:** `contractId: ID!`, `terminationDate: Date!`
**NotificationType enum:** `INFO`, `WARNING`

### Suggestion Type Enum

`TerminationFlowSurveyOptionSuggestionType`:
- `UPDATE_ADDRESS`
- `UPGRADE_COVERAGE`
- `DOWNGRADE_PRICE`
- `REDIRECT`
- `INFO`
- `AUTO_CANCEL_SOLD`
- `AUTO_CANCEL_SCRAPPED`
- `AUTO_DECOMMISSION`
- `CAR_DECOMMISSION_INFO`
- `CAR_ALREADY_DECOMMISSION`

## End-to-End Flow (survey-first)

```
User taps "Cancel Insurance"
  → [Multi-contract?] → Select Insurance Screen
  → Survey Screen (fetches terminationSurvey query)
      → User picks reason
      → [Has subOptions?] → Push new survey screen with subOptions
      → [Has suggestion?] → Handle deflection (see Suggestion Handling)
      → [No blocking suggestion] → Continue
  → [TerminateWithDate action] → Date Picker Screen (minDate/maxDate)
      → Fetch notification for selected date
      → Confirmation Screen (date + extra coverage + notification)
      → terminateContract mutation
  → [DeleteInsurance action] → Confirmation Screen (extra coverage)
      → deleteContract mutation
  → [Success] → Success Screen
  → [userError] → Show error
```

## Suggestion Handling

| Suggestion Type | Behavior | Blocks Continue? |
|----------------|----------|:---:|
| `UPDATE_ADDRESS` | Redirect to address change flow | Yes |
| `UPGRADE_COVERAGE` | Redirect to ChangeTier flow | Yes |
| `DOWNGRADE_PRICE` | Redirect to ChangeTier flow | Yes |
| `REDIRECT` | Open URL | Yes |
| `INFO` | Show description inline | No |
| `AUTO_CANCEL_SOLD` | Push unified deflect screen | N/A (navigates away) |
| `AUTO_CANCEL_SCRAPPED` | Push unified deflect screen | N/A (navigates away) |
| `AUTO_DECOMMISSION` | Push unified deflect screen | N/A (navigates away) |
| `CAR_DECOMMISSION_INFO` | Push unified deflect screen | N/A (navigates away) |
| `CAR_ALREADY_DECOMMISSION` | Push unified deflect screen | N/A (navigates away) |

The unified `TerminationDeflectScreen` replaces both `TerminationDeflectAutoDecomScreen` and `TerminationDeflectAutoCancelScreen`. It receives the suggestion type, description, and optional URL, and offers "Continue anyway" to proceed to date picker or confirmation.

## Client Protocol

```swift
@MainActor
public protocol TerminateContractsClient {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData
    func terminateContract(
        contractId: String, terminationDate: String,
        surveyOptionId: String, comment: String?
    ) async throws -> TerminationContractResult
    func deleteContract(
        contractId: String, surveyOptionId: String, comment: String?
    ) async throws -> TerminationContractResult
    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification?
}
```

Replaces the current 5-method protocol that threads `FlowContext` through every call.

## Domain Models

- **`TerminationSurveyData`** — options: `[TerminationSurveyOption]`, action: `TerminationAction`
- **`TerminationSurveyOption`** — id, title, feedbackRequired: Bool, suggestion: `TerminationSuggestion?`, subOptions: `[TerminationSurveyOption]`
- **`TerminationSuggestion`** — type: `TerminationSuggestionType` (enum), description: String, url: String?
- **`TerminationAction`** — enum: `.terminateWithDate(minDate, maxDate, extraCoverage)` | `.deleteInsurance(extraCoverage)`
- **`ExtraCoverageItem`** — displayName: String, displayValue: String?
- **`TerminationContractResult`** — success or userError(message)
- **`TerminationNotification`** — message: String, type: `.info` | `.warning`

## Navigation Structure

**NavigationViewModel:** `TerminationFlowNavigationViewModel` (rewrite)
- Holds `Router` instance
- Stores client-side flow state: contractId, surveyData, selectedOptionId, comment, selectedDate
- Progress calculated client-side based on step position

**Router Actions:**
```swift
enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case survey(options: [TerminationSurveyOption])
    case datePicker(minDate: Date, maxDate: Date)
    case deflect(suggestion: TerminationSuggestion)
    case confirmation
}

enum TerminationFlowFinalRouterActions: Hashable {
    case success(isDeletion: Bool, terminationDate: String?)
    case failure(message: String)
    // Note: `fail` renamed to `failure`, `updateApp` removed.
    // Update pattern-match sites in TerminationFlowNavigation (getView and routerDestination).
}
```

## Screen Mapping

| Screen | Existing file | Change |
|--------|--------------|--------|
| Select Insurance | `TerminationSelectInsuranceScreen` | Keep mostly as-is |
| Survey | `TerminationSurveyScreen` | Adapt — no server round-trip on continue, push subOptions client-side |
| Date Picker | `SetTerminationDateLandingScreen` / `SetTerminationDate` | Adapt — receives min/max from survey action |
| Confirmation | `TerminationSummaryScreen` + `ConfirmTerminationScreen` | Merge — shows date/deletion info, extra coverage, notification, fires mutation |
| Processing | `TerminationProcessingScreen` | Keep — shown while mutation runs |
| Success | Existing success handling | Simplify |
| Deflect | `TerminationDeflectAutoDecomScreen` + `TerminationDeflectAutoCancelScreen` | Unify into `TerminationDeflectScreen` |

## Service Layer

- **`TerminateContractsClientOctopus`** — rewrite with 4 methods, no FlowContext
- **`TerminateContractsClientDemo`** — rewrite with hardcoded survey data + delays
- **`TerminateContractsService`** — keep same wrapper pattern (`@Inject`, `@Log`)
- **DI** (`AppDelegate+DI.swift`) — same registration, just updated implementation

## Files to Delete

### GraphQL (Odyssey operations)
- `TerminationStartFlow.graphql` (contains all old fragments)
- `FlowTerminationDateNext.graphql`
- `FlowTerminationDeletionNext.graphql`
- `FlowTerminationSurveyNext.graphql`
- `FlowTerminationDecomNext.graphql`

### Code
- `TerminationStepHandler.swift` — server-step routing no longer needed
- Old models tied to FlowContext / step responses (TerminateStepResponse, TerminationContractStep, etc.)
- `TerminationDeflectAutoDecomScreen.swift` — replaced by unified deflect screen
- `TerminationDeflectAutoCancelScreen.swift` — replaced by unified deflect screen
- `FlowTerminationOfferStep`-related code — no equivalent in new schema

## Entry Point Changes

The external entry points (`ContractsNavigation`, `LoggedInNavigation+Presentations`, `handleTerminateInsurance()` modifier) remain unchanged — they still create a `TerminateInsuranceViewModel` and pass `[TerminationConfirmConfig]`.

**`TerminateInsuranceViewModel.start()` rewrite:**

The current implementation has two paths: multi-contract (creates nav VM with configs) and single-contract (calls `startTermination` to get a `TerminateStepResponse`, then creates nav VM from that response). The `TerminateStepResponse`-based init is deleted entirely.

New behavior:
- **Multi-contract (>1 config):** Create nav VM with configs → show select insurance screen → on selection, fetch survey for that contract
- **Single contract (1 config):** Create nav VM with the single config's contractId → nav VM fetches survey on init → show survey screen directly

The `TerminationFlowNavigationViewModel` now has a single simplified init:
```swift
init(configs: [TerminationConfirmConfig], terminateInsuranceViewModel: TerminateInsuranceViewModel?)
```
For single-contract, the nav VM detects `configs.count == 1`, sets `contractId` from the first config, and triggers `fetchSurvey()` automatically. The initial step is `.survey` (loading state until data arrives) instead of the old pattern of calling `startTermination` before creating the nav VM.

## Survey Screen Continue Logic

The current `continueClicked()` calls `submitSurvey` (a server round-trip). This is replaced with purely client-side navigation:

```
continueClicked():
  if selectedOption has subOptions:
    → push new survey screen with subOptions (same as today)
  else if selectedOption has suggestion:
    → handle suggestion (see below)
  else:
    → call navVM.proceedAfterSurvey(optionId, comment)

navVM.proceedAfterSurvey(optionId, comment):
  store selectedOptionId + comment
  switch action:
    case .terminateWithDate: → push datePicker screen
    case .deleteInsurance: → push confirmation screen
```

**Suggestion handling in survey continue:**

| Suggestion Type | On continue |
|----------------|------------|
| `UPDATE_ADDRESS` | Dismiss flow, deep-link to address change (same as current `TerminationRedirectHandler.handleUpdateAddress`) |
| `UPGRADE_COVERAGE` | Fetch ChangeTier intent, dismiss flow, present ChangeTier (same as current `handleChangeTier` with `.betterCoverage`) |
| `DOWNGRADE_PRICE` | Fetch ChangeTier intent, dismiss flow, present ChangeTier (same as current `handleChangeTier` with `.betterPrice`) |
| `REDIRECT` | Dismiss flow, open suggestion URL via deep link |
| `INFO` | Show description inline, allow continue (non-blocking) |
| `AUTO_*` / `CAR_*` | Push unified deflect screen |

The `TerminationRedirectHandler` class is kept but simplified — it no longer needs `FlowContext`. Its `handle()` method is refactored to accept a `TerminationSuggestion` instead of `FlowTerminationSurveyRedirectAction`.

**Feedback validation:** The existing 10-character minimum for required feedback text is retained. When `feedbackRequired` is true and the user's comment is fewer than 10 characters, the continue button remains disabled.

## Deflect Screen Routing

The `TerminationDeflectScreen` "Continue anyway" must know whether to push date picker or confirmation. The router action carries the action type:

```swift
case deflect(suggestion: TerminationSuggestion, action: TerminationAction)
```

On "Continue anyway", the deflect screen calls `navVM.proceedAfterSurvey()` which reads the stored `action` to route to either `.datePicker` or `.confirmation`.

## Progress Tracking

Client-side progress based on step count:

| Step | Progress (no select insurance) | Progress (with select insurance) |
|------|:---:|:---:|
| Select Insurance | — | 0.0 |
| Survey (root) | 0.0 | 0.25 |
| Survey (sub-options, each level) | +0.1 per level | +0.075 per level |
| Date Picker | 0.5 | 0.625 |
| Confirmation | 0.75 | 0.8125 |
| Success/Failure | 1.0 | 1.0 |

This replaces the server-driven `clearedSteps / totalSteps` calculation. The existing `+0.2` hardcoded increment and scaling formula in `TerminationSurveyScreen.continueClicked()` are removed entirely — progress values come directly from this table.

## Notification Query

The existing `FlowTerminationNotification.graphql` and its client implementation already use `TerminationFlowNotificationInput(contractId:, terminationDate:)` — this file and the `getNotification` client method need only minor cleanup (rename file to match convention), no functional changes.

## `updateApp` Case

The `TerminationFlowFinalRouterActions.updateApp` case is removed. The new schema does not return an "update app" step — the server always returns a known action type (`TerminateWithDate` or `DeleteInsurance`). If the server adds new action union members in the future, the client handles unknown types with a generic error screen.

## Tests

### Tests to delete:
- All tests referencing `startTermination`, `sendTerminationDate`, `sendConfirmDelete`, `sendSurvey`, `sendContinueAfterDecom`
- `TerminationDeflectAutoDecomViewModelTests` — method under test is deleted
- Current `MockData.swift` mock responses tied to `TerminateStepResponse`

### New tests required:
- **Service layer:** `getTerminationSurvey` success/error, `terminateContract` success/userError, `deleteContract` success/userError
- **Survey VM:** option selection, sub-option navigation, feedback validation, suggestion blocking
- **Nav VM:** routing from survey action type (terminateWithDate → date picker, deleteInsurance → confirmation), `proceedAfterSurvey` branching
- **Mock data:** New `MockData` with `TerminationSurveyData` fixtures (options with suggestions, subOptions, both action types)
