# Termination Flow Odyssey Removal — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Odyssey server-driven termination flow with a stateless client-driven flow using the new `terminationSurvey` query + `terminateContract`/`deleteContract` mutations.

**Architecture:** Survey-first flow. One query fetches all survey data + action type upfront. Client owns navigation. Single mutation fires at the end. No more FlowContext threading.

**Tech Stack:** SwiftUI, Apollo GraphQL (OctopusGraphQL), custom Router (hCoreUI), @Inject DI, async/await

**Spec:** `docs/superpowers/specs/2026-03-24-termination-odyssey-removal-design.md`

---

## File Map

### New GraphQL files (create)
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationSurvey.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminateContract.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/DeleteContract.graphql`

### Old GraphQL files (delete)
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationStartFlow.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDateNext.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDeletionNext.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationSurveyNext.graphql`
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDecomNext.graphql`

### Keep (update content + rename)
- `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationNotification.graphql` → `TerminationFlowNotification.graphql` (also inline the fragment — drop `FlowTerminationNotificationFragment` wrapper and select fields directly)

### Models (rewrite)
- `Projects/TerminateContracts/Sources/Models/TerminationFlowSurveyStepModel.swift` → rewrite to new domain models
- `Projects/TerminateContracts/Sources/Models/TerminationFlowDateNextStepModel.swift` → rewrite to keep only `ExtraCoverageItem` and `TerminationNotification` (file stays in place, no rename needed to avoid project file issues)

### Models (delete)
- `Projects/TerminateContracts/Sources/Models/TerminationFlowDeletionNextModel.swift`
- `Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoCancelModel.swift`
- `Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoDecomModel.swift`
- `Projects/TerminateContracts/Sources/Models/TerminationFlowFailedNextModel.swift`
- `Projects/TerminateContracts/Sources/Models/TerminationFlowSuccessNextModel.swift`

### Service layer (rewrite)
- `Projects/TerminateContracts/Sources/Service/Protocols/TerminateContractsClient.swift`
- `Projects/TerminateContracts/Sources/Service/TerminateContractsService.swift`
- `Projects/TerminateContracts/Sources/Service/DemoImplementation/TerminateContractsClientDemo.swift`
- `Projects/App/Sources/Service/OctopusClientsImplementation/TerminateContractsClientOctopus.swift`

### Navigation (rewrite)
- `Projects/TerminateContracts/Sources/Navigation/TerminationFlowNavigationViewModel.swift`
- `Projects/TerminateContracts/Sources/Models/TerminateInsuranceViewModel.swift`

### Views (adapt)
- `Projects/TerminateContracts/Sources/Views/TerminationSurveyScreen.swift`
- `Projects/TerminateContracts/Sources/Views/SetTerminationDateLandingScreen.swift`
- `Projects/TerminateContracts/Sources/Views/SetTerminationDate.swift`
- `Projects/TerminateContracts/Sources/Views/TerminationSummaryScreen.swift`
- `Projects/TerminateContracts/Sources/Views/ConfirmTerminationScreen.swift`
- `Projects/TerminateContracts/Sources/Views/TerminationProcessingScreen.swift`
- `Projects/TerminateContracts/Sources/Views/TerminationSelectInsuranceScreen.swift`

### Views (delete + create replacement)
- Delete: `Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoDecomScreen.swift`
- Delete: `Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoCancelScreen.swift`
- Create: `Projects/TerminateContracts/Sources/Views/TerminationDeflectScreen.swift`

### Tests (rewrite)
- `Projects/TerminateContracts/Tests/MockData.swift`
- `Projects/TerminateContracts/Tests/TerminateContractsTests.swift`
- `Projects/TerminateContracts/Tests/TerminationDateLandingScreenViewModelTests.swift`
- Delete: `Projects/TerminateContracts/Tests/TerminationDeflectAutoDecomViewModelTests.swift`

---

## Task 1: New GraphQL Operations

**Files:**
- Create: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationSurvey.graphql`
- Create: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminateContract.graphql`
- Create: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/DeleteContract.graphql`

- [ ] **Step 1: Create `TerminationSurvey.graphql`**

