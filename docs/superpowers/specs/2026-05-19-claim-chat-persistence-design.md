# Claim Chat Persistence & Replay — Design Spec

**Date:** 2026-05-19
**Module:** SubmitClaimChat
**Status:** Approved for implementation planning

## Goal

Let users resume an unfinished claim submission flow across app launches.
The current `SubmitClaimChatViewModel` calls `startClaimIntent` on init and
holds the chain of `ClaimIntentStepHandler`s entirely in memory; closing the
app discards all progress.

This spec covers a client-side persistence + backend-replay approach
("option C" from the design discussion): the step-handler chain is persisted
to disk after every successful step, and on resume a fresh `claimIntent` is
started and each saved user input is re-submitted in order to recover state.

A future option (B) will add a server-side resume endpoint that supersedes
the replay logic; this spec is intentionally structured so that the replay
machinery can be swapped out without changing the persistence DTOs or the
resume UX.

## Non-goals

- Server-side state recovery (deferred to option B).
- Replaying audio and file-upload steps. Local file references and signed
  upload URIs do not survive across launches reliably; replay stops at the
  first such step and the user redoes the upload manually.
- Multiple parallel drafts (e.g. one per entry point). One draft per user,
  total. A new claim flow overwrites any prior draft.
- Persisting in-progress edits (form values the user typed but didn't
  submit). Only state at step-completion boundaries is persisted.
- Migrating older schema versions on load. A schema version mismatch wipes
  the draft.
- Encryption beyond iOS Data Protection defaults.

## Requirements

| # | Requirement |
|---|---|
| R1 | Save the step-handler chain after every successful step (`.goToNext`, `.regret`). |
| R2 | On launch, if a non-expired draft exists, prompt the user "Continue previous claim?" before starting the flow. |
| R3 | On resume, replay saved inputs in order against a fresh `claimIntent` via the live `ClaimIntentService`. |
| R4 | Stop replay at the first audio or file-upload step; let the user complete it manually. |
| R5 | One draft per user. New flows overwrite prior drafts. |
| R6 | Drafts expire after 7 days. |
| R7 | Clear the draft when: outcome reached, user picks "Start over", or TTL expired on load. |
| R8 | Mid-replay failures (network, schema drift, backend rejection) surface as a Retry / Start over prompt; partial replay state is discarded. |
| R9 | Disk save failures are silent (logged, not user-visible). |
| R10 | Persistence schema is versioned; mismatched versions on load wipe the draft. |

## Architecture

### New files (under `Projects/SubmitClaimChat/Sources/Models/Persistence/`)

- **`StepSnapshot.swift`** — `ChainSnapshot`, `StepSnapshot`, `StepInput`,
  `ExecutionState`, `ReplayBlockReason` DTOs. Declares the `Persistable`
  protocol that handlers conform to.
- **`ClaimChatDraftStore.swift`** — disk I/O. Atomic writes to
  `<Documents>/claim-chat-draft.json`. `save(_:)`, `load() -> ChainSnapshot?`,
  `clear()`. Self-healing on corrupt files. Schema version + TTL enforced on
  load. Test-friendly: file URL is injectable.
- **`ChainReplayer.swift`** — orchestrates replay. Takes a `ChainSnapshot`
  and the live `ClaimIntentService`; returns `ReplayResult` with the
  rehydrated handler array and the current claim intent.

### Modified files

- **`Models/SubmitClaimChatModel.swift`** — add `Codable` conformance to
  `ClaimIntent`, `ClaimIntentStep`, `ClaimIntentStepContent`, and all nested
  content structs. (`Deflection` is already `Codable`; the synthesized
  decoder round-trips its `id` correctly even though the memberwise `init`
  regenerates it from `UUID()`.)
- **`Models/ClaimIntentStepHandler.swift`** — declare conformance to
  `Persistable`. Default `snapshot()` reads `claimIntent`, `state.isSkipped`,
  `state.isStepExecuted` and asks the subclass for its input via an
  abstract `defaultInputCase()`. Default `applyRestoredInput(_:)` is a
  no-op.
- **`Models/SubmitClaimFormStep.swift`** — override `snapshot()` to serialize
  `formValues` as `[FieldValue]` (plus `selectedSearchItem` per search field
  to preserve display title). Override `applyRestoredInput(_:)` to re-populate
  `formValues[fieldId].values` and `selectedSearchItem`.
