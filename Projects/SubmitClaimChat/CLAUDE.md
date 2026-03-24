# SubmitClaimChat

The SubmitClaimChat module implements the current chat-based claims submission flow. It presents a guided, multi-step claim intent experience rendered as a chat conversation, where the backend drives the flow by returning the next step after each user response. Steps include forms, single-select options, audio recordings, file uploads, summaries, tasks, and deflection screens.

## Architecture
- **ViewModel pattern**: The core ViewModel is `SubmitClaimChatViewModel` (`@MainActor final class: ObservableObject`), which manages step progression, scroll coordination, and error handling. Each step type has a dedicated `ClaimIntentStepHandler` subclass (factory pattern via `ClaimIntentStepHandlerFactory`). No `PresentableStore` is used in this module.
- **Key services**:
  - `ClaimIntentClient` -- protocol defining all claim intent API operations (start, submit audio/file/form/select/summary/task, skip, regret, search).
  - `ClaimIntentService` -- thin wrapper around `ClaimIntentClient` that uses `@Inject` for the client.
  - `ClaimIntentFlowManager` -- orchestrates the flow by delegating to `ClaimIntentService` and using `ClaimIntentStepHandlerFactory` to create step handlers.
  - `hSubmitClaimFileUploadClient` -- protocol for file upload with progress tracking.
  - `ClaimIntentClientDemo` -- demo implementation of `ClaimIntentClient`.
- **Data flow**: `SubmitClaimChatViewModel` calls `ClaimIntentFlowManager.startClaimIntent()` on init. The backend returns a `ClaimIntentType` which is either `.intent(model:)` (continue to next step) or `.outcome(model:)` (flow complete). Each step handler's `executeStep()` submits the user's response and returns the next `ClaimIntentType`. The ViewModel processes events via `processClaimIntent()` which appends new step handlers, handles regret (go back), or navigates to the outcome screen.
- **Step handler pattern**: `ClaimIntentStepHandler` is the base class. Subclasses (`SubmitClaimFormStep`, `SubmitClaimAudioStep`, `SubmitClaimFileUploadStep`, `SubmitClaimSingleSelectStep`, `SubmitClaimSummaryStep`, `SubmitClaimTaskStep`, `SubmitClaimDeflectStep`) override `executeStep()` and `validateInput()`. The factory in `ClaimIntentStepHandlerFactory.createHandler()` maps `ClaimIntentStepContent` cases to the appropriate subclass.

