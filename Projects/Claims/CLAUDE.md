# Claims

Displays and manages the status of insurance claims after submission. Provides active-claim cards for the home screen, a claim detail view with file uploads and chat access, and a claim history screen for closed/resolved claims.

## Architecture
- Pattern: Legacy Store (PresentableStore). `ClaimsStore` is a `StateStore<ClaimsState, ClaimsAction>` with `effects` for async work and `reduce` for state mutations. Views observe the store via `@PresentableStore` or subscribe to `stateSignal` through dedicated ViewModels (`ClaimsViewModel`, `ClaimHistoryViewModel`, `ClaimDetailViewModel`). The ViewModels are `ObservableObject` classes that bridge the store into SwiftUI.
- Key services and protocols:
  - `hFetchClaimsClient` (protocol) -- fetches active and history claim lists. Octopus implementation lives in `Projects/App/Sources/Service/OctopusClientsImplementation/FetchClaimClientOctopus.swift`. Demo implementation in `Service/DemoImplementation/FetchClaimClientDemo.swift`.
  - `hFetchClaimDetailsClient` (protocol) -- fetches a single claim by ID, its files, and acknowledges closed status. Wrapped by `FetchClaimDetailsService` (a thin logging facade). Octopus implementation in `Projects/App/Sources/Service/OctopusClientsImplementation/FetchClaimDetailsClientOctopus.swift`. Demo in `Service/DemoImplementation/FetchClaimDetailsClientDemo.swift`.
  - `hClaimFileUploadClient` (protocol) -- uploads files to a claim endpoint with progress reporting. Wrapped by `hClaimFileUploadService` (logging facade). Has a local Octopus implementation at `Service/OctopusImplementation/UploadClaimFileClientOctopus.swift` and demo in `Service/DemoImplementation/UploadClaimFileDemoClient.swift`.
- Data flow: Actions like `.fetchActiveClaims` and `.fetchHistoryClaims` are dispatched to `ClaimsStore`. The store's `effects` method calls the injected `hFetchClaimsClient` via `@Inject`, then dispatches `.setActiveClaims` or `.setHistoryClaims` to persist results. ViewModels subscribe to `store.stateSignal` (Combine publisher) and update `@Published` properties. `ClaimDetailViewModel` uses `FetchClaimDetailsService` directly for single-claim fetches and file operations, bypassing the store for the detail data but writing files back into `ClaimsState` via `.setFilesForClaim`. All service clients are registered at app launch in `AppDelegate+DI.swift`.

## Key Files
- `Sources/ClaimAction.swift` -- `ClaimsAction` enum (fetch active, fetch history, set claims, set files, loading states) and `ClaimsNavigationAction`.
- `Sources/ClaimState.swift` -- `ClaimsState` struct holding `activeClaims`, `historyClaims`, `files` dictionary, and `loadingStates`. Exposes `hasActiveClaims` computed property.
- `Sources/ClaimStore.swift` -- `ClaimsStore` (`StateStore` subclass) with effects and reducer. Injects `hFetchClaimsClient`.
- `Sources/Models/ClaimModel.swift` -- `ClaimModel` (main domain model) with nested `ClaimStatus`, `ClaimOutcome`, and `ClaimDisplayItem` types. Also contains `CrossSellInfo` conversion for post-claim cross-sell.
- `Sources/Views/ClaimDetailView.swift` -- Full claim detail screen with status card, info section, chat link, member free text, claim details, file upload section, and document/PDF section. Contains `ClaimDetailViewModel` in the same file.
- `Sources/Views/ClaimFilesView.swift` -- File upload flow with progress indicator and success screen. Contains `ClaimFilesViewModel` and `FileUrlModel`.
- `Sources/Views/ClaimHistoryScreen.swift` -- Lists closed claims. Contains `ClaimHistoryViewModel`.
- `Sources/Views/ClaimsCard.swift` -- Home screen card showing active claims (single card or horizontal scroll). Contains `ClaimsViewModel` with a 60-second polling timer.
- `Sources/Views/ClaimStatusCard.swift` -- Reusable card component showing claim type, submission date, status bar, outcome pills, and a details button. Contains `ClaimPills` and preview helper `ClaimModel.previewData`.
- `Sources/Views/ClaimStatusBar.swift` -- Three-segment progress bar (submitted / being handled / closed) with accessibility labels.
- `Sources/Views/ClaimSection.swift` -- Horizontal scroll wrapper using `InfoCardScrollView` for multiple active claims.
- `Sources/Views/FilesGridView.swift` -- Grid layout for file thumbnails with delete and preview capabilities. Contains `FileGridViewModel`.
- `Sources/Service/Protocols/FetchClaimsClient.swift` -- `hFetchClaimsClient` protocol.
- `Sources/Service/Protocols/FetchClaimDetailsClient.swift` -- `hFetchClaimDetailsClient` protocol, `FetchClaimDetailsService` facade, `ClaimDetailsType` enum, `FetchClaimDetailsError`.
- `Sources/Service/Protocols/UploadClaimFileClient.swift` -- `hClaimFileUploadClient` protocol.
- `Sources/Service/OctopusImplementation/UploadClaimFileClientOctopus.swift` -- `hClaimFileUploadService` (logging wrapper) and `ClaimFileUploadResponse`/`FileUpload` response models.
- `Sources/Service/Models/UploadFileResponseModel.swift` -- `UploadFileResponseModel` for audio URL responses.
- `Tests/FetchClaimsTests.swift` -- Unit tests for active claims, history claims, and file fetching using a mock service.
- `Tests/MockData.swift` -- `MockFetchClaimsService` conforming to `hFetchClaimsClient` with injectable closures. Factory method `createMockFetchClaimService` registers the mock into `Dependencies`.

