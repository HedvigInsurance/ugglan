# SubmitClaimChat

The current, chat-based claim submission flow. The backend drives the flow one step at a time (forms, single select,
audio recording, file upload, summary, server tasks, information, deflection), and each step is rendered as a chat
message with an input card.

## Architecture
- `SubmitClaimChatViewModel` (in `SubmitClaimChatScreen.swift`) owns the router, the list of step handlers, scroll
  state and errors. It starts the intent on init via `ClaimIntentFlowManager` and handles `SubmitClaimEvent`s
  (`goToNext`, `regret`, `removeStep`, `outcome`).
- Every API call returns a `ClaimIntentType`: `.intent(model:)` (next step) or `.outcome(model:)` (done; pushes
  `SubmitClaimOutcomeScreen`).
- One `ClaimIntentStepHandler` subclass per step type, created by `ClaimIntentStepHandlerFactory.createHandler` from
  `ClaimIntentStepContent`. Subclasses override `executeStep()` (the base calls `fatalError`) and optionally
  `validateInput()`. When adding a step type, add the subclass, a factory case and the matching step view.
- `ClaimIntentService` (in `Service/Protocols/ClaimIntentClient.swift`) wraps `ClaimIntentClient`;
  `hSubmitClaimFileUploadClient` handles uploads with progress.

## Entry points
- `.handleClaimFlow(startInput:onViewDeinit:)`, applied in App's `LoggedInNavigation` and bound to
  `HomeNavigationViewModel.claimsAutomationStartInput`. It shows the honesty pledge detent, then the flow modally.
  `StartClaimInput` lives here (Home holds it on `HomeNavigationViewModel`).

## Dependencies
- hCore, hCoreUI, Claims
- Depended on by: Home, App

## Gotchas
- The client never knows the step sequence in advance; don't hardcode step order.
- `SubmitClaimTaskStep` polls `getNextStep(claimIntentId:)` until the server-side task completes.
- `ClaimChatScrollCoordinator` decides whether the input floats at the bottom, merges with the content, or shows a
  "scroll to bottom" button. Scroll changes are easy to break; test regret and long forms.
- The global `disableSubmitChatClaimAnimations` comes from Dev Settings (`isSubmitClaimAnimationsEnabled`) and zeroes
  the chat animation timings.
- Dismiss confirmation depends on the `isResumeClaimEnabled` flag: when it's on, the alert only shows for resumable
  intents (resume-draft copy); when it's off, the generic claims alert always shows. The outcome screen posts
  `.claimCreated` on deinit.
