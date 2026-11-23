# NotificationService

`UNNotificationServiceExtension` that sets the badge number on incoming push notifications before display. The badge
count is kept in shared `UserDefaults` (app group suite, key `count`).

## Dependencies
- UserNotifications only; no internal module dependencies.

## Gotchas
- This is an **app extension** without its own `Project.swift`: the `NotificationService` (dev) and
  `NotificationServiceProd` targets are declared in `Projects/App/Project.swift`, with entitlements in
  `Config/Dev` and `Config/Prod`.
- The app group name is derived from the bundle identifier (`group.` + bundle id without the last component). The app
  resets the count in `MainNavigation` (`resetBadge`, using `group.<app bundle id>`), so both sides must keep
  resolving to the same suite.
