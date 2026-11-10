# ChatCore

UI-free data layer for customer support messaging: message and conversation models, `ChatStore`, the conversation
client protocols, the chat services and the demo client. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/Message.swift`, `Conversation.swift`, `Chat.swift` (`ChatData`) — message, conversation and chat
  payload models
- `Sources/Models/ConversationsError.swift` — errors thrown by the conversation services and clients
- `Sources/ChatStore.swift` — `ChatStore` (`AppStore`): failed-message persistence per conversation and the
  push-notification-permission flag
- `Sources/Service/ChatService.swift` — `ChatServiceProtocol`, `ConversationService` (existing conversation),
  `NewConversationService` (creates the conversation on first send)
- `Sources/Service/Protocols/ConversationClient.swift` — `ConversationClient`, `ConversationsClient`,
  `ConversationMessagesData`
- `Sources/Service/Protocols/ChatUploadFileClient.swift` — `ChatFileUploaderClient`, `ChatUploadFileResponseModel`
- `Sources/Service/DemoImplementation/ConversationsClientDemo.swift` — `ConversationsDemoClient`
- `Sources/Helpers/Message+Timestamp.swift`, `MessageType+Helpers.swift` — formatting and link detection helpers

## Dependencies
- hCore, AppStateContainer
- Depended on by: ChatUI, Claims (`Conversation`), App (`ConversationsClientOctopus`, `ChatUploadFileClientOctopus`,
  DI, `NewConversationService`)

## Gotchas
- No test target: the chat tests exercise `ChatScreenViewModel` and live in ChatUITests.