```graphql
query TerminationSurvey($contractId: ID!) {
  terminationSurvey(contractId: $contractId) {
    options {
      ...TerminationSurveyOptionFragment
      subOptions {
        ...TerminationSurveyOptionFragment
        subOptions {
          ...TerminationSurveyOptionFragment
          subOptions {
            ...TerminationSurveyOptionFragment
          }
        }
      }
    }
    action {
      ... on TerminationFlowActionTerminateWithDate {
        minDate
        maxDate
        extraCoverage {
          ...TerminationExtraCoverageItemFragment
        }
      }
      ... on TerminationFlowActionDeleteInsurance {
        extraCoverage {
          ...TerminationExtraCoverageItemFragment
        }
      }
    }
  }
}

fragment TerminationSurveyOptionFragment on TerminationFlowSurveyOption {
  id
  title
  feedbackRequired
  suggestion {
    ...TerminationSurveyOptionSuggestionFragment
  }
}

fragment TerminationSurveyOptionSuggestionFragment on TerminationFlowSurveyOptionSuggestion {
  type
  description
  url
}

fragment TerminationExtraCoverageItemFragment on TerminationFlowExtraCoverageItem {
  displayName
  displayValue
}
```

- [ ] **Step 2: Create `TerminateContract.graphql`**

```graphql
mutation TerminateContract($input: TerminationFlowTerminateContractInput!) {
  terminateContract(input: $input) {
    contract {
      id
    }
    userError {
      message
    }
  }
}
```

- [ ] **Step 3: Create `DeleteContract.graphql`**

```graphql
mutation DeleteContract($input: TerminationFlowDeleteContractInput!) {
  deleteContract(input: $input) {
    contract {
      id
    }
    userError {
      message
    }
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationSurvey.graphql \
       Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminateContract.graphql \
       Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/DeleteContract.graphql
git commit -m "feat: add new termination GraphQL operations (survey, terminate, delete)"
```

---

## Task 2: Delete Old Odyssey GraphQL Files

**Files:**
- Delete: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationStartFlow.graphql`
- Delete: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDateNext.graphql`
- Delete: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDeletionNext.graphql`
- Delete: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationSurveyNext.graphql`
- Delete: `Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDecomNext.graphql`

- [ ] **Step 1: Delete all 5 Odyssey GraphQL files**

```bash
rm Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationStartFlow.graphql
rm Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDateNext.graphql
rm Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDeletionNext.graphql
rm Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationSurveyNext.graphql
rm Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationDecomNext.graphql
```

- [ ] **Step 2: Update and rename notification file**

```bash
git mv Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/FlowTerminationNotification.graphql \
      Projects/hGraphQL/GraphQL/Octopus/TerminiateContracts/TerminationFlowNotification.graphql
```

Then update the file content to inline the fragment (so generated code exposes fields directly instead of via fragment accessor):

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

This removes the `FlowTerminationNotificationFragment` wrapper. The Task 5 Octopus client code accesses `.message` and `.type` directly.

- [ ] **Step 3: Run codegen to generate new Swift types**

```bash
cd Projects/Codegen && swift run
```

This generates Swift types in `Projects/hGraphQL/Sources/Derived/GraphQL/Octopus/` for the new operations. Codegen should remove stale generated files for deleted operations automatically. Verify that old generated files (e.g., `FlowTerminationStartMutation.graphql.swift`) are gone after codegen. If they persist, delete them manually from `Projects/hGraphQL/Sources/Derived/GraphQL/Octopus/Operations/Mutations/`. Expect compilation errors in `TerminateContractsClientOctopus.swift` since it still references deleted types — that's expected and fixed in Task 5.

- [ ] **Step 4: Commit**

```bash
git add -A Projects/hGraphQL/
git commit -m "chore: remove Odyssey GraphQL operations, rename notification file, run codegen"
```

---

## Task 3: New Domain Models

**Files:**
- Rewrite: `Projects/TerminateContracts/Sources/Models/TerminationFlowSurveyStepModel.swift`
- Modify: `Projects/TerminateContracts/Sources/Models/TerminationFlowDateNextStepModel.swift`
- Delete: `Projects/TerminateContracts/Sources/Models/TerminationFlowDeletionNextModel.swift`
- Delete: `Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoCancelModel.swift`
- Delete: `Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoDecomModel.swift`
- Delete: `Projects/TerminateContracts/Sources/Models/TerminationFlowFailedNextModel.swift`
- Delete: `Projects/TerminateContracts/Sources/Models/TerminationFlowSuccessNextModel.swift`

- [ ] **Step 1: Rewrite `TerminationFlowSurveyStepModel.swift` with new domain models**

Replace the entire file. New contents:

