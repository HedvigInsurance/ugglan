# NotificationService

App extension that intercepts and modifies push notifications before display. Manages a badge count via shared `UserDefaults` (app group suite).

## Key Files
- `NotificationService.swift` — `UNNotificationServiceExtension` subclass; modifies notification content and tracks badge count
- `Config/Dev/NotificationService.entitlements` — Development entitlements
- `Config/Prod/NotificationService.entitlements` — Production entitlements
- `Info.plist` — Extension configuration

## Dependencies
- UserNotifications (system framework only; no internal module dependencies)

## Gotchas
- This is an **app extension**, not a standard framework module; it has no `Sources/` directory or `Project.swift`
- Uses `UserDefaults(suiteName:)` with a computed app group name derived from the bundle identifier
- Badge count is persisted and incremented per notification; there is no mechanism here to reset it
