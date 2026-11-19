# MessagesUI

SwiftUI screens for the in-app Messages inbox, built on MessagesCore: inbox list, filter sheet and opened message.

## Key Files
- `Sources/Navigation/MessagesNavigation.swift` — `MessagesRouterAction` (`.inbox`, `.message(id:)`) and `.messagesRouterDestinations()`, which registers both screens on the enclosing `hNavigationStack` (applied in App's `HomeTab`).
- `Sources/Views/MessagesInboxScreen.swift` — inbox screen (one card, newest first), `MessageRow` (titled by channel), loading skeleton, empty/error states.
- `Sources/Views/MessagesInboxViewModel.swift` — type filter and date range over `MessagesStore` (always newest first).
- `Sources/Views/MessagesFilterToolbarButton.swift` — envelope (type) and calendar (date) buttons in the navigation bar, next to the title; a blue dot marks the active filter. The calendar is an SF Symbol because the Hedvig UI kit has none.
- `Sources/Views/MessagesFilterSheet.swift` — "Show" sheet with `hRadioOptionList`; picking an option applies it and closes the sheet (only "Cancel" below).
- `Sources/Views/MessagesDateFilterSheet.swift` — "Date" sheet with a `MultiDatePicker` shown straight away: first tap = start, second tap = end, the days between are highlighted; a single day filters to that day. "Clear dates" removes the range.
- `Sources/Components/MessagesSheetLayout.swift` — shared sheet layout: title, subtitle, content, glass button pair, content-fitted detent.
- `Sources/Views/MessageDetailScreen.swift` — opened message; loads its body on appear via `MessagesStore.loadBody(messageId:)`, with a loader and a retry on failure.
- `Sources/Components/MessagesScreenLayout.swift` — shared chrome matching the chat Inbox: standard white bar with a centred inline title, optional trailing toolbar buttons, `hForm` content.
- `Sources/Components/EmailWebView.swift` — read-only `WKWebView` for email HTML.
- `Sources/Components/MessagesComponents.swift` — `HedvigAvatar`, `MessagesCard`, `.messagesGlassButton(_:)`.

## Dependencies
- `hCore`, `hCoreUI`, `MessagesCore`

## Consumers
- `Home` (pushes `MessagesRouterAction.inbox` from the bell), `App` (registers the destinations).

## Gotchas
- **Liquid Glass is native.** Pills and sheet buttons use `.glass` / `.glassProminent` on iOS 26 (`.messagesGlassButton`), with hCoreUI capsules as the fallback. The filter sheet is a system `.sheet` (not the app's `.detent`) so it gets the iOS 26 glass sheet; its height is measured from its content.
- Glass tints are resolved to a plain `Color` (`colorFor(colorScheme, .base)`): hColor's `.tint` sets the accent colour, which `.glassProminent` buttons inside a sheet ignore, so they turned system blue.
- `MultiDatePicker` only selects separate days, so the date sheet feeds it every day of the range as the selection and turns each tap (the one day added or removed) back into a start/end edit. Its bound is `..<Date()`: a bound at tomorrow's midnight still left tomorrow selectable.
- **Email links can't be opened.** `EmailWebView` allows only the initial `loadHTMLString` navigation and cancels everything else; JavaScript and link previews are off, and the injected CSS greys out links and buttons. Colours come from hCoreUI tokens resolved for the current colour scheme, and the Hedvig font is inlined as base64 because the web content process can't see app-registered fonts. Remote images load normally.
- `InboxMessage.body` is HTML for emails (web view) and plain text for SMS and Kivra (`hText`); the channel decides.
- There is no read state: the backend has none, so no unread section, "New" pill or bell badge.