```swift
import Foundation
import hCore

public struct TerminationSurveyData: Codable, Equatable, Hashable, Sendable {
    public let options: [TerminationSurveyOption]
    public let action: TerminationAction

    public init(options: [TerminationSurveyOption], action: TerminationAction) {
        self.options = options
        self.action = action
    }
}

public struct TerminationSurveyOption: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let feedbackRequired: Bool
    public let suggestion: TerminationSuggestion?
    public let subOptions: [TerminationSurveyOption]

    public init(
        id: String,
        title: String,
        feedbackRequired: Bool,
        suggestion: TerminationSuggestion?,
        subOptions: [TerminationSurveyOption]
    ) {
        self.id = id
        self.title = title
        self.feedbackRequired = feedbackRequired
        self.suggestion = suggestion
        self.subOptions = subOptions
    }
}

public struct TerminationSuggestion: Codable, Equatable, Hashable, Sendable {
    public let type: TerminationSuggestionType
    public let description: String
    public let url: String?

    public init(type: TerminationSuggestionType, description: String, url: String?) {
        self.type = type
        self.description = description
        self.url = url
    }

    public var isBlocking: Bool {
        switch type {
        case .updateAddress, .upgradeCoverage, .downgradePrice, .redirect:
            return true
        case .info:
            return false
        case .autoCancelSold, .autoCancelScrapped, .autoDecommission,
             .carDecommissionInfo, .carAlreadyDecommission, .unknown:
            return false
        }
    }

    public var isDeflect: Bool {
        switch type {
        case .autoCancelSold, .autoCancelScrapped, .autoDecommission,
             .carDecommissionInfo, .carAlreadyDecommission:
            return true
        default:
            return false
        }
    }
}

public enum TerminationSuggestionType: String, Codable, Sendable {
    case updateAddress
    case upgradeCoverage
    case downgradePrice
    case redirect
    case info
    case autoCancelSold
    case autoCancelScrapped
    case autoDecommission
    case carDecommissionInfo
    case carAlreadyDecommission
    case unknown
}

public enum TerminationAction: Codable, Equatable, Hashable, Sendable {
    case terminateWithDate(minDate: String, maxDate: String, extraCoverage: [ExtraCoverageItem])
    case deleteInsurance(extraCoverage: [ExtraCoverageItem])
}

public enum TerminationContractResult: Equatable, Sendable {
    case success
    case userError(message: String)
}

public enum SurveyScreenSubtitleType: Codable, Sendable {
    case `default`
    case generic

    var title: String {
        switch self {
        case .default:
            return L10n.terminationSurveySubtitle
        case .generic:
            return L10n.terminationSurveyGenericSubtitle
        }
    }
}
```

- [ ] **Step 2: Clean up `TerminationFlowDateNextStepModel.swift`**

Keep `ExtraCoverageItem`, `TerminationNotification`, and `TerminationNotificationType`. Remove `TerminationFlowDateNextStepModel` and `FlowStepModel` protocol. Keep the file at its current path to avoid Tuist/project manifest issues.

```swift
import Foundation

public struct ExtraCoverageItem: Codable, Equatable, Hashable, Sendable {
    public let displayName: String
    public let displayValue: String?

    public init(displayName: String, displayValue: String?) {
        self.displayName = displayName
        self.displayValue = displayValue
    }
}

public struct TerminationNotification: Codable, Equatable, Hashable, Sendable {
    public let message: String
    public let type: TerminationNotificationType

    public init(message: String, type: TerminationNotificationType) {
        self.message = message
        self.type = type
    }
}

public enum TerminationNotificationType: String, Codable, Sendable {
    case info
    case warning
}
```

- [ ] **Step 3: Delete old model files**

```bash
rm Projects/TerminateContracts/Sources/Models/TerminationFlowDeletionNextModel.swift
rm Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoCancelModel.swift
rm Projects/TerminateContracts/Sources/Models/TerminationFlowDeflectAutoDecomModel.swift
rm Projects/TerminateContracts/Sources/Models/TerminationFlowFailedNextModel.swift
rm Projects/TerminateContracts/Sources/Models/TerminationFlowSuccessNextModel.swift
```

- [ ] **Step 4: Commit**

```bash
git add -A Projects/TerminateContracts/Sources/Models/
git commit -m "feat: replace Odyssey termination models with new domain models"
```

---

## Task 4: Rewrite Client Protocol + Service Layer

**Files:**
- Rewrite: `Projects/TerminateContracts/Sources/Service/Protocols/TerminateContractsClient.swift`
- Rewrite: `Projects/TerminateContracts/Sources/Service/TerminateContractsService.swift`
- Rewrite: `Projects/TerminateContracts/Sources/Service/DemoImplementation/TerminateContractsClientDemo.swift`

- [ ] **Step 1: Rewrite `TerminateContractsClient.swift`**

