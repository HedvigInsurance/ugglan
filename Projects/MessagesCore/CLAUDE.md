# MessagesCore

Data layer for the in-app Messages inbox (emails, SMS and Kivra messages sent to the member). UI-free; depends only on `hCore`.

## Key Files
- `Sources/Models/InboxMessage.swift` — `MessageChannel`, `InboxMessage`, `InboxFilter`, `InboxSort`, `InboxDateRange` (either end open, whole days inclusive) and `InboxSections` (filters by type and date, sorts and splits messages into the "Unread" and "Earlier" sections).
- `Sources/Service/Protocols/MessagesClient.swift` — `MessagesClient` protocol (`getMessages`, `markAsRead`) + `MessagesError`.
- `Sources/Service/MessagesService.swift` — thin `@Inject` wrapper with `@Log`.
- `Sources/Service/DemoImplementation/MessagesClientDemo.swift` — in-memory inbox with the sample messages from the Figma frames (dates relative to now).
- `Sources/Store/MessagesStore.swift` — `MessagesStore` (`AppStore`): `state: LoadState<[InboxMessage]>`, `unreadCount`, `message(with:)`, optimistic `markAsRead`.

## Dependencies
- `hCore`
- Octopus impl: `Projects/App/Sources/Service/OctopusClientsImplementation/MessagesClientOctopus.swift`.

## Consumers
- `MessagesUI` (screens), `Home` (bell badge via `MessagesStore.unreadCount`), `App` (DI).

## Gotchas
- **No backend yet.** `MessagesClientOctopus` delegates to `MessagesClientDemo`, so the real app shows sample data. The feature is reachable only behind the Unleash flag `enable_messages_inbox` (`FeatureData.isMessagesInboxEnabled`). Replace the Octopus client once the API exists.
- `MessagesStore` is an `AppStore` (not a ViewModel) because the Home bell and the Messages screens share the unread state. Everything in it is `@Transient`: message content is always fetched fresh.
- A failed refresh keeps the current list and reports no error; only a failed first load shows `.failed`.
