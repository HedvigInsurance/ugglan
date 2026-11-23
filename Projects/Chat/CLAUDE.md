# Chat

Customer support messaging: the inbox (list of conversations), chat screens with polling for new messages,
file/image upload, retry of failed messages, a push-notification permission prompt, and a cross-sell banner.

## Architecture
- ViewModels (`@MainActor @Observable`): `ChatScreenViewModel` owns a `ChatInputViewModel` and a
  `ChatMessageViewModel`, which in turn owns a `ChatConversationViewModel` and a `ChatCrossSellViewModel`.
  `InboxViewModel` drives the inbox.
- `ChatStore` (`@PersistableStore` `AppStore`) is used only for failed messages per conversation (persisted) and
  `askedForPushNotificationsPermission` (`@Transient`). Everything else uses ViewModels.
- `ChatServiceProtocol` has two implementations: `ConversationService` (existing conversation by ID) and
  `NewConversationService`. They sit on the `ConversationClient` (messages), `ConversationsClient` (list/create
  conversations) and `ChatFileUploaderClient` protocols. `ConversationsDemoClient` implements both conversation
  protocols.
- `ConversationService` pages messages with token cursors (`olderToken` / `newerToken`).

## Entry points
- Open chat from anywhere by posting `NotificationCenter.default.post(name: .openChat, object: ChatType)`.
  `ChatType` is `.conversationId(id:)`, `.conversationFromClaimWithId(id:)`, `.newConversation` or `.inbox`.
  Home's `HomeNavigationViewModel` observes this and App's `LoggedInNavigation` presents `ChatNavigation`.
- `InboxView` is also pushed inside Home's Help Center stack.
- `ChatRedirectViewType` (`.notification`, `.claimDetailFor(claimId:)`) handles redirects out of a conversation.

## Dependencies
- hCore, hCoreUI, AddonsCore, ContractsCore, CrossSellCore, CrossSellUI
- Depended on by: App, Claims, Home

## Gotchas
- The message list is flipped (`.flippedUpsideDown()`) so new messages appear at the bottom. Keep this in mind when
  reading layout code.
- New messages come from a 5-second polling timer. There is no WebSocket or push-based delivery.
- `NewConversationService` creates the conversation on the server when the first message is sent, then hands off
  to a `ConversationService`.
- `ChatScrollViewDelegate` reads a private `UISheetPresentationController` property through KVC (`_sheetInteraction`)
  to block sheet dismissal while scrolling. This is fragile across iOS updates.
- `AskForRating` is triggered 2 seconds after the chat screen opens.