- **`Models/SubmitClaimSingleSelectStep.swift`** — override `snapshot()` to
  serialize `selectedOptionId`. Override `applyRestoredInput(_:)` to set it.
- **`Models/SubmitClaimSummaryStep.swift`** — `defaultInputCase()` returns
  `.summary`. No input data; no `applyRestoredInput` override.
- **`Models/SubmitClaimTaskStep.swift`** — `defaultInputCase()` returns
  `.task`. No input data.
- **`Models/SubmitClaimDeflectStep.swift`** — `defaultInputCase()` returns
  `.deflect`. No input data. Note: deflect is terminal and `executeStep`
  always throws, so saves never fire past a deflect.
- **`Models/SubmitClaimAudioStep.swift`** — `defaultInputCase()` returns
  `.audio(notReplayable: .mediaStep)`. Snapshot data is intentionally minimal
  because replay stops here.
- **`Models/SubmitClaimFileUploadStep.swift`** — same pattern: returns
  `.fileUpload(notReplayable: .mediaStep)`.
- **`Views/SubmitClaimChatScreen.swift`** — `SubmitClaimChatViewModel`:
  - `init` branches on `ClaimChatDraftStore.load()`; if a draft exists, set
    `resumePrompt = .pending(snapshot)` instead of calling
    `startClaimIntent()`.
  - Add `userChoseToResume()`, `userChoseToStartOver()`,
    `userChoseToRetry()` actions.
  - Hook `saveDraft()` into `processClaimIntent` for `.goToNext` and
    `.regret`.
  - Clear the draft on `.outcome`.
- **`Navigation/SubmitClaimFlowNavigation.swift`** — present the resume
  prompt as a bottom-sheet detent (same pattern as the existing
  `SubmitClaimChatHonestyPledgeScreen`).

## Data model

```swift
struct ChainSnapshot: Codable {
    let schemaVersion: Int        // currently 1; bump on shape changes
    let savedAt: Date             // ISO8601-encoded; used for 7-day TTL
    let startInput: StartClaimInput
    let steps: [StepSnapshot]
}

struct StepSnapshot: Codable {
    let claimIntent: ClaimIntent
    let executionState: ExecutionState
    let input: StepInput
}

enum ExecutionState: String, Codable {
    case executed    // user submitted; we have the next step
    case skipped     // user explicitly skipped
    case pending     // current step at save time; last entry only
}

enum StepInput: Codable {
    case form(fields: [FieldValue], searchSelections: [String: SingleSelectValue])
    case singleSelect(selectedOptionId: String)
    case summary
    case task
    case deflect
    case audio(notReplayable: ReplayBlockReason)
    case fileUpload(notReplayable: ReplayBlockReason)
}

enum ReplayBlockReason: String, Codable {
    case mediaStep
}
```

`StartClaimInput`, `FieldValue`, and `SingleSelectValue` need `Codable`
conformance. The first two are already `Codable` or trivially made so;
`SingleSelectValue` is small (all `String?` / `String` / `Bool`) and adds
the conformance directly.

```swift
@MainActor
protocol Persistable {
    func snapshot() -> StepSnapshot
    func applyRestoredInput(_ input: StepInput)
}
```

## Persistence layer

```swift
@MainActor
final class ClaimChatDraftStore {
    static let shared = ClaimChatDraftStore()

    private static let fileName = "claim-chat-draft.json"
    private static let ttl: TimeInterval = 7 * 24 * 60 * 60
    static let currentSchemaVersion = 1

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileURL: URL = Self.defaultFileURL()) {
        self.fileURL = fileURL
        // encoder/decoder use .iso8601 dateEncodingStrategy
    }

    func save(_ snapshot: ChainSnapshot)         // logs and returns on failure
    func load() -> ChainSnapshot?                // returns nil on missing/corrupt/expired/version-mismatch; clears on each
    func clear()
}
```

- **Documents directory** chosen over Caches; drafts must survive OS-driven
  cache eviction.
- **Atomic writes** (`Data.writeOptions = .atomic`) avoid half-written files
  on crash.
- **Schema version** enforced on load — mismatched versions wipe the draft.
- **Self-healing** on decode error: load returns nil and deletes the file
  so a corrupted draft never permanently breaks the resume prompt.
- **iOS Data Protection** default (`.completeUnlessOpen`) is sufficient.
  Explicit `.completeFileProtection` is not added — it would prevent saves
  while the device is locked, which is undesirable for background-triggered
  saves.