## Dependencies
- Imports: hCore (DI, File model, MonetaryAmount, logging), hCoreUI (UI components, Router, hForm, hSection, hRow, hButton, StatusCard, InfoCard, PDFPreview, DocumentPreview, AudioPlayer, TrackPlayerView, InfoCardScrollView), PresentableStore (StateStore, @PresentableStore, globalPresentableStoreContainer), Chat (Conversation model, ChatType), CrossSell (CrossSellInfo), Apollo (imported but not directly used in Sources -- leftover), Kingfisher (image loading in file views), Combine, Photos, SwiftUI.
- Project-level dependencies declared in `Project.swift`: hCore, hCoreUI, Contracts, Chat, Payment.
- Dependents (modules that import Claims): App, Home, Profile, SubmitClaimChat.

## Navigation
- `ClaimsCard` is embedded in `MainHomeView` (Home module) as the active claims widget on the home tab.
- Tapping a claim card pushes `ClaimModel` onto the home `Router`. In `LoggedInNavigation.swift`, `.routerDestination(for: ClaimModel.self)` maps this to `ClaimDetailView`.
- `ClaimHistoryScreen` is navigated to from the Profile module; it receives an `onTap` closure that routes back through the caller's router.
- Deep link `claim-details?id=` and push notifications (`OPEN_CLAIM`, `CLAIM_CLOSED`) also open `ClaimDetailView` through `LoggedInNavigation`.
- From `ClaimDetailView`, tapping the chat row posts a `Notification.Name.openChat` notification (handled globally by `LoggedInNavigation`) to open the claim conversation.
- On `ClaimDetailView` dismiss, if `showClaimClosedFlow` is true, a `Notification.Name.openCrossSell` notification is posted to trigger the cross-sell flow.

## Gotchas
- **Local OctopusImplementation**: `Sources/Service/OctopusImplementation/UploadClaimFileClientOctopus.swift` contains `hClaimFileUploadService` (the logging wrapper with upload logic) directly in the Claims module. Per convention, Octopus implementations should live in `Projects/hGraphQL/`. The other two Octopus implementations (`FetchClaimsClientOctopus`, `FetchClaimDetailsClientOctopus`) correctly live in the App module but also belong in hGraphQL.
- **Apollo import without direct use**: `ClaimAction.swift`, `ClaimState.swift`, and `ClaimStore.swift` all import Apollo even though they do not reference any Apollo types directly. These are leftover imports.
- **ViewModel co-located with View**: `ClaimDetailViewModel` (130+ lines) lives at the bottom of `ClaimDetailView.swift` rather than in its own file. Similarly, `ClaimFilesViewModel` is in `ClaimFilesView.swift` and `FileGridViewModel` is in `FilesGridView.swift`.
- **UIKit escape hatches**: `ClaimFilesViewModel` and `ClaimDetailView` reach into UIKit via `UIApplication.shared.getTopViewControllerNavigation()` and `UIApplication.shared.getTopViewController()` to toggle navigation bar visibility and present UIAlertControllers.
- **Timer-based polling**: `ClaimDetailViewModel` polls claim details every 5 seconds to check for new chat messages, and `ClaimsViewModel` polls active claims every 60 seconds. Neither uses push-based updates.
- **Notification-based navigation**: Chat opening and cross-sell triggering use `NotificationCenter.default.post` rather than direct router calls, creating implicit coupling.