Replace the entire file:

```swift
import Foundation
import hCore

@MainActor
public protocol TerminateContractsClient {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData
    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult
    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult
    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification?
}
```

- [ ] **Step 2: Rewrite `TerminateContractsService.swift`**

```swift
import Foundation
import hCore

@MainActor
class TerminateContractsService {
    @Inject private var client: TerminateContractsClient

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        log.info("TerminateContractsService: getTerminationSurvey for contractId: \(contractId)")
        let data = try await client.getTerminationSurvey(contractId: contractId)
        log.info("TerminateContractsService: getTerminationSurvey success")
        return data
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        log.info("TerminateContractsService: terminateContract for contractId: \(contractId) date: \(terminationDate)")
        let result = try await client.terminateContract(
            contractId: contractId,
            terminationDate: terminationDate,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        log.info("TerminateContractsService: terminateContract result: \(result)")
        return result
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        log.info("TerminateContractsService: deleteContract for contractId: \(contractId)")
        let result = try await client.deleteContract(
            contractId: contractId,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        log.info("TerminateContractsService: deleteContract result: \(result)")
        return result
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        log.info("TerminateContractsService: getNotification for contractId: \(contractId)")
        let data = try await client.getNotification(contractId: contractId, date: date)
        log.info("TerminateContractsService: getNotification success: \(data?.message ?? "nil")")
        return data
    }
}
```

- [ ] **Step 3: Rewrite `TerminateContractsClientDemo.swift`**

```swift
import Foundation
import hCore

class TerminateContractsClientDemo: TerminateContractsClient {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        try await Task.sleep(nanoseconds: 500_000_000)
        return TerminationSurveyData(
            options: [
                .init(
                    id: "option1",
                    title: "I found a better price",
                    feedbackRequired: false,
                    suggestion: .init(type: .downgradePrice, description: "We can offer you a better price", url: nil),
                    subOptions: []
                ),
                .init(
                    id: "option2",
                    title: "I'm moving abroad",
                    feedbackRequired: false,
                    suggestion: nil,
                    subOptions: [
                        .init(
                            id: "subOption1",
                            title: "I'm moving to another EU country",
                            feedbackRequired: true,
                            suggestion: nil,
                            subOptions: []
                        ),
                        .init(
                            id: "subOption2",
                            title: "I'm moving outside the EU",
                            feedbackRequired: false,
                            suggestion: nil,
                            subOptions: []
                        ),
                    ]
                ),
                .init(
                    id: "option3",
                    title: "Other reason",
                    feedbackRequired: true,
                    suggestion: nil,
                    subOptions: []
                ),
            ],
            action: .terminateWithDate(
                minDate: Date().localDateString,
                maxDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())?.localDateString ?? "",
                extraCoverage: [
                    .init(displayName: "Travel insurance", displayValue: "49 kr/month"),
                ]
            )
        )
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return .success
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return .success
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return .init(message: "Your insurance will be terminated on this date.", type: .info)
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add Projects/TerminateContracts/Sources/Service/
git commit -m "feat: rewrite termination client protocol and service for new schema"
```

---

## Task 5: Rewrite Octopus Client Implementation

**Files:**
- Rewrite: `Projects/App/Sources/Service/OctopusClientsImplementation/TerminateContractsClientOctopus.swift`

- [ ] **Step 1: Rewrite `TerminateContractsClientOctopus.swift`**

Replace the entire file. The new implementation has 4 methods — no FlowContext, no step routing, no Into protocol.