## Key Files
- **Entry point / navigation**: `Navigation/SubmitClaimFlowNavigation.swift` -- `SubmitClaimFlowNavigation` (wraps `RouterHost`), `SubmitClaimChatInput`
- **Flow launcher**: `Navigation/ClaimFlowLauncher.swift` -- `ClaimFlowLauncher` ViewModifier, `handleClaimFlow()` extension (honesty pledge -> claim flow)
- **Main screen**: `Views/SubmitClaimChatScreen.swift` -- `SubmitClaimChatScreen` view, `SubmitClaimChatViewModel`
- **Step handler base**: `Models/ClaimIntentStepHandler.swift` -- `ClaimIntentStepHandler`, `ClaimIntentStepHandlerFactory`, `SubmitClaimEvent`, `ClaimIntentError`
- **Step handler subclasses**: `Models/SubmitClaimFormStep.swift`, `Models/SubmitClaimAudioStep.swift`, `Models/SubmitClaimFileUploadStep.swift`, `Models/SubmitClaimSingleSelectStep.swift`, `Models/SubmitClaimSummaryStep.swift`, `Models/SubmitClaimTaskStep.swift`, `Models/SubmitClaimDeflectStep.swift`
- **Flow manager**: `Models/ClaimIntentFlowManager.swift`
- **Scroll coordinator**: `Models/ClaimChatScrollCoordinator.swift`
- **Constants**: `Models/ClaimChatConstants.swift`
- **Form field validator**: `Models/FormFieldValidator.swift`
- **Service protocol**: `Service/Protocols/ClaimIntentClient.swift` -- `ClaimIntentClient`, `ClaimIntentService`, `StartClaimInput`, `FieldValue`
- **File upload protocol**: `Service/Protocols/FileUploadClient.swift` -- `hSubmitClaimFileUploadClient`
- **Demo implementation**: `Service/DemoImplementation/ClaimIntentClientDemo.swift`
- **Models**: `Models/SubmitClaimChatModel.swift` -- `ClaimIntent`, `ClaimIntentStep`, `ClaimIntentStepContent`, `ClaimIntentStepOutcome`, plus all content model structs (form fields, audio recording, file upload, summary, select, deflection, outcome)
- **Step views**: `Views/Steps/SubmitClaimFormView.swift`, `SubmitClaimSingleSelectView.swift`, `SubmitClaimSummaryView.swift`, `SubmitClaimFileUploadView.swift`, `SubmitClaimVoiceRecordingView.swift`, `SubmitClaimTaskView.swift`, `SubmitClaimDeflectView.swift`, `SubmitClaimSuccessView.swift`, `SubmitClaimOutcomeScreen.swift`, `FormFieldSearchView.swift`, `FormFieldSearchViewModel.swift`, `SingleSelectValueView.swift`
- **Chat message view**: `Views/SubmitClaimChatMessageView.swift`
- **Honesty pledge**: `Views/SubmitClaimChatHonestyPledgeScreen.swift`
- **Voice recording**: `Views/VoiceRecording/VoiceRecorder.swift`, `VoiceRecordButton.swift`, `VoicePlaybackButton.swift`, `VoiceSendButton.swift`, `VoiceStartOverButton.swift`, `VoiceWaveformView.swift`, `VoiceRecordingCardContent.swift`
- **Components**: `Views/Components/ClaimChatLoadingAnimationView.swift`, `RevealTextView.swift`, `ProgressIndicator.swift`, `NavigationBarProgressModifier.swift`, `SupportView.swift`, `AlertHelper.swift`
- **Contact card**: `Views/ClaimContactCard.swift`
- **Extensions**: `Extensions/AccessibilityHelpers.swift`

## Dependencies
- **Imports**: hCore, hCoreUI, Claims (via Project.swift)
- **Depended on by**: Home (imports SubmitClaimChat for `StartClaimInput`, `handleClaimFlow`, and `SubmitClaimChatInput`), App

## Navigation
- **Routes defined here**:
  - `ClaimFlowLauncher` -- ViewModifier that presents the honesty pledge detent, then the full claim flow modally
  - `SubmitClaimFlowNavigation` -- `RouterHost` that routes to `SubmitClaimChatScreen`, outcome screens (`ClaimIntentStepOutcome`), and deflection screens (`ClaimIntentOutcomeDeflection`)
  - The public API is the `handleClaimFlow(startInput:)` view modifier, used by Home to bind to `HomeNavigationViewModel.claimsAutomationStartInput`
- **Entry from other modules**: Home triggers the flow by setting `claimsAutomationStartInput` on `HomeNavigationViewModel`. The `ClaimFlowLauncher` modifier intercepts this binding.
- **Navigation style**: Uses legacy `RouterHost + Router`. The flow uses `router.push()` for outcome/deflection screens and `router.dismiss()` for error-driven exits.

## Gotchas
- The entire flow is backend-driven. The client does not know the sequence of steps in advance -- it receives one step at a time from the `ClaimIntentClient` API and renders the appropriate view.
- `ClaimIntentStepHandler.executeStep()` is abstract (calls `fatalError`) and must be overridden by every subclass.
- `SubmitClaimTaskStep` is a special step type representing a server-side processing task. It polls `ClaimIntentService.getNextStep()` periodically until the task is marked as completed.
- The scroll coordination logic (`ClaimChatScrollCoordinator`) is complex, managing whether the input area should float at the bottom, merge with content, or show a "scroll to bottom" button based on content height and scroll position.
- A global `disableSubmitChatClaimAnimations` flag can disable chat message animations, set when the user skips the honesty pledge animation.
- On dismissal, the flow posts a `.claimCreated` notification and supports alert-based dismissal confirmation via `withAlertDismiss`.