- **Singleton** via `.shared`; `@MainActor` ensures save/load are serialized
  by the main actor. Tests construct their own instance with a temp-dir URL.

## Replay flow

```swift
@MainActor
final class ChainReplayer {
    enum ReplayError: Error {
        case startIntentFailed
        case stepResponseMissing
        case backendReturnedOutcomeMidReplay
        case unexpectedStepType(expected: String, got: String)
        case underlyingService(Error)
    }

    struct ReplayResult {
        let restoredHandlers: [ClaimIntentStepHandler]
        let currentClaimIntent: ClaimIntent
        let progress: Float?
    }

    func replay(_ snapshot: ChainSnapshot) async throws -> ReplayResult
}
```

Algorithm:

1. Call `service.startClaimIntent(input: snapshot.startInput)`. If it
   doesn't return `.intent`, throw `.startIntentFailed`.
2. Walk `snapshot.steps` in order:
   - Break on `.audio(notReplayable:)`, `.fileUpload(notReplayable:)`, or
     `executionState == .pending`.
   - Assert backend's current step content case matches the saved case
     (`.form == .form`, etc.); throw `.unexpectedStepType` on drift.
   - Build a fresh handler via `ClaimIntentStepHandlerFactory` from the
     **backend's** `currentIntent` (not the saved one).
   - Apply the saved input: `handler.applyRestoredInput(snapshotStep.input)`.
   - Submit:
     - If `executionState == .skipped`, call
       `service.claimIntentSkipStep(stepId:)`.
     - Else, call `handler.executeStep()`. This routes through the same
       live submit path the UI uses, exercising real validation and error
       handling.
   - Wrap any thrown error as `.underlyingService`.
   - Mark the handler as executed/skipped, disable animations
     (`state.animateText = false`, `isLoaderAnimating = false`,
     `showLoadingAnimation = false`), append to `restored`.
   - On `.outcome` mid-replay, throw `.backendReturnedOutcomeMidReplay`.
3. After the loop, build a handler for the new "current" `currentIntent`
   (the step the user will land on), append it, and return.

**Design choice — replay uses live `executeStep()` rather than reaching
into the service directly.** This means any per-step behavior (validation,
error wrapping, side effects on `state`) is exercised identically during
replay. The cost is that replay is coupled to step-handler internals; the
benefit is a single submit path to maintain.

**Retry policy.** A failed replay can be retried, but each retry calls
`startClaimIntent` again, abandoning the previous backend intent. There is
no per-step retry. All-or-nothing per attempt because subsequent step IDs
become invalid after the first failure.

## Resume UX

State on the ViewModel:

```swift
enum ResumePromptState {
    case notNeeded
    case pending(snapshot: ChainSnapshot)
    case replaying
    case failed(snapshot: ChainSnapshot, error: Error)
    case resolved
}
@Published var resumePrompt: ResumePromptState
```

- `notNeeded`: no draft on disk; `startClaimIntent()` runs from `init`.
- `pending`: draft exists; a bottom-sheet detent (same pattern as
  `SubmitClaimChatHonestyPledgeScreen`) appears before the chat loads, with
  "Continue" and "Start over" actions.
- `replaying`: the existing `ClaimChatLoadingAnimationView` covers the chat.
- `failed`: an inline error alert (existing `AlertHelper` +
  `SubmitClaimChatScreenAlertViewModel.alertModel`) with "Retry" and
  "Start over" actions.
- `resolved`: normal chat flow.

Localization keys to add (Lokalise):

- `claimChatResumeTitle` — "Continue previous claim?"
- `claimChatResumeBody` — "We saved your progress from earlier. Want to pick up where you left off?"
- `claimChatResumeContinueButton` — "Continue"
- `claimChatResumeStartOverButton` — "Start over"
- `claimChatResumeFailedTitle` — "Couldn't restore your claim"
- `claimChatResumeFailedBody` — "Something went wrong while loading your previous progress."
- `claimChatResumeRetryButton` — "Retry"

Final copy will be finalized via the standard Lokalise sync; the keys
above are placeholders for the spec.

## Error handling