```swift
import Foundation
import TerminateContracts
import hCore
import hGraphQL

class TerminateContractsClientOctopus: TerminateContractsClient {
    @Inject private var octopus: hOctopus

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        let query = OctopusGraphQL.TerminationSurveyQuery(contractId: contractId)
        let data = try await octopus.client.fetch(query: query)
        return data.terminationSurvey.asTerminationSurveyData
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        let input = OctopusGraphQL.TerminationFlowTerminateContractInput(
            contractId: contractId,
            terminationDate: terminationDate,
            terminationSurveyOptionId: surveyOptionId,
            terminationComment: GraphQLNullable(optionalValue: comment)
        )
        let mutation = OctopusGraphQL.TerminateContractMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)!
        if let errorMessage = data.terminateContract.userError?.message {
            return .userError(message: errorMessage)
        }
        return .success
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        let input = OctopusGraphQL.TerminationFlowDeleteContractInput(
            contractId: contractId,
            terminationSurveyOptionId: surveyOptionId,
            terminationComment: GraphQLNullable(optionalValue: comment)
        )
        let mutation = OctopusGraphQL.DeleteContractMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)!
        if let errorMessage = data.deleteContract.userError?.message {
            return .userError(message: errorMessage)
        }
        return .success
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        let input = OctopusGraphQL.TerminationFlowNotificationInput(
            contractId: contractId,
            terminationDate: date.localDateString
        )
        let query = OctopusGraphQL.TerminationFlowNotificationQuery(input: input)
        let data = try await octopus.client.fetch(query: query)
        guard let notification = data.currentMember.terminationFlowNotification else { return nil }
        return .init(
            message: notification.message,
            type: notification.type == .case(.warning) ? .warning : .info
        )
    }
}

// MARK: - GraphQL → Domain Mapping

extension OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey {
    var asTerminationSurveyData: TerminationSurveyData {
        .init(
            options: options.map { $0.asTerminationSurveyOption },
            action: action.asTerminationAction
        )
    }
}

extension OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey.Option {
    var asTerminationSurveyOption: TerminationSurveyOption {
        let fragment = fragments.terminationSurveyOptionFragment
        return .init(
            id: fragment.id,
            title: fragment.title,
            feedbackRequired: fragment.feedbackRequired,
            suggestion: fragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
            subOptions: subOptions.map { subOption in
                let subFragment = subOption.fragments.terminationSurveyOptionFragment
                return .init(
                    id: subFragment.id,
                    title: subFragment.title,
                    feedbackRequired: subFragment.feedbackRequired,
                    suggestion: subFragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
                    subOptions: subOption.subOptions.map { subSubOption in
                        let subSubFragment = subSubOption.fragments.terminationSurveyOptionFragment
                        return .init(
                            id: subSubFragment.id,
                            title: subSubFragment.title,
                            feedbackRequired: subSubFragment.feedbackRequired,
                            suggestion: subSubFragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
                            subOptions: subSubOption.subOptions.map { leaf in
                                let leafFragment = leaf.fragments.terminationSurveyOptionFragment
                                return .init(
                                    id: leafFragment.id,
                                    title: leafFragment.title,
                                    feedbackRequired: leafFragment.feedbackRequired,
                                    suggestion: leafFragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
                                    subOptions: []
                                )
                            }
                        )
                    }
                )
            }
        )
    }
}

extension OctopusGraphQL.TerminationSurveyOptionSuggestionFragment {
    var asSuggestion: TerminationSuggestion {
        .init(
            type: type.asTerminationSuggestionType,
            description: description,
            url: url
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionSuggestionType> {
    var asTerminationSuggestionType: TerminationSuggestionType {
        switch self {
        case .case(.updateAddress): return .updateAddress
        case .case(.upgradeCoverage): return .upgradeCoverage
        case .case(.downgradePrice): return .downgradePrice
        case .case(.redirect): return .redirect
        case .case(.info): return .info
        case .case(.autoCancelSold): return .autoCancelSold
        case .case(.autoCancelScrapped): return .autoCancelScrapped
        case .case(.autoDecommission): return .autoDecommission
        case .case(.carDecommissionInfo): return .carDecommissionInfo
        case .case(.carAlreadyDecommission): return .carAlreadyDecommission
        default: return .unknown
        }
    }
}

extension OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey.Action {
    var asTerminationAction: TerminationAction {
        if let terminateWithDate = asTerminationFlowActionTerminateWithDate {
            return .terminateWithDate(
                minDate: terminateWithDate.minDate,
                maxDate: terminateWithDate.maxDate,
                extraCoverage: terminateWithDate.extraCoverage.map {
                    .init(displayName: $0.fragments.terminationExtraCoverageItemFragment.displayName,
                          displayValue: $0.fragments.terminationExtraCoverageItemFragment.displayValue)
                }
            )
        } else if let deleteInsurance = asTerminationFlowActionDeleteInsurance {
            return .deleteInsurance(
                extraCoverage: deleteInsurance.extraCoverage.map {
                    .init(displayName: $0.fragments.terminationExtraCoverageItemFragment.displayName,
                          displayValue: $0.fragments.terminationExtraCoverageItemFragment.displayValue)
                }
            )
        }
        return .deleteInsurance(extraCoverage: [])
    }
}
```

**Important note:** The exact generated type names (e.g., `OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey.Option`) depend on codegen output from Task 2 Step 3. After codegen runs, check the generated files in `Projects/hGraphQL/Sources/Derived/GraphQL/Octopus/` to verify the type paths. Adjust the extension target types accordingly.

