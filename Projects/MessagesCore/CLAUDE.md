# MessagesCore

Data layer for the in-app Messages inbox (emails, SMS and Kivra messages sent to the member). UI-free; depends only on `hCore`.

## Key Files
- `Sources/Models/InboxMessage.swift` — `MessageChannel`, `InboxMessage` (`body` is nil until loaded), `InboxFilter`, `InboxSort`, `InboxDateRange` (either end open, whole days inclusive) and `InboxList` (filters by type and date, then sorts).
- `Sources/Service/Protocols/MessagesClient.swift` — `MessagesClient` protocol (`getMessages`, `getMessageContent`) + `MessagesError`.
- `Sources/Service/MessagesService.swift` — thin `@Inject` wrapper with `@Log`.
- `Sources/Service/DemoImplementation/MessagesClientDemo.swift` — in-memory inbox with the sample messages from the Figma frames (dates relative to now).
- `Sources/Store/MessagesStore.swift` — `MessagesStore` (`AppStore`): `state: LoadState<[InboxMessage]>`, `message(with:)`, `loadBody(messageId:)` (fetches once, keeps it on the message and across refreshes; also fills a missing preheader).

## Dependencies
- `hCore`
- Octopus impl: `Projects/App/Sources/Service/OctopusClientsImplementation/MessagesClientOctopus.swift`.

## Consumers
- `MessagesUI` (screens), `Home` (bell; preloads the inbox via `MessagesStore.fetchMessages()`), `App` (DI).

## Gotchas
- **Backed by Customer.io deliveries** (`Member.cioMessages` / `Member.cioMessageContent`, notification-service). The list carries no bodies; each body is fetched on open, because Customer.io caps its archived-message endpoint at 100 requests/day workspace-wide (the backend caches them). `preview` and `sender` can be nil for older messages. Deliveries with a null `messageType` are dropped. The feature is behind the Unleash flag `enable_messages_inbox` (`FeatureData.isMessagesInboxEnabled`).
- No read state and no category: the API has neither. The row is titled by channel.
- `MessagesStore` is an `AppStore` (not a ViewModel) because Home preloads the inbox and the Messages screens read it. Everything in it is `@Transient`: nothing is persisted between launches.
- A failed refresh keeps the current list and reports no error; only a failed first load shows `.failed`.
