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
public protocol TerminateContractsClient: Sendable {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData
    func terminateContract(
        contractId: String, terminationDate: String,
        surveyOptionId: String, comment: String?
    ) async throws -> TerminationContractResult
    func deleteContract(
        contractId: String, surveyOptionId: String, comment: String?
    ) async throws -> TerminationContractResult
    func getNotification(contractId: String, date: String) async throws -> TerminationNotification?
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
    case success(terminationDate: String?)
    case failure(message: String)
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

## Entry Points (unchanged)

- `ContractsNavigation` → `TerminationConfirmConfig` → modal presentation
- `LoggedInNavigation+Presentations` → `handleTerminateInsurance()` modifier
- `TerminateInsuranceViewModel` as entry point