- [ ] **Step 2: Verify it compiles**

The App project must compile. If codegen produced different type names, adjust the extensions above to match.

- [ ] **Step 3: Commit**

```bash
git add Projects/App/Sources/Service/OctopusClientsImplementation/TerminateContractsClientOctopus.swift
git commit -m "feat: rewrite Octopus client for new termination schema"
```

---

## Task 6: Rewrite Navigation ViewModel + Entry Point

**Files:**
- Rewrite: `Projects/TerminateContracts/Sources/Navigation/TerminationFlowNavigationViewModel.swift`
- Rewrite: `Projects/TerminateContracts/Sources/Models/TerminateInsuranceViewModel.swift`

This is the largest task — it rewrites the core flow orchestration. The key changes:
- Single init (configs-based), no more TerminateStepResponse init
- Survey data fetched inside the flow, not before creating the nav VM
- Client-side progress tracking
- `proceedAfterSurvey()` method for routing after survey completion
- Simplified redirect handler
- No more FlowContext, TerminationStepHandler, or server-step routing

- [ ] **Step 1: Rewrite `TerminateInsuranceViewModel.swift`**

```swift
import ChangeTier
import Combine
import Foundation

@MainActor
public class TerminateInsuranceViewModel: ObservableObject {
    @Published var flowNavigationVm: TerminationFlowNavigationViewModel?
    @Published var changeTierInput: ChangeTierInput?
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) {
        flowNavigationVm = TerminationFlowNavigationViewModel(
            configs: configs,
            terminateInsuranceViewModel: self
        )
    }
}
```

- [ ] **Step 2: Rewrite `TerminationFlowNavigationViewModel.swift`**

This file is large. Rewrite it completely. Key structure:

1. `TerminationRedirectHandler` — simplified, accepts `TerminationSuggestion` instead of old action type
2. `TerminationFlowNavigationViewModel` — single init, holds survey data, client-side progress, `proceedAfterSurvey()`
3. `TerminationFlowNavigation` — SwiftUI view with RouterHost, routerDestination for new action enums
4. Router action enums — new shapes per spec
5. Tracking extensions

The navigation VM must:
- On init with single config, auto-fetch survey
- Store: `surveyData`, `selectedOptionId`, `comment`, `selectedDate`, `config`
- Expose: `proceedAfterSurvey(optionId:comment:)` which reads `surveyData.action` to push datePicker or confirmation
- Expose: `submitTermination()` which calls `terminateContract` or `deleteContract` based on action
- Progress: computed from step position using the table in the spec

**`TerminationRedirectHandler` rewrite:** The existing class (defined in this same file) is kept but simplified. Change its `handle()` method to accept a `TerminationSuggestion` instead of `FlowTerminationSurveyRedirectAction?`. Mapping:
- `.updateAddress` → same as current `handleUpdateAddress()` (dismiss + deep-link to move contract)
- `.upgradeCoverage` → same as current `handleChangeTier(.betterCoverage)` (fetch ChangeTier intent, dismiss, present ChangeTier)
- `.downgradePrice` → same as current `handleChangeTier(.betterPrice)`
- `.redirect` → dismiss + open `suggestion.url` via deep link
- Other types are handled by the deflect screen, not the redirect handler

**Note:** `TerminationStepHandler` (also defined in this file) is deleted entirely — its server-step routing is no longer needed.

Refer to the spec at `docs/superpowers/specs/2026-03-24-termination-odyssey-removal-design.md` sections "Entry Point Changes", "Navigation Structure", "Survey Screen Continue Logic", "Deflect Screen Routing", and "Progress Tracking" for the exact behavior.

- [ ] **Step 3: Verify it compiles**

Many views reference the nav VM's published properties. Expect compile errors in views that will be adapted in Tasks 7-9. That's expected — just confirm the nav VM + entry point compile in isolation.

- [ ] **Step 4: Commit**

```bash
git add Projects/TerminateContracts/Sources/Navigation/TerminationFlowNavigationViewModel.swift \
       Projects/TerminateContracts/Sources/Models/TerminateInsuranceViewModel.swift
git commit -m "feat: rewrite termination nav VM and entry point for client-driven flow"
```

---

## Task 7: Adapt Survey Screen

**Files:**
- Modify: `Projects/TerminateContracts/Sources/Views/TerminationSurveyScreen.swift`

- [ ] **Step 1: Rewrite `TerminationSurveyScreen` and `SurveyScreenViewModel`**