| Failure | Behavior |
|---|---|
| Disk full / sandbox error on save | Log, return. Live flow continues; no draft persisted. |
| Corrupt JSON on load | `clear()`; return nil. |
| Schema version mismatch on load | `clear()`; return nil. No migration. |
| TTL expired | `clear()`; return nil. |
| `startClaimIntent` fails during replay | Throw `.startIntentFailed`; ViewModel → `.failed`. |
| Network error mid-replay | Wrap as `.underlyingService`; ViewModel → `.failed`. Retry starts a fresh intent. |
| Backend returns `.outcome` mid-replay | Throw `.backendReturnedOutcomeMidReplay`; ViewModel → `.failed`. |
| Backend's current step type differs from saved | Throw `.unexpectedStepType`; ViewModel → `.failed`. |
| Backend rejects a replayed submit | Wrap as `.underlyingService`; ViewModel → `.failed`. |
| Replay stops early at media step | Not an error; user lands on the media step ready to upload. |
| Outcome reached but `clear()` fails | Next launch will offer resume for a submitted claim. Resume will likely succeed again or hit drift. Acceptable. |

## Known tradeoffs

- **Stranded backend intents.** Every replay attempt starts a fresh
  `claimIntent` server-side and abandons the previous one. A user who
  resumes three times before completing has three orphaned intents on the
  server. Acceptable for this iteration; resolved by option B's server-side
  resume endpoint.
- **No telemetry for replay success rate** in v1. Can be added later if we
  want to track how often replay actually succeeds in production.

## Testing

New test files under `Projects/SubmitClaimChat/Tests/Persistence/`,
following the patterns in `Projects/SubmitClaimChat/Tests/SubmitClaimChatTests.swift`.

**`ClaimChatDraftStoreTests`** — pure disk I/O with a temp-dir file URL:
- `test_save_then_load_returnsSameSnapshot`
- `test_load_returnsNil_whenFileMissing`
- `test_load_returnsNil_andClears_whenSchemaVersionMismatched`
- `test_load_returnsNil_andClears_whenExpired`
- `test_load_returnsNil_andClears_onCorruptJson`
- `test_save_isAtomic`

**`StepSnapshotCodableTests`** — DTO round-trip:
- `test_chainSnapshot_codable_roundtrip_form`
- `test_chainSnapshot_codable_roundtrip_singleSelect`
- `test_chainSnapshot_codable_roundtrip_audio_preservesReplayBlockReason`
- `test_chainSnapshot_codable_roundtrip_searchField`
- `test_claimIntent_codable_roundtrip_allContentCases` (one per case)

**`ChainReplayerTests`** — fake `ClaimIntentClient` (mirroring
`ClaimIntentClientDemo` from `Service/DemoImplementation/`):
- `test_replay_emptyChain_callsStartAndReturnsFirstStep`
- `test_replay_singleFormStep_executed_advancesToNext`
- `test_replay_skippedStep_callsSkipNotSubmit`
- `test_replay_stopsAtAudioStep`
- `test_replay_throwsBackendReturnedOutcomeMidReplay`
- `test_replay_throwsUnexpectedStepType_onContentDrift`
- `test_replay_propagatesServiceError`
- `test_replay_restoredHandlersHaveAnimationsDisabled`

**`SubmitClaimChatViewModelResumeTests`** — integration-style with fake
client and temp-dir store:
- `test_init_noDraft_callsStartClaimIntent`
- `test_init_withValidDraft_setsResumePromptPending`
- `test_userChoseToResume_success_setsResumePromptResolved_andRestoresChain`
- `test_userChoseToResume_failure_setsResumePromptFailed_withSameSnapshot`
- `test_userChoseToStartOver_clearsDraft_andCallsStartClaimIntent`
- `test_outcomeReached_clearsDraft`
- `test_eachSuccessfulStep_writesDraft`
- `test_regret_writesTruncatedDraft`

Per `CLAUDE-testing.md`, every test class adds memory-leak teardown blocks
asserting `XCTAssertNil` on weak references to the ViewModel and replayer.

**Out of scope for v1 tests:** UI snapshot tests of the resume detent;
cross-launch integration tests; "realistic 10-step chain" end-to-end
tests.

## Open items (for implementation planning)

- Exact final copy for the seven new localization keys (handed to writers
  via Lokalise once the spec is approved).
- Whether `ClaimChatDraftStore` should be registered through the existing
  `Dependencies.shared` DI container or remain a plain singleton.
  Preference: keep as a plain singleton with injectable file URL — the DI
  container is overkill for a single-implementation store.
