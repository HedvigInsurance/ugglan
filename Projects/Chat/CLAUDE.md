# Chat

The Chat module provides the customer support messaging interface. It includes an inbox view listing all conversations, individual chat screens with real-time message polling, file/image upload and sharing, message retry on failure, and push notification prompting.

## Architecture
- **Mixed pattern**: The primary chat UI uses the modern ViewModel pattern (`ChatScreenViewModel`, `ChatMessageViewModel`, `ChatConversationViewModel` -- all `@MainActor class: ObservableObject`). However, there is also a legacy `ChatStore: StateStore<ChatState, ChatAction>` used specifically for persisting failed messages and tracking push notification permission state.
- **Key services**:
  - `ChatServiceProtocol` -- abstraction for fetching/sending messages within a conversation. Has two concrete implementations: `ConversationService` (existing conversation by ID) and `NewConversationService` (creates a conversation on first message send).
  - `ConversationClient` -- protocol for the raw API operations (get messages with pagination tokens, send message).
  - `ConversationsClient` -- protocol for listing and creating conversations.
  - `ChatFileUploaderClient` -- protocol for file upload.
  - `ConversationsDemoClient` -- demo implementation that satisfies both `ConversationsClient` and `ConversationClient`.
- **Data flow**: `ChatScreenViewModel` owns a `ChatMessageViewModel` (which owns a `ChatConversationViewModel`) and a `ChatInputViewModel`. On appear, a 5-second polling timer fetches new messages via `ChatServiceProtocol.getNewMessages()`. Messages are stored in `ChatMessageViewModel.messages` as `@Published` state. Pagination for older messages uses token-based cursors (`olderToken`/`newerToken`).

## Key Files
- **Entry point / navigation**: `Navigation/ChatNavigation.swift` -- `ChatNavigation` view (wraps `RouterHost`), `ChatNavigationViewModel`, `ChatType` routing
- **Chat screen**: `Views/ChatScreen.swift` -- `ChatScreen` view with flipped scroll, `ChatScreenModifier`, `ChatScrollViewDelegate`
- **ViewModels**: `Views/ChatScreenViewModel.swift` -- `ChatScreenViewModel`, `ChatMessageViewModel`, `ChatConversationViewModel`
- **Inbox**: `Views/InboxView.swift` -- `InboxView`, `InboxViewModel` (uses `@Inject var service: ConversationsClient`)
- **Legacy store**: `ChatStore.swift` -- `ChatStore`, `ChatState`, `ChatAction` (failed message persistence, push notification flag)
- **Service layer**: `Service/ChatService.swift` -- `ChatServiceProtocol`, `ConversationService`, `NewConversationService`
- **Service protocols**: `Service/Protocols/ConversationClient.swift` -- `ConversationClient`, `ConversationsClient`, `ConversationMessagesData`
- **File upload protocol**: `Service/Protocols/ChatUploadFileClient.swift` -- `ChatFileUploaderClient`
- **Demo implementation**: `Service/DemoImplementation/ConversationsClientDemo.swift`
- **Message views**: `Views/MessageView.swift`, `Views/MessageViews/ActionView.swift`, `Views/MessageViews/LinkView.swift`
- **Input**: `Views/ChatInputView.swift`, `Views/ChatFileView.swift`, `Views/ImagesView.swift`
- **Models**: `Models/Chat.swift` (ChatData), `Models/Message.swift`, `Models/Conversation.swift`
- **Helpers**: `Helpers/Message+Timestamp.swift`, `Helpers/Message+UI.swift`, `Helpers/MessageType+Helpers.swift`, `Helpers/View+Flipped.swift`, `Helpers/WebMetaDataProvider.swift`

## Dependencies
- **Imports**: hCore, hCoreUI, Contracts (via Project.swift). Also uses PresentableStore at the file level.
- **Depended on by**: Home (imports Chat for InboxView and ChatType), Claims (imports Chat), App

## Navigation
- **Routes defined here**:
  - `ChatNavigationViewModel` manages the chat entry by `ChatType`: `.conversationId(id:)`, `.conversationFromClaimWithId(id:)`, `.newConversation`, `.inbox`
  - `ChatRedirectViewType.notification` -- push notification permission prompt
  - `ChatRedirectViewType.claimDetailFor(claimId:)` -- navigates to claim detail from within a chat conversation
- **Entry from other modules**: Chat is opened via `NotificationCenter.default.post(name: .openChat, object: ChatType)` from anywhere in the app. `HomeNavigationViewModel` listens for this notification and presents `ChatNavigation` as a detent/modal. The inbox is also pushed within Home and Help Center navigation stacks.
- **Navigation style**: Uses legacy `RouterHost + Router` pattern. `ChatNavigationViewModel` owns a `Router` and presents file previews, push notification prompts, and automation info views via `.detent()` modifiers.

## Gotchas
- The chat scroll is "flipped upside down" (`.flippedUpsideDown()`) so new messages appear at the bottom -- this is a common iOS chat pattern but can be confusing when reading the layout code.
- Message polling runs on a 5-second timer. There is no WebSocket or push-based real-time messaging.
- `NewConversationService` lazily creates a conversation on the server when the user sends the first message, then delegates to a `ConversationService` for subsequent operations.
- `ChatScrollViewDelegate` accesses private UIKit APIs (via `_sheetInteraction` KVC) to disable sheet dismissal while scrolling -- this is fragile and could break on iOS updates.
- The `ChatStore` (legacy PresentableStore) is only used for two concerns: tracking failed messages per conversation and whether push notification permission has been requested. Everything else uses the ViewModel pattern.
- `AskForRating` is triggered 2 seconds after the chat screen opens.