Key changes:
- `SurveyScreenViewModel` takes `[TerminationSurveyOption]` instead of `[TerminationFlowSurveyStepModelOption]`
- `feedbackRequired` is now a `Bool` on the option instead of a separate `TerminationFlowSurveyStepFeedback` object
- `continueClicked()` no longer calls `submitSurvey` — instead:
  - If subOptions exist → push new survey screen
  - If selected option has a deflect suggestion → push deflect screen via navVM
  - If selected option has a blocking suggestion → handle redirect via navVM
  - Otherwise → call `navVM.proceedAfterSurvey(optionId:comment:)`
- Feedback text view shown when `feedbackRequired == true` for selected option
- 10-character minimum validation retained
- Remove all `terminationContext` / `FlowContext` references

- [ ] **Step 2: Commit**

```bash
git add Projects/TerminateContracts/Sources/Views/TerminationSurveyScreen.swift
git commit -m "feat: adapt survey screen for client-driven flow"
```

---

## Task 8: Adapt Date Picker + Summary + Confirmation Screens

**Files:**
- Modify: `Projects/TerminateContracts/Sources/Views/SetTerminationDateLandingScreen.swift`
- Modify: `Projects/TerminateContracts/Sources/Views/SetTerminationDate.swift`
- Modify: `Projects/TerminateContracts/Sources/Views/TerminationSummaryScreen.swift`
- Modify: `Projects/TerminateContracts/Sources/Views/ConfirmTerminationScreen.swift`
- Modify: `Projects/TerminateContracts/Sources/Views/TerminationProcessingScreen.swift`

- [ ] **Step 1: Adapt `SetTerminationDateLandingScreen`**

Key changes:
- No longer reads `terminationDeleteStepModel` / `terminationDateStepModel` from nav VM
- Instead reads `navVM.surveyData.action` to determine if deletion or date-based
- Date range (minDate/maxDate) comes from the action's associated values
- Deletion case shows "Today" with lock icon (same as current)
- Date case shows date picker dropdown (same as current)
- `isDeletion` computed from action type, not from separate step models

- [ ] **Step 2: Adapt `SetTerminationDate`**

Key changes:
- Min/max date comes from nav VM's `surveyData.action` associated values instead of `terminationDateStepModel`
- Selected date stored in `navVM.selectedDate`

- [ ] **Step 3: Adapt `TerminationSummaryScreen`**

Key changes:
- Reads contract info from `navVM.config`
- Reads extra coverage from `navVM.surveyData.action` associated values
- Reads selected date from `navVM.selectedDate`
- Shows notification from `navVM.notification`
- "Terminate" button triggers `navVM.isConfirmTerminationPresented = true`

- [ ] **Step 4: Adapt `ConfirmTerminationScreen`**

Key changes:
- On confirm, calls `navVM.submitTermination()` which handles the mutation call

- [ ] **Step 5: Adapt `TerminationProcessingScreen`**

Minimal changes — just update references to nav VM properties if needed.

- [ ] **Step 6: Commit**

```bash
git add Projects/TerminateContracts/Sources/Views/SetTerminationDateLandingScreen.swift \
       Projects/TerminateContracts/Sources/Views/SetTerminationDate.swift \
       Projects/TerminateContracts/Sources/Views/TerminationSummaryScreen.swift \
       Projects/TerminateContracts/Sources/Views/ConfirmTerminationScreen.swift \
       Projects/TerminateContracts/Sources/Views/TerminationProcessingScreen.swift
git commit -m "feat: adapt date/summary/confirmation screens for new flow"
```

---

## Task 9: Unified Deflect Screen + Select Insurance Screen

**Files:**
- Delete: `Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoDecomScreen.swift`
- Delete: `Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoCancelScreen.swift`
- Create: `Projects/TerminateContracts/Sources/Views/TerminationDeflectScreen.swift`
- Modify: `Projects/TerminateContracts/Sources/Views/TerminationSelectInsuranceScreen.swift`

- [ ] **Step 1: Delete old deflect screens**

```bash
rm Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoDecomScreen.swift
rm Projects/TerminateContracts/Sources/Views/TerminationDeflectAutoCancelScreen.swift
```

- [ ] **Step 2: Create unified `TerminationDeflectScreen.swift`**

The unified screen receives a `TerminationSuggestion` and displays:
- Title based on suggestion type
- Description text from the suggestion
- Optional URL link
- "Continue anyway" button that calls `navVM.proceedAfterSurvey()` (which reads the stored action to route to date picker or confirmation)
- "Go back" button

- [ ] **Step 3: Adapt `TerminationSelectInsuranceScreen`**

Key changes:
- On selection, instead of calling `vm.startTermination(config:fromSelectInsurance:)`, call `vm.fetchSurvey(for: config)` which fetches the survey and pushes to the survey screen
- Remove the server-driven progress calculation

- [ ] **Step 4: Commit**

```bash
git add -A Projects/TerminateContracts/Sources/Views/
git commit -m "feat: unify deflect screens, adapt select insurance for new flow"
```

---

## Task 10: Clean Up Remaining References

**Files:**
- Modify: `Projects/TerminateContracts/Sources/Views/Termination+modifier.swift`
- Modify: `Projects/TerminateContracts/Sources/Helpers/View+hide.swift`
- Verify: `Projects/App/Sources/AppDelegate+DI.swift` — DI registration should still work since the protocol name hasn't changed

- [ ] **Step 1: Verify `Termination+modifier.swift` still works**

This file creates the `TerminateInsuranceViewModel` and presents the flow modally. Since `start(with:)` no longer throws (it doesn't make a network call anymore), update the call site if needed.

- [ ] **Step 2: Verify DI registration in `AppDelegate+DI.swift`**

The registration still uses `TerminateContractsClient` protocol name. Just verify it compiles.

- [ ] **Step 3: Full project build**

Build the entire project to find any remaining compile errors from old type references.

```bash
# Use Xcode or tuist build command as appropriate
```

Fix any remaining references to deleted types.

- [ ] **Step 4: Commit any remaining fixes**

```bash
git add -A
git commit -m "chore: fix remaining references after Odyssey removal"
```

---

## Task 11: Rewrite Tests

**Files:**
- Rewrite: `Projects/TerminateContracts/Tests/MockData.swift`
- Rewrite: `Projects/TerminateContracts/Tests/TerminateContractsTests.swift`
- Rewrite: `Projects/TerminateContracts/Tests/TerminationDateLandingScreenViewModelTests.swift`
- Delete: `Projects/TerminateContracts/Tests/TerminationDeflectAutoDecomViewModelTests.swift`

- [ ] **Step 1: Delete old deflect test file**

```bash
rm Projects/TerminateContracts/Tests/TerminationDeflectAutoDecomViewModelTests.swift
```

- [ ] **Step 2: Rewrite `MockData.swift`**

Create mock `TerminationSurveyData` fixtures covering:
- Options with various suggestion types (blocking, deflect, info)
- Options with subOptions (nested)
- Options with feedbackRequired
- Both action types: `terminateWithDate` and `deleteInsurance`
- Mock `TerminateContractsClient` implementation for tests

- [ ] **Step 3: Rewrite `TerminateContractsTests.swift`**

New tests:
- `testGetTerminationSurvey_success` — mock client returns survey data
- `testGetTerminationSurvey_error` — mock client throws
- `testTerminateContract_success` — returns `.success`
- `testTerminateContract_userError` — returns `.userError(message:)`
- `testDeleteContract_success` — returns `.success`
- `testDeleteContract_userError` — returns `.userError(message:)`

- [ ] **Step 4: Rewrite `TerminationDateLandingScreenViewModelTests.swift`**

Adapt to new nav VM API — tests should verify:
- Deletion action shows "Today" field, disabled date picker
- TerminateWithDate action shows date picker with min/max
- Continue button disabled until date selected + terms agreed (for date flow)

- [ ] **Step 5: Add nav VM routing tests**

Test `proceedAfterSurvey()` branching:
- With `terminateWithDate` action → verify router pushes date picker
- With `deleteInsurance` action → verify router pushes confirmation
- Test `submitTermination()` calls correct mutation based on action type

- [ ] **Step 6: Run tests**

```bash
# Run TerminateContracts tests
```

- [ ] **Step 7: Commit**

```bash
git add -A Projects/TerminateContracts/Tests/
git commit -m "feat: rewrite termination tests for new schema"
```

---

## Task 12: Final Verification

- [ ] **Step 1: Full project build — verify zero errors**
- [ ] **Step 2: Run all TerminateContracts tests — verify all pass**
- [ ] **Step 3: Verify no remaining references to deleted Odyssey types**

Search for any remaining references:

```
FlowTerminationStart
FlowTerminationDateNext
FlowTerminationDeletionNext
FlowTerminationSurveyNext
FlowTerminationCarAutoDecom
FlowContext (in termination files)
TerminateStepResponse
TerminationContractStep
TerminationStepHandler
FlowStepModel
```

- [ ] **Step 4: Final commit if any cleanup needed**
